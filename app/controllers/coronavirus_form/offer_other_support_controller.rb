# frozen_string_literal: true

class CoronavirusForm::OfferOtherSupportController < ApplicationController
  TEXT_FIELDS = %w[offer_other_support].freeze

  def submit
    @form_responses = {
      offer_other_support: strip_tags(params[:offer_other_support]).presence,
    }

    invalid_fields = validate_field_response_length(controller_name, TEXT_FIELDS)

    if invalid_fields.any?
      flash.now[:validation] = invalid_fields
      log_validation_error(invalid_fields)
      render controller_path, status: :unprocessable_entity
    elsif session["check_answers_seen"]
      update_session_store
      redirect_to check_your_answers_url
    else
      update_session_store
      redirect_to location_url
    end
  end

private

  def update_session_store
    session[:offer_other_support] = @form_responses[:offer_other_support]
  end

  def previous_path
    offer_care_url
  end
end
