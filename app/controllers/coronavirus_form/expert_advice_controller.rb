# frozen_string_literal: true

class CoronavirusForm::ExpertAdviceController < ApplicationController
  include ActionView::Helpers::SanitizeHelper
  include FieldValidationHelper
  include FormFlowHelper

  before_action :check_first_question_answered, only: :show

  def show
    session[:expert_advice] ||= ""
    render "coronavirus_form/#{PAGE}"
  end

  def submit
    session[:expert_advice] ||= ""
    session[:expert_advice] = sanitize(params[:expert_advice]).presence

    invalid_fields = validate_radio_field(
      PAGE,
      radio: session[:expert_advice],
    )

    if invalid_fields.any?
      flash.now[:validation] = invalid_fields
      render "coronavirus_form/#{PAGE}"
    elsif session["check_answers_seen"]
      redirect_to controller: "coronavirus_form/check_answers", action: "show"
    elsif session[:expert_advice] == "Yes"
      redirect_to controller: "coronavirus_form/expert_advice_type", action: "show"
    elsif session[:expert_advice] == "No"
      redirect_to controller: "coronavirus_form/offer_care", action: "show"
    else
      redirect_to controller: "coronavirus_form/", action: "show"
    end
  end

private

  PAGE = "expert_advice"

  def previous_path
    offer_space_path
  end
end
