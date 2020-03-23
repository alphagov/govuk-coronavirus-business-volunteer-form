# frozen_string_literal: true

class CoronavirusForm::OfferTransportController < ApplicationController
  include ActionView::Helpers::SanitizeHelper
  include FieldValidationHelper

  def show
    render "coronavirus_form/#{PAGE}"
  end

  def submit
    offer_transport = sanitize(params[:offer_transport]).presence
    session[:offer_transport] = offer_transport

    invalid_fields = validate_radio_field(
      PAGE,
      radio: offer_transport,
    )

    if invalid_fields.any?
      flash.now[:validation] = invalid_fields
      render "coronavirus_form/#{PAGE}"
    elsif session["check_answers_seen"]
      redirect_to controller: "coronavirus_form/check_answers", action: "show"
    elsif session[:offer_transport] == I18n.t("coronavirus_form.#{PAGE}.options.option_yes.label")
      redirect_to controller: "coronavirus_form/transport_type", action: "show"
    elsif session[:offer_transport] == I18n.t("coronavirus_form.#{PAGE}.options.option_no.label")
      redirect_to controller: "coronavirus_form/offer_space", action: "show"
    end
  end

private

  PAGE = "offer_transport"

  def previous_path
    offer_transport_path
  end
end
