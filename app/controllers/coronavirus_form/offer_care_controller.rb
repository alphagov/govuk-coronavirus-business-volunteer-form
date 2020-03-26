# frozen_string_literal: true

class CoronavirusForm::OfferCareController < ApplicationController
  before_action :check_first_question_answered, only: :show

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
    elsif session[:offer_care] == I18n.t("coronavirus_form.questions.#{PAGE}.options.option_yes.label")
      redirect_to controller: "coronavirus_form/offer_care_qualifications", action: "show"
    elsif session["check_answers_seen"]
      redirect_to controller: "coronavirus_form/check_answers", action: "show"
    else
      redirect_to controller: "coronavirus_form/#{NEXT_PAGE}", action: "show"
    end
  end

private

  PAGE = "offer_care"
  NEXT_PAGE = "offer_other_support"

  def previous_path
    expert_advice_path
  end
end
