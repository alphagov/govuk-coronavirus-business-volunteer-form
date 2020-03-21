# frozen_string_literal: true

class CoronavirusForm::ExpertAdviceController < ApplicationController
  include ActionView::Helpers::SanitizeHelper
  include FieldValidationHelper

  def show
    session[:expert_advice] ||= []
    render "coronavirus_form/#{PAGE}"
  end

  def submit
    expert_advice = Array(params[:expert_advice]).map { |item| sanitize(item).presence }.compact
    expert_advice_other = sanitize(params[:expert_advice_other]).presence
    session[:expert_advice] = expert_advice
    session[:expert_advice_other] = if selected_other?(expert_advice)
                                      expert_advice_other
                                    else
                                      ""
                                    end
    invalid_fields = validate_checkbox_field(
      PAGE,
      values: expert_advice,
      allowed_values: I18n.t("coronavirus_form.#{PAGE}.options").map { |_, item| item.dig(:label) },
      other: expert_advice_other,
    )

    if invalid_fields.any?
      flash.now[:validation] = invalid_fields
      render "coronavirus_form/#{PAGE}"
    else
      redirect_to controller: session["check_answers_seen"] ? "coronavirus_form/check_answers" : "coronavirus_form/#{NEXT_PAGE}", action: "show"
    end
  end

private

  PAGE = "expert_advice"
  NEXT_PAGE = "offer_care"

  def selected_other?(expert_advice)
    expert_advice.include?(
      I18n.t("coronavirus_form.expert_advice.options.other.label"),
    )
  end

  def previous_path
    "/coronavirus-form/offer-space"
  end
end
