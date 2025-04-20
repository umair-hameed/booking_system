class BookingsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_booking, only: [:show, :cancel, :confirm, :edit, :update]
  # before_action :set_booking, only: [:show, :edit, :update, :destroy, :cancel]

  before_action :authorize_booking!, only: []
  # before_action :authorize_booking!, only: [:show, :edit, :update, :destroy, :cancel]

  def index
    @bookings = current_user.admin? ? Booking.all : current_user.bookings
    @bookings = @bookings.includes(:room, :user).order(start_time: :desc)
  end

  def show; end

  def new
    @booking = Booking.new
    @booking.room_id = params[:room_id] if params[:room_id]
    @room = Room.find_by(id: params[:room_id]) if params[:room_id]
  end

  def create
    @booking = current_user.bookings.new(booking_params)
    @room = Room.find_by(id: booking_params[:room_id]) if booking_params[:room_id]

    if @booking.save
      redirect_to @booking, notice: 'Booking was successfully created.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @room = @booking.room
  end

  def update
    if @booking.update(booking_params)
      redirect_to @booking, notice: "Booking updated successfully."
    else
      flash.now[:alert] = "There was an error updating the booking."
      render :edit, status: :unprocessable_entity
    end
  end

  def cancel
    if @booking.user == current_user || current_user.admin?
      if BookingCancellationService.new(@booking).cancel
        redirect_to bookings_path, notice: "Booking cancelled successfully."
      else
        redirect_to bookings_path, alert: "Unable to cancel booking."
      end
    else
      redirect_to bookings_path, alert: "You are not authorized to cancel this booking."
    end
  end

  def confirm
    if current_user.admin?
      if @booking.pending?
        @booking.update(status: :confirmed)
        redirect_to bookings_path, notice: "Booking confirmed successfully."
      else
        redirect_to bookings_path, alert: "Only pending bookings can be confirmed."
      end
    else
      redirect_to bookings_path, alert: "You are not authorized to confirm this booking."
    end
  end


  private

  def set_booking
    @booking = Booking.find(params[:id])

  rescue ActiveRecord::RecordNotFound
    # head(:not_found) if @event_file.nil?
    redirect_back(fallback_location: bookings_path, alert: "Booking not found.")
  end

  def booking_params
    params.require(:booking).permit(:room_id, :start_time, :end_time)
  end

  def authorize_booking!
    unless current_user.admin? || @booking.user == current_user
      redirect_to bookings_path, alert: 'You are not authorized to view this booking.'
    end
  end
end
