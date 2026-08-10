# frozen_string_literal: true

# == Schema Information
#
# Table name: work_schedule_publications
#
#  id                :integer          not null, primary key
#  payload           :json             not null
#  published_at      :datetime         not null
#  revision          :integer          not null
#  source_updated_at :datetime         not null
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  published_by_id   :integer          not null
#  work_schedule_id  :integer          not null
#
# Indexes
#
#  idx_schedule_publications_revision                    (work_schedule_id,revision) UNIQUE
#  index_work_schedule_publications_on_published_by_id   (published_by_id)
#  index_work_schedule_publications_on_work_schedule_id  (work_schedule_id)
#
# Foreign Keys
#
#  published_by_id   (published_by_id => users.id)
#  work_schedule_id  (work_schedule_id => work_schedules.id)
#
class WorkSchedulePublication < ApplicationRecord
  belongs_to :work_schedule, inverse_of: :work_schedule_publications
  belongs_to :published_by, class_name: "User"

  validates :revision, :source_updated_at, :published_at, :payload, presence: true
  validates :revision, uniqueness: {scope: :work_schedule_id}, numericality: {only_integer: true, greater_than: 0}

  before_update :prevent_change
  before_destroy :prevent_change

  def readonly?
    persisted?
  end

  private

  def prevent_change
    throw(:abort)
  end
end
