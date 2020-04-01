# frozen_string_literal: true

class CoronavirusForm::OfferCareController < ApplicationController
  def submit
    offer_care = strip_tags(params[:offer_care]).presence
    session[:offer_care] = offer_care

    invalid_fields = validate_radio_field(
      controller_name,
      radio: offer_care,
    )

    if invalid_fields.any?
      flash.now[:validation] = invalid_fields
      render controller_path
    elsif session[:offer_care] == I18n.t("coronavirus_form.questions.#{controller_name}.options.option_yes.label")
      redirect_to offer_care_qualifications_url
    elsif session["check_answers_seen"]
      redirect_to check_your_answers_url
    else
      redirect_to offer_other_support_url
    end
  end

private

  def previous_path
    expert_advice_type_url
  end
end
