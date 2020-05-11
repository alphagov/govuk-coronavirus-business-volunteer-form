# frozen_string_literal: true

class CoronavirusForm::RoomsNumberController < ApplicationController
  REQUIRED_FIELDS = %w[rooms_number].freeze

  def submit
    @form_responses = {
      rooms_number: strip_tags(params[:rooms_number]).presence,
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
    session[:rooms_number] = @form_responses[:rooms_number]
  end

  def previous_path
    accommodation_path
  end
end
