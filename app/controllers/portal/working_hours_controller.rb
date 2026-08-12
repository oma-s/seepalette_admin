# frozen_string_literal: true

module Portal
  class WorkingHoursController < BaseController
    before_action :set_working_hour, only: %i[edit update destroy]

    def index
      @month = requested_month
      @working_hours = current_user.working_hours.where(date: @month.all_month).order(start_at: :desc)
      @total_minutes = @working_hours.sum(:duration_minutes)
    end

    def new
      @working_hour = current_user.working_hours.new(break_minutes: 0)
      prefill_from_schedule
    end

    def create
      @working_hour = current_user.working_hours.new
      if assign_form_attributes(@working_hour) && @working_hour.save
        redirect_to portal_working_hours_path(month: @working_hour.date.strftime("%Y-%m")), notice: "Arbeitszeit wurde erfasst."
      else
        render :new, status: :unprocessable_content
      end
    end

    def edit
    end

    def update
      if assign_form_attributes(@working_hour) && @working_hour.save
        redirect_to portal_working_hours_path(month: @working_hour.date.strftime("%Y-%m")), notice: "Arbeitszeit wurde aktualisiert."
      else
        render :edit, status: :unprocessable_content
      end
    end

    def destroy
      month = @working_hour.date.strftime("%Y-%m")
      @working_hour.destroy!
      redirect_to portal_working_hours_path(month: month), notice: "Arbeitszeit wurde gelöscht."
    end

    private

    def set_working_hour
      @working_hour = current_user.working_hours.find(params[:id])
    end

    def requested_month
      Date.strptime(params[:month].to_s, "%Y-%m").beginning_of_month
    rescue Date::Error
      Time.zone.today.beginning_of_month
    end

    def assign_form_attributes(record)
      values = params.require(:working_hour).permit(:date, :start_time, :end_time, :overnight, :break_minutes)
      date = Date.iso8601(values.require(:date))
      start_at = time_on(date, values.require(:start_time))
      end_date = date + (ActiveModel::Type::Boolean.new.cast(values[:overnight]) ? 1.day : 0.days)
      record.assign_attributes(
        date: date,
        start_at: start_at,
        end_at: time_on(end_date, values.require(:end_time)),
        break_minutes: values[:break_minutes]
      )
      true
    rescue ActionController::ParameterMissing, ArgumentError
      record.errors.add(:base, "Bitte Datum und Uhrzeiten vollständig angeben")
      false
    end

    def time_on(date, value)
      hour, minute = value.to_s.split(":", 2).map { |part| Integer(part, 10) }
      raise ArgumentError unless hour.between?(0, 23) && minute.between?(0, 59)

      Time.zone.local(date.year, date.month, date.day, hour, minute)
    end

    def prefill_from_schedule
      starts_at = Time.zone.parse(params[:starts_at]) if params[:starts_at].present?
      ends_at = Time.zone.parse(params[:ends_at]) if params[:ends_at].present?
      return unless starts_at && ends_at

      @working_hour.assign_attributes(date: starts_at.to_date, start_at: starts_at, end_at: ends_at)
    rescue ArgumentError
      nil
    end
  end
end
