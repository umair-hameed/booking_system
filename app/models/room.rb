class Room < ApplicationRecord
  has_many :bookings

  validates :name, :capacity, :price_per_hour, presence: true
  validates :price_per_hour, numericality: { greater_than_or_equal_to: 0 }

  scope :active, -> { where(active: true) }
end
