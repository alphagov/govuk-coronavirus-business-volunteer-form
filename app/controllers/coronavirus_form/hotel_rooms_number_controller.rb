# frozen_string_literal: true

class CoronavirusForm::HotelRoomsNumberController < ApplicationController
  REQUIRED_FIELDS = %w[hotel_rooms_number].freeze

  def submit
    @form_responses = {
      hotel_rooms_number: strip_tags(params[:hotel_rooms_number]).presence,
    }

    invalid_fields = validate_mandatory_text_fields(controller_name, REQUIRED_FIELDS)

    if invalid_fields.any?
      flash.now[:validation] = invalid_fields
      render controller_path, status: :unprocessable_entity
    elsif session["check_answers_seen"]
      update_session_store
      redirect_to check_your_answers_url
    else
      update_session_store
      redirect_to offer_transport_url
    end
  end

private

  def update_session_store
    session[:hotel_rooms_number] = @form_responses[:hotel_rooms_number]
  end

  def previous_path
    hotel_rooms_path
  end
end
