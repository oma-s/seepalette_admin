# frozen_string_literal: true

class User < ApplicationRecord
  rolify
  
  DEFAULT_EMAIL = 'admin@example.com'

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :recoverable, :rememberable, :validatable

  has_many :expenses, dependent: :restrict_with_error
  has_many :addresses, as: :addressable, dependent: :destroy

  validates :given_name, :family_name, presence: true
  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :password, presence: true, length: { minimum: 6 }

  def admin?
    has_role?(:admin)
  end

  def to_s
    [given_name, family_name].compact_blank.join(' ')
  end
end
