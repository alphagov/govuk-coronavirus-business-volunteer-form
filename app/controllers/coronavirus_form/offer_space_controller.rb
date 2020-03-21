# frozen_string_literal: true

class CoronavirusForm::OfferSpaceController < ApplicationController
  include ActionView::Helpers::SanitizeHelper
  include FieldValidationHelper

  def show
    render "coronavirus_form/#{PAGE}"
  end

  def submit
    offer_space = sanitize(params[:offer_space]).presence
    session[:offer_space] = offer_space

    invalid_fields = validate_radio_field(
      PAGE,
      radio: offer_space,
    )

    if invalid_fields.any?
      flash.now[:validation] = invalid_fields
      render "coronavirus_form/#{PAGE}"
    elsif session["check_answers_seen"]
      redirect_to controller: "coronavirus_form/check_answers", action: "show"
    elsif offer_space.eql? "Yes"
      redirect_to controller: "coronavirus_form/offer_space_type", action: "show"
    else
      redirect_to controller: "coronavirus_form/expert_advice", action: "show"
    end
  end

private

  PAGE = "offer_space"

  def previous_path
    coronavirus_form_offer_transport_path
  end
end
