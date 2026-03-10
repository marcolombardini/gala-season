class Event < ApplicationRecord
  belongs_to :organization

  has_many :attendances, dependent: :destroy
  has_many :attendees, through: :attendances, source: :user

  enum :dress_code, {
    black_tie: 0,
    black_tie_optional: 1,
    cocktail_attire: 2,
    business_casual: 3,
    formal: 4,
    corporate: 5,
    corporate_festive: 6,
    festive: 7,
    festive_black_tie: 8
  }

  enum :status, { draft: 0, published: 1 }

  scope :published, -> { where(status: :published) }
  scope :upcoming, -> { where(date: Date.current..) }

  validates :title, presence: true
  validates :date, presence: true
end
