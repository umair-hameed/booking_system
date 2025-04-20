class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
  has_many :bookings, dependent: :destroy

  enum role: { customer: 0, admin: 1 }

  validates :name, :email, :role, presence: true
  validates :email, uniqueness: true

  def active_booking_for(room)
    bookings.find_by(room: room, status: [:pending, :confirmed])
  end
end
