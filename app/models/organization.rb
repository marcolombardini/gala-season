class Organization < ApplicationRecord
  has_secure_password

  has_many :events, dependent: :destroy
  has_many :follows, dependent: :destroy
  has_many :followers, through: :follows, source: :user

  validates :name, presence: true
  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :slug, presence: true, uniqueness: true

  before_validation :generate_slug, on: :create

  private

  def generate_slug
    return if name.blank?

    base = name.parameterize
    self.slug = base
    counter = 1
    while Organization.exists?(slug: slug)
      self.slug = "#{base}-#{counter}"
      counter += 1
    end
  end
end
