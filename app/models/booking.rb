class Booking < ApplicationRecord
  belongs_to :user
  belongs_to :room
  has_many :audit_logs, dependent: :destroy

  enum status: { pending: 0, confirmed: 1, cancelled: 2 }

  validates :start_time, :end_time, presence: true
  validate :non_overlapping_booking
  validate :valid_time_range

  before_save :calculate_total_price

  # after_create :log_creation
  # after_update :log_cancellation, if: -> { saved_change_to_status? && cancelled? }

  private

  def valid_time_range
    errors.add(:end_time, 'must be after start time') if end_time <= start_time
  end

  def non_overlapping_booking
    overlaps = Booking.where(room_id: room_id)
                      .where.not(id: id)
                      .where("start_time < ? AND end_time > ?", end_time, start_time)
    errors.add(:base, 'Room is already booked for this time') if overlaps.exists?
  end

  def calculate_total_price
    duration_hours = ((end_time - start_time) / 1.hour).ceil
    base_price = room.price_per_hour * duration_hours

    # Apply discount if booking exceeds 4 hours
    discount = duration_hours > 4 ? 0.10 * base_price : 0
    self.total_price = base_price - discount
  end

  # def log_creation
  #   audit_logs.create(action: "created", description: "Booking created", timestamp: Time.current)
  # end

  # def log_cancellation
  #   audit_logs.create(action: "cancelled", description: "Booking cancelled", timestamp: Time.current)
  # end
end
