# frozen_string_literal: true

class CoronavirusForm::HotelRoomsNumberController < ApplicationController
  REQUIRED_FIELDS = %w(hotel_rooms_number).freeze

  def submit
    hotel_rooms_number = strip_tags(params[:hotel_rooms_number]).presence
    session[:hotel_rooms_number] = hotel_rooms_number

    invalid_fields = validate_mandatory_text_fields(controller_name, REQUIRED_FIELDS)

    if invalid_fields.any?
      flash.now[:validation] = invalid_fields
      render controller_path
    elsif session["check_answers_seen"]
      redirect_to check_your_answers_url
    else
      redirect_to offer_transport_url
    end
  end

private

  def previous_path
    hotel_rooms_path
  end
end
