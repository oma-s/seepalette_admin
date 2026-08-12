# frozen_string_literal: true

module Portal
  class WorkSchedulesController < BaseController
    def show
      @schedules = PublishedSchedule.all
      @schedule = selected_schedule
      return unless @schedule

      @team_view = params[:view] == "team"
      @selected_date = selected_date
      @selected_week = selected_week
      @shifts = @team_view ? @schedule.all_shifts : @schedule.shifts_for(current_user)
      schedule_index = @schedules.index(@schedule)
      @previous_schedule = @schedules[schedule_index - 1] if schedule_index&.positive?
      @next_schedule = @schedules[schedule_index + 1] if schedule_index && schedule_index < @schedules.length - 1
    end

    private

    def selected_schedule
      if params[:schedule_id].present?
        @schedules.find { |schedule| schedule.id == params[:schedule_id].to_i }
      else
        PublishedSchedule.default_for(schedules: @schedules)
      end
    end

    def selected_date
      requested = Date.iso8601(params[:date]) if params[:date].present?
      return requested if requested&.between?(@schedule.starts_on, @schedule.ends_on)

      Time.zone.today.clamp(@schedule.starts_on, @schedule.ends_on)
    rescue Date::Error
      @schedule.starts_on
    end

    def selected_week
      requested = Date.iso8601(params[:week]).beginning_of_week if params[:week].present?
      requested ||= @selected_date.beginning_of_week
      [requested, @schedule.starts_on.beginning_of_week].max
    rescue Date::Error
      @selected_date.beginning_of_week
    end
  end
end
