# frozen_string_literal: true

class CoronavirusForm::HotelRoomsController < ApplicationController
  def submit
    @form_responses = {
      hotel_rooms: strip_tags(params[:hotel_rooms]).presence,
    }

    invalid_fields = validate_radio_field(
      controller_name,
      radio: @form_responses[:hotel_rooms],
    )

    if invalid_fields.any?
      flash.now[:validation] = invalid_fields
      log_validation_error(invalid_fields)
      render controller_path, status: :unprocessable_entity
    elsif @form_responses[:hotel_rooms] == I18n.t("coronavirus_form.questions.hotel_rooms.options.yes_staying_in.label") ||
        @form_responses[:hotel_rooms] == I18n.t("coronavirus_form.questions.hotel_rooms.options.yes_all_uses.label")
      update_session_store
      redirect_to hotel_rooms_number_url
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
    session[:hotel_rooms] = @form_responses[:hotel_rooms]
  end

  def previous_path
    medical_equipment_url
  end
end
