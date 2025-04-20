class BookingCancellationService
  def initialize(booking)
    @booking = booking
  end

  def cancel
    return false if @booking.cancelled?

    if Time.current - @booking.created_at <= 24.hours
      @booking.total_price = @booking.total_price * 0.95
    end

    @booking.status = :cancelled
    @booking.save
  end
end
