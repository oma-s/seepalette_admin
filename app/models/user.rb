# frozen_string_literal: true

# == Schema Information
#
# Table name: users
#
#  id                     :integer          not null, primary key
#  email                  :string           not null
#  encrypted_password     :string           not null
#  failed_attempts        :integer          default(0), not null
#  family_name            :string
#  given_name             :string           not null
#  locked_at              :datetime
#  remember_created_at    :datetime
#  reset_password_sent_at :datetime
#  reset_password_token   :string
#  schedulable            :boolean          default(TRUE), not null
#  schedule_color         :string           not null
#  unlock_token           :string
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#
# Indexes
#
#  index_users_on_email                 (email) UNIQUE
#  index_users_on_reset_password_token  (reset_password_token) UNIQUE
#  index_users_on_schedulable           (schedulable)
#  index_users_on_unlock_token          (unlock_token) UNIQUE
#
class User < ApplicationRecord
  rolify

  DEFAULT_EMAIL = "admin@example.com"
  SCHEDULE_COLORS = {
    "indigo" => "Indigo",
    "blue" => "Blau",
    "cyan" => "Cyan",
    "teal" => "Petrol",
    "green" => "Grün",
    "lime" => "Limette",
    "amber" => "Bernstein",
    "orange" => "Orange",
    "rose" => "Rosa",
    "fuchsia" => "Fuchsia",
    "violet" => "Violett",
    "slate" => "Schiefer"
  }.freeze

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :recoverable, :rememberable, :validatable

  has_many :expenses, dependent: :restrict_with_error
  has_many :addresses, as: :addressable, dependent: :destroy
  has_many :working_hours, dependent: :restrict_with_error
  has_many :work_shifts, dependent: :restrict_with_error
  has_many :work_schedule_publications, foreign_key: :published_by_id, dependent: :restrict_with_error, inverse_of: :published_by

  scope :schedulable, -> { where(schedulable: true) }

  validates :given_name, :family_name, presence: true
  validates :email, presence: true, uniqueness: true, format: {with: URI::MailTo::EMAIL_REGEXP}
  validates :schedule_color, inclusion: {in: SCHEDULE_COLORS.keys}
  validates :password, presence: true, on: :create
  validates :password, length: {minimum: 6}, allow_blank: true
  validate :admin_role_may_be_removed, if: -> { @admin_role_assignment == false }

  after_initialize :assign_schedule_color, if: :new_record?
  before_validation :assign_schedule_color, on: :create
  after_save :apply_admin_role, if: -> { !@admin_role_assignment.nil? }

  def admin?
    has_role?(:admin)
  end

  def admin_role
    @admin_role_assignment.nil? ? admin? : @admin_role_assignment
  end

  def admin_role=(value)
    @admin_role_assignment = ActiveModel::Type::Boolean.new.cast(value)
  end

  def to_s
    [given_name, family_name].compact_blank.join(" ")
  end

  def self.schedule_color_options
    SCHEDULE_COLORS.map { |value, label| [label, value] }
  end

  private

  def assign_schedule_color
    return if schedule_color.present?

    usage = self.class.where(schedule_color: SCHEDULE_COLORS.keys).group(:schedule_color).count
    self.schedule_color = SCHEDULE_COLORS.keys.min_by { |color| [usage.fetch(color, 0), SCHEDULE_COLORS.keys.index(color)] }
  end

  def admin_role_may_be_removed
    return unless admin?

    if email == DEFAULT_EMAIL
      errors.add(:admin_role, "kann dem geschützten Standard-Admin nicht entzogen werden")
    elsif User.with_role(:admin).where.not(id: id).none?
      errors.add(:admin_role, "kann dem letzten Admin nicht entzogen werden")
    end
  end

  def apply_admin_role
    @admin_role_assignment ? add_role(:admin) : remove_role(:admin)
    @admin_role_assignment = nil
  end
end
