# frozen_string_literal: true

class CoronavirusForm::OfferOtherSupportController < ApplicationController
  TEXT_FIELDS = %w(offer_other_support).freeze

  def submit
    offer_other_support = strip_tags(params[:offer_other_support]).presence

    session[:offer_other_support] = offer_other_support

    invalid_fields = validate_field_response_length(controller_name, TEXT_FIELDS)

    if invalid_fields.any?
      flash.now[:validation] = invalid_fields
      render controller_path
    elsif session["check_answers_seen"]
      redirect_to check_your_answers_path
    else
      redirect_to location_path
    end
  end

private

  def previous_path
    offer_care_path
  end
end
