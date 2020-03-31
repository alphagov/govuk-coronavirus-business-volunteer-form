# frozen_string_literal: true

class CoronavirusForm::OfferTransportController < ApplicationController
  def submit
    offer_transport = strip_tags(params[:offer_transport]).presence
    session[:offer_transport] = offer_transport

    invalid_fields = validate_radio_field(
      controller_name,
      radio: offer_transport,
    )

    if invalid_fields.any?
      flash.now[:validation] = invalid_fields
      render controller_path
    elsif session[:offer_transport] == I18n.t("coronavirus_form.questions.#{controller_name}.options.option_yes.label")
      redirect_to transport_type_url
    elsif session["check_answers_seen"]
      redirect_to check_your_answers_url
    elsif session[:offer_transport] == I18n.t("coronavirus_form.questions.#{controller_name}.options.option_no.label")
      redirect_to offer_space_url
    end
  end

private

  def previous_path
    hotel_rooms_url
  end
end
