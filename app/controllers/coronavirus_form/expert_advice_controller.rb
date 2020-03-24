# frozen_string_literal: true

class CoronavirusForm::ExpertAdviceController < ApplicationController
  include ActionView::Helpers::SanitizeHelper
  include FieldValidationHelper
  include FormFlowHelper

  before_action :check_first_question_answered, only: :show

  def show
    render "coronavirus_form/#{PAGE}"
  end

  def submit
    expert_advice = sanitize(params[:expert_advice]).presence
    session[:expert_advice] = expert_advice

    invalid_fields = validate_radio_field(
      PAGE,
      radio: expert_advice,
    )

    if invalid_fields.any?
      flash.now[:validation] = invalid_fields
      render "coronavirus_form/#{PAGE}"
    elsif session[:expert_advice] == I18n.t("coronavirus_form.questions.#{PAGE}.options.option_yes.label")
      redirect_to controller: "coronavirus_form/expert_advice_type", action: "show"
    elsif session["check_answers_seen"]
      redirect_to controller: "coronavirus_form/check_answers", action: "show"
    else
      redirect_to controller: "coronavirus_form/offer_care", action: "show"
    end
  end

private

  PAGE = "expert_advice"

  def previous_path
    offer_space_path
  end
end
