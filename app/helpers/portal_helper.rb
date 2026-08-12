# frozen_string_literal: true

module PortalHelper
  SCHEDULE_COLORS = User::SCHEDULE_COLORS.keys.freeze

  def portal_nav_link(label, path, section)
    active = controller_path.start_with?("portal/#{section}")
    link_to label, path, class: class_names("portal-nav__link", "is-active": active), aria: {current: ("page" if active)}
  end

  def format_minutes(minutes)
    minutes = minutes.to_i
    hours, remainder = minutes.divmod(60)
    "#{hours} Std. #{remainder.to_s.rjust(2, "0")} Min."
  end

  def format_shift_time(shift)
    suffix = shift[:overnight] ? " (+1)" : ""
    "#{shift[:starts_at].strftime("%H:%M")}–#{shift[:ends_at].strftime("%H:%M")}#{suffix}"
  end

  def schedule_color_class(color)
    value = SCHEDULE_COLORS.include?(color) ? color : "slate"
    "shift-color--#{value}"
  end

  def working_hour_form_values(working_hour)
    {
      date: working_hour.date&.iso8601 || Time.zone.today.iso8601,
      start_time: working_hour.start_at&.strftime("%H:%M"),
      end_time: working_hour.end_at&.strftime("%H:%M"),
      overnight: working_hour.start_at && working_hour.end_at && working_hour.end_at.to_date > working_hour.start_at.to_date
    }
  end
end
