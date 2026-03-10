class User < ApplicationRecord
  has_secure_password

  has_many :attendances, dependent: :destroy
  has_many :attended_events, through: :attendances, source: :event
  has_many :follows, dependent: :destroy
  has_many :followed_organizations, through: :follows, source: :organization

  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :username, presence: true, uniqueness: true
end
