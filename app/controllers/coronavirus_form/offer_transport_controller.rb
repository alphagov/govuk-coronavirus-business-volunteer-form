# frozen_string_literal: true

class CoronavirusForm::OfferTransportController < ApplicationController
  before_action :check_first_question_answered, only: :show

  def show
    render "coronavirus_form/#{PAGE}"
  end

  def submit
    offer_transport = strip_tags(params[:offer_transport]).presence
    session[:offer_transport] = offer_transport

    invalid_fields = validate_radio_field(
      PAGE,
      radio: offer_transport,
    )

    if invalid_fields.any?
      flash.now[:validation] = invalid_fields
      render "coronavirus_form/#{PAGE}"
    elsif session[:offer_transport] == YES
      redirect_to controller: "coronavirus_form/transport_type", action: "show"
    elsif session["check_answers_seen"]
      redirect_to controller: "coronavirus_form/check_answers", action: "show"
    elsif session[:offer_transport] == NO
      redirect_to controller: "coronavirus_form/offer_space", action: "show"
    end
  end

private

  PAGE = "offer_transport"
  YES = I18n.t("coronavirus_form.questions.#{PAGE}.options.option_yes.label")
  NO = I18n.t("coronavirus_form.questions.#{PAGE}.options.option_no.label")

  def previous_path
    hotel_rooms_path
  end
end
