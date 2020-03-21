# frozen_string_literal: true

class CoronavirusForm::OfferCommunitySupportController < ApplicationController
  include ActionView::Helpers::SanitizeHelper
  include FieldValidationHelper

  def show
    render "coronavirus_form/#{PAGE}"
  end

  def submit
    offer_community_support = sanitize(params[:offer_community_support]).presence
    session[:offer_community_support] = offer_community_support

    invalid_fields = validate_radio_field(
      PAGE,
      radio: offer_community_support,
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

  PAGE = "offer_community_support"
  NEXT_PAGE = "thank_you"

  def previous_path
    coronavirus_form_offer_care_path
  end
end
