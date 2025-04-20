class MultipleRoomBookingService
  def initialize(user:, room_ids:, booking_times:)
    @user = user
    @room_ids = room_ids.map(&:to_i)
    @booking_times = booking_times.to_unsafe_h
    @parsed_times = {}
  end

  def call
    return error("You can only book up to 3 rooms.") if @room_ids.size > 3

    selected_times = @booking_times.slice(*@room_ids.map(&:to_s))

    @room_ids.each do |room_id|
      times = selected_times[room_id.to_s]
      start_time = parse_time(times["start_time"])
      end_time = parse_time(times["end_time"])
      room = Room.find_by(id: room_id)

      return error("Start and end times are required for each selected room.") if start_time.blank? || end_time.blank?
      return error("End time must be after start time for Room ##{room&.name || room_id}.") if end_time <= start_time

      @parsed_times[room_id] = { start_time: start_time, end_time: end_time }
    end

    # Step 2: Transactionally create bookings
    ActiveRecord::Base.transaction do
      @room_ids.each do |room_id|
        room = Room.active.find_by(id: room_id)
        raise ActiveRecord::Rollback, "Room ##{room_id} is not available." unless room

        times = @parsed_times[room_id]

        booking = Booking.create!(
          user: @user,
          room: room,
          start_time: times[:start_time],
          end_time: times[:end_time],
        )

        booking.audit_logs.create!(
          action: "created",
          description: "Booking created via multiple room form",
          timestamp: Time.current
        )
      end
    end

    { success: true }
  rescue => e
    error("Booking failed: #{e.message}")
  end

  private

  def parse_time(raw)
    Time.zone.parse(raw) rescue nil
  end

  def error(message)
    { success: false, error: message }
  end
end
