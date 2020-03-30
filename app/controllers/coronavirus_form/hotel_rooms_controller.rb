# frozen_string_literal: true

class CoronavirusForm::HotelRoomsController < ApplicationController
  def submit
    hotel_rooms = strip_tags(params[:hotel_rooms]).presence
    session[:hotel_rooms] = hotel_rooms

    invalid_fields = validate_radio_field(
      controller_name,
      radio: hotel_rooms,
    )

    if invalid_fields.any?
      flash.now[:validation] = invalid_fields
      render controller_path
    elsif session["check_answers_seen"]
      redirect_to check_your_answers_path
    else
      redirect_to offer_transport_path
    end
  end

private

  def previous_path
    medical_equipment_path
  end
end
