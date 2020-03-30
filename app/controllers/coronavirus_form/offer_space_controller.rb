# frozen_string_literal: true

class CoronavirusForm::OfferSpaceController < ApplicationController
  def submit
    offer_space = strip_tags(params[:offer_space]).presence
    session[:offer_space] = offer_space

    invalid_fields = validate_radio_field(controller_name, radio: offer_space)

    if invalid_fields.any?
      flash.now[:validation] = invalid_fields
      render controller_path
    elsif offer_space.eql? "Yes"
      redirect_to offer_space_type_path
    elsif session["check_answers_seen"]
      redirect_to check_your_answers_path
    else
      redirect_to expert_advice_type_path
    end
  end

private

  def previous_path
    offer_transport_path
  end
end
