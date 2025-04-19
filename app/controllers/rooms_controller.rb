class RoomsController < ApplicationController
  before_action :authenticate_user!
  before_action :authorize_admin!, except: [:index, :show]
  before_action :set_room, only: [:show, :edit, :update, :destroy]

  def index
    if current_user.admin?
      @rooms = Room.all
    else
      @rooms = Room.active
    end
  end

  def show; end
  def new
    @room = Room.new
  end

  def create
    @room = Room.new(room_params)

    if @room.save
      redirect_to @room, notice: 'Room was successfully created.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit; end

  def update
    if @room.update(room_params)
      redirect_to @room, notice: 'Room was successfully updated.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    if @room.bookings.exists?
      redirect_to rooms_path, alert: 'Cannot delete room with existing bookings.'
    else
      @room.destroy
      redirect_to rooms_path, notice: 'Room was successfully deleted.'
    end
  end

  private

  def set_room
    @room = Room.find(params[:id])
  end

  def room_params
    params.require(:room).permit(:name, :capacity, :price_per_hour, :active)
  end

  def authorize_admin!
    unless current_user.admin?
      redirect_to rooms_path, alert: 'You are not authorized to perform this action.'
    end
  end
end
