class User < ApplicationRecord
  has_many :bookings, dependent: :destroy

  enum role: { customer: 0, admin: 1 }

  validates :name, :email, :role, presence: true
  validates :email, uniqueness: true
end
