# frozen_string_literal: true

# == Schema Information
#
# Table name: stations
#
#  id              :integer          not null, primary key
#  active          :boolean          default(TRUE), not null
#  default_enabled :boolean          default(FALSE), not null
#  name            :string           not null
#  position        :integer          default(0), not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#
# Indexes
#
#  index_stations_on_active_and_default_enabled_and_position  (active,default_enabled,position)
#  index_stations_on_name                                     (name) UNIQUE
#
class Station < ApplicationRecord
  DEFAULT_NAMES = ["Brötchen", "Küche", "Küche 1", "Küche 2", "Bar", "Runner", "CvD", "Aushilfe"].freeze

  has_many :work_schedule_day_stations, dependent: :restrict_with_error

  scope :active, -> { where(active: true) }
  scope :defaults, -> { where(default_enabled: true) }
  scope :ordered, -> { order(:position, :name) }

  validates :name, presence: true, uniqueness: {case_sensitive: false}
  validates :position, numericality: {only_integer: true, greater_than_or_equal_to: 0}

  def to_s
    name
  end

  def self.ensure_defaults!
    DEFAULT_NAMES.each_with_index do |name, position|
      find_or_create_by!(name: name) do |station|
        station.position = position
        station.default_enabled = true
        station.active = true
      end
    end
  end
end
