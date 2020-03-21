# frozen_string_literal: true

class CoronavirusForm::OfferCareController < ApplicationController
  include ActionView::Helpers::SanitizeHelper
  include FieldValidationHelper

  def show
    render "coronavirus_form/#{PAGE}"
  end

  def submit
    offer_care = sanitize(params[:offer_care]).presence
    session[:offer_care] = offer_care

    invalid_fields = validate_radio_field(
      PAGE,
      radio: offer_care,
    )

    if invalid_fields.any?
      flash.now[:validation] = invalid_fields
      render "coronavirus_form/#{PAGE}"
    elsif session["check_answers_seen"]
      redirect_to controller: "coronavirus_form/check_answers", action: "show"
    else
      redirect_to controller: "coronavirus_form/#{NEXT_PAGE}", action: "show"
    end
  end

private

  PAGE = "offer_care"
  NEXT_PAGE = "thank_you"

  def previous_path
    coronavirus_form_expert_advice_path
  end
end
