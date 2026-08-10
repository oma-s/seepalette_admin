# frozen_string_literal: true

ActiveAdmin.register WorkSchedule do
  menu parent: "Dienstplanung", priority: 1, label: "Dienstpläne"

  permit_params :title, :starts_on, :ends_on, :notes

  filter :title
  filter :starts_on
  filter :ends_on
  filter :created_at

  action_item :planner, only: :show do
    link_to "Planer öffnen", planner_admin_work_schedule_path(resource)
  end

  action_item :edit_schedule, only: :planner do
    link_to "Einstellungen", edit_admin_work_schedule_path(resource)
  end

  index do
    selectable_column
    id_column
    column :title
    column("Zeitraum") { |schedule| "#{l(schedule.starts_on)} – #{l(schedule.ends_on)}" }
    column("Status") { |schedule| status_tag schedule.publication_state.to_s.humanize }
    column("Tage") { |schedule| schedule.work_schedule_days.size }
    column("Schichten") { |schedule| schedule.work_shifts.size }
    column :updated_at
    actions defaults: true do |schedule|
      item "Planer", planner_admin_work_schedule_path(schedule)
    end
  end

  show do
    attributes_table do
      row :title
      row :starts_on
      row :ends_on
      row(:status) { |schedule| status_tag schedule.publication_state.to_s.humanize }
      row("Letzte Veröffentlichung") do |schedule|
        publication = schedule.latest_publication
        publication && "Revision #{publication.revision}, #{l(publication.published_at)}"
      end
      row :notes
      row :created_at
      row :updated_at
    end

    panel "Übersicht" do
      div do
        link_to "Dienstplan im Planer bearbeiten", planner_admin_work_schedule_path(resource), class: "button"
      end
      table_for resource.work_schedule_days do
        column :date
        column("Stationen") { |day| day.work_schedule_day_stations.size }
        column("Schichten") { |day| day.work_shifts.size }
        column("Hinweise") { |day| day.day_notices.size }
      end
    end
  end

  form do |f|
    f.semantic_errors(*f.object.errors.attribute_names)
    f.inputs "Dienstplan" do
      f.input :title
      f.input :starts_on, as: :date_picker
      f.input :ends_on, as: :date_picker
      f.input :notes
    end
    para "Für jeden Kalendertag im Zeitraum wird automatisch ein Tag angelegt. Eine Verkürzung ist nur möglich, wenn die entfallenden Tage keine Schichten oder Hinweise enthalten."
    f.actions
  end

  member_action :planner, method: :get do
    @work_schedule = resource
    render "admin/work_schedules/planner"
  end

  member_action :planner_data, method: :get do
    render json: resource.planner_payload
  end

  member_action :save_shift, method: :post do
    schedule = resource
    attributes = planner_shift_attributes(schedule)
    shift = params[:shift_id].present? ? schedule.work_shifts.find(params[:shift_id]) : WorkShift.new
    if shift.persisted? && !attributes[:user].schedulable? && shift.user_id != attributes[:user].id
      return render json: {errors: ["Diese Person ist nicht für neue Schichten freigeschaltet"]}, status: :unprocessable_entity
    end

    shift.assign_attributes(attributes)
    if shift.save
      render json: {shift: shift.planner_payload}
    else
      render_validation_errors(shift)
    end
  rescue ActiveRecord::RecordNotFound
    render json: {errors: ["Tag, Station, Person oder Schicht wurde nicht gefunden"]}, status: :not_found
  rescue ArgumentError => error
    render json: {errors: [error.message]}, status: :unprocessable_entity
  end

  member_action :delete_shift, method: :delete do
    shift = resource.work_shifts.find(params.require(:shift_id))
    shift.destroy!
    head :no_content
  rescue ActiveRecord::RecordNotFound
    render json: {errors: ["Schicht wurde nicht gefunden"]}, status: :not_found
  end

  member_action :save_day, method: :patch do
    day = resource.work_schedule_days.find(params.require(:day_id))
    if day.update(params.require(:day).permit(:grid_start_minute, :grid_end_minute))
      render json: {day: day.planner_payload}
    else
      render_validation_errors(day)
    end
  end

  member_action :save_notice, method: :post do
    day = resource.work_schedule_days.find(params.require(:day_id))
    notice = params[:notice_id].present? ? day.day_notices.find(params[:notice_id]) : day.day_notices.new
    notice.assign_attributes(params.require(:notice).permit(:text, :severity))
    if notice.save
      render json: {notice: {id: notice.id, text: notice.text, severity: notice.severity, created_at: notice.created_at.iso8601}}
    else
      render_validation_errors(notice)
    end
  end

  member_action :delete_notice, method: :delete do
    notice = resource.work_schedule_days.find(params.require(:day_id)).day_notices.find(params.require(:notice_id))
    notice.destroy!
    head :no_content
  end

  member_action :add_station, method: :post do
    day = resource.work_schedule_days.find(params.require(:day_id))
    station_params = params.require(:day_station).permit(:station_id, :name, :scope, :default_enabled)
    day_station = if station_params[:station_id].present?
      day.add_catalog_station!(Station.active.find(station_params[:station_id]))
    elsif station_params[:scope] == "catalog"
      station = Station.create!(
        name: station_params[:name],
        default_enabled: ActiveModel::Type::Boolean.new.cast(station_params[:default_enabled]),
        position: Station.maximum(:position).to_i + 1
      )
      day.add_catalog_station!(station)
    else
      day.add_custom_station!(station_params[:name])
    end
    render json: {station: day_station.planner_payload}
  rescue ActiveRecord::RecordInvalid => error
    render_validation_errors(error.record)
  end

  member_action :remove_station, method: :delete do
    day_station = resource.work_schedule_day_stations.find(params.require(:day_station_id))
    if day_station.work_shifts.exists?
      render json: {errors: ["Eine Station mit Schichten kann nicht entfernt werden"]}, status: :unprocessable_entity
    else
      day_station.destroy!
      head :no_content
    end
  end

  member_action :copy_day, method: :post do
    source = resource.work_schedule_days.find(params.require(:source_day_id))
    target = resource.work_schedule_days.find(params.require(:target_day_id))
    target.copy_from!(source,
      include_stations: boolean_param(:include_stations),
      include_notices: boolean_param(:include_notices),
      include_shifts: boolean_param(:include_shifts))
    render json: {day: target.reload.planner_payload}
  rescue ActiveRecord::RecordInvalid => error
    render_validation_errors(error.record)
  end

  member_action :duplicate_schedule, method: :post do
    duplicate = resource.duplicate_to!(params.require(:starts_on),
      include_stations: boolean_param(:include_stations),
      include_notices: boolean_param(:include_notices),
      include_shifts: boolean_param(:include_shifts))
    render json: {id: duplicate.id, location: planner_admin_work_schedule_path(duplicate)}
  rescue ActiveRecord::RecordInvalid => error
    render_validation_errors(error.record)
  rescue ArgumentError => error
    render json: {errors: [error.message]}, status: :unprocessable_entity
  end

  member_action :publish_schedule, method: :post do
    publication = resource.publish!(current_user)
    render json: {revision: publication.revision, publication_state: resource.reload.publication_state}
  rescue ActiveRecord::RecordInvalid
    render json: {errors: ["Ein Dienstplan benötigt mindestens eine gültige Schicht"]}, status: :unprocessable_entity
  end

  controller do
    def scoped_collection
      super.includes(:work_schedule_publications, work_schedule_days: [:day_notices, {work_schedule_day_stations: :work_shifts}])
    end

    private

    def planner_shift_attributes(schedule)
      values = params.require(:shift).permit(:user_id, :day_station_id, :date, :start_time, :end_time, :overnight, :notes)
      day = schedule.work_schedule_days.find_by!(date: Date.iso8601(values.require(:date)))
      day_station = day.work_schedule_day_stations.find(values.require(:day_station_id))
      user = User.find(values.require(:user_id))
      if !user.schedulable? && params[:shift_id].blank?
        raise ArgumentError, "Diese Person ist nicht für neue Schichten freigeschaltet"
      end

      start_time = time_on(day.date, values.require(:start_time))
      end_date = day.date + (ActiveModel::Type::Boolean.new.cast(values[:overnight]) ? 1.day : 0.days)
      {
        work_schedule_day_station: day_station,
        user: user,
        starts_at: start_time,
        ends_at: time_on(end_date, values.require(:end_time)),
        notes: values[:notes]
      }
    end

    def time_on(date, value)
      hour, minute = value.to_s.split(":", 2).map { |part| Integer(part, 10) }
      raise ArgumentError, "Ungültige Uhrzeit" unless hour&.between?(0, 23) && minute&.between?(0, 59)

      Time.zone.local(date.year, date.month, date.day, hour, minute)
    rescue TypeError, ArgumentError
      raise ArgumentError, "Ungültige Uhrzeit"
    end

    def boolean_param(name)
      ActiveModel::Type::Boolean.new.cast(params[name])
    end

    def render_validation_errors(record)
      render json: {errors: record.errors.full_messages}, status: :unprocessable_entity
    end
  end
end
