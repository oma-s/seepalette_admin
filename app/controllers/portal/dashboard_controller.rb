# frozen_string_literal: true

module Portal
  class DashboardController < BaseController
    UPCOMING_WINDOW = 14.days
    UPCOMING_LIMIT = 5

    def show
      @announcements = Announcement.visible_at.display_order
      @published_schedules = PublishedSchedule.all
      now = Time.current
      @upcoming_shifts = PublishedSchedule.upcoming_for(
        current_user,
        from: now,
        to: now + UPCOMING_WINDOW,
        limit: UPCOMING_LIMIT,
        schedules: @published_schedules
      )
      @next_later_shift = if @upcoming_shifts.empty?
        PublishedSchedule.upcoming_for(current_user, from: now, limit: 1, schedules: @published_schedules).first
      end

      month = Time.zone.today.all_month
      @working_minutes = current_user.working_hours.where(date: month).sum(:duration_minutes)
      @expense_total = current_user.expenses.where(date: month).sum("km * factor")
    end
  end
end
