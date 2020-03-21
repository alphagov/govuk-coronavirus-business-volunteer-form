# frozen_string_literal: true

class BusinessVolunteering::HotelRoomsController < ApplicationController
  include ActionView::Helpers::SanitizeHelper
  include FieldValidationHelper

  def show
    render "business_volunteering/#{PAGE}"
  end

  def submit
    hotel_rooms = sanitize(params[:hotel_rooms]).presence
    session[:hotel_rooms] = hotel_rooms

    invalid_fields = validate_radio_field(
      PAGE,
      radio: hotel_rooms,
    )

    if invalid_fields.any?
      flash.now[:validation] = invalid_fields
      render "business_volunteering/#{PAGE}"
    elsif session["check_answers_seen"]
      redirect_to controller: "business_volunteering/check_answers", action: "show"
    else
      redirect_to controller: "business_volunteering/offer_food", action: "show"
    end
  end

private

  PAGE = "hotel_rooms"

  def previous_path
    business_volunteering_do_you_have_medical_equipment_to_offer_path
  end
end
