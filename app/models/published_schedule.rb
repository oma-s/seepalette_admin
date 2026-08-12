# frozen_string_literal: true

class PublishedSchedule
  attr_reader :publication, :payload

  class << self
    def all
      WorkSchedule.includes(:work_schedule_publications).filter_map do |schedule|
        publication = schedule.latest_publication
        new(publication) if publication
      end.sort_by(&:starts_on)
    end

    def default_for(date = Time.zone.today, schedules: all)
      schedules.find { |schedule| date.between?(schedule.starts_on, schedule.ends_on) } ||
        schedules.select { |schedule| schedule.starts_on > date }.min_by(&:starts_on) ||
        schedules.select { |schedule| schedule.ends_on < date }.max_by(&:ends_on)
    end

    def upcoming_for(user, from:, to: nil, limit: nil, schedules: all)
      shifts = schedules.flat_map { |schedule| schedule.shifts_for(user) }
        .select { |shift| shift[:ends_at] >= from }
      shifts.select! { |shift| shift[:starts_at] <= to } if to
      shifts.sort_by! { |shift| shift[:starts_at] }
      limit ? shifts.first(limit) : shifts
    end
  end

  def initialize(publication)
    @publication = publication
    @payload = publication.payload.deep_symbolize_keys
  end

  def id
    publication.work_schedule_id
  end

  def title
    payload.fetch(:title)
  end

  def notes
    payload[:notes]
  end

  def starts_on
    Date.iso8601(payload.fetch(:starts_on))
  end

  def ends_on
    Date.iso8601(payload.fetch(:ends_on))
  end

  def days
    @days ||= payload.fetch(:days, []).map do |day|
      date = Date.iso8601(day.fetch(:date))
      {
        date: date,
        grid_start_minute: day[:grid_start_minute],
        grid_end_minute: day[:grid_end_minute],
        notices: day.fetch(:notices, []),
        stations: day.fetch(:stations, []).map do |station|
          {
            name: station.fetch(:name),
            position: station[:position],
            shifts: station.fetch(:shifts, []).map { |shift| normalize_shift(shift, date, station.fetch(:name), day.fetch(:notices, [])) }
          }
        end
      }
    end
  end

  def all_shifts
    @all_shifts ||= days.flat_map { |day| day[:stations].flat_map { |station| station[:shifts] } }
      .sort_by { |shift| [shift[:starts_at], shift[:ends_at]] }
  end

  def shifts_for(user)
    all_shifts.select { |shift| shift[:user_id] == user.id }
  end

  def day(date)
    days.find { |day| day[:date] == date }
  end

  private

  def normalize_shift(shift, date, station_name, notices)
    {
      schedule_id: id,
      schedule_title: title,
      schedule_notes: notes,
      date: date,
      station_name: station_name,
      notices: notices,
      user_id: shift.fetch(:user_id).to_i,
      user_name: shift.fetch(:user_name),
      user_color: shift.fetch(:user_color, "slate"),
      starts_at: Time.zone.parse(shift.fetch(:starts_at)),
      ends_at: Time.zone.parse(shift.fetch(:ends_at)),
      start_time: shift[:start_time],
      end_time: shift[:end_time],
      overnight: shift[:overnight],
      notes: shift[:notes]
    }
  end
end
