# frozen_string_literal: true

# == Schema Information
#
# Table name: announcements
#
#  id            :integer          not null, primary key
#  active        :boolean          default(TRUE), not null
#  body          :text             not null
#  priority      :integer          default(0), not null
#  severity      :string           default("info"), not null
#  title         :string           not null
#  visible_from  :datetime
#  visible_until :datetime
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#
# Indexes
#
#  idx_announcements_visibility                    (active,visible_from,visible_until)
#  index_announcements_on_priority_and_created_at  (priority,created_at)
#
class Announcement < ApplicationRecord
  SEVERITIES = %w[info warning critical].freeze

  validates :title, :body, presence: true
  validates :severity, inclusion: {in: SEVERITIES}
  validates :priority, numericality: {only_integer: true}
  validate :visible_until_after_visible_from

  scope :visible_at, ->(time = Time.current) {
    where(active: true)
      .where("visible_from IS NULL OR visible_from <= ?", time)
      .where("visible_until IS NULL OR visible_until >= ?", time)
  }
  scope :display_order, -> {
    order(priority: :desc, created_at: :desc)
  }

  private

  def visible_until_after_visible_from
    return if visible_from.blank? || visible_until.blank? || visible_until > visible_from

    errors.add(:visible_until, "muss nach dem Sichtbarkeitsbeginn liegen")
  end
end
