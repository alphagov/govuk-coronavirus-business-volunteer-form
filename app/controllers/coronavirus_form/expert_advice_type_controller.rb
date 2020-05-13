# frozen_string_literal: true

class CoronavirusForm::ExpertAdviceTypeController < ApplicationController
  TEXT_FIELDS = %w[expert_advice_type_other].freeze

  def submit
    @form_responses = {
      expert_advice_type: Array(params[:expert_advice_type]).map { |item| strip_tags(item).presence }.compact,
    }
    @form_responses[:expert_advice_type_other] = strip_tags(params[:expert_advice_type_other]).presence if selected_other?

    invalid_fields = validate_field_response_length(controller_name, TEXT_FIELDS) +
      validate_checkbox_field(
        controller_name,
        values: @form_responses[:expert_advice_type],
        allowed_values: I18n.t("coronavirus_form.questions.#{controller_name}.options").map { |_, item| item.dig(:label) },
        other: @form_responses[:expert_advice_type_other],
      )

    if invalid_fields.any?
      flash.now[:validation] = invalid_fields
      log_validation_error(invalid_fields)
      render controller_path, status: :unprocessable_entity
    elsif session["check_answers_seen"]
      update_session_store
      redirect_to check_your_answers_url
    else
      update_session_store
      redirect_to offer_care_url
    end
  end

private

  def update_session_store
    session[:expert_advice_type] = @form_responses[:expert_advice_type]
    session[:expert_advice_type_other] = @form_responses[:expert_advice_type_other]
  end

  def selected_other?
    @form_responses[:expert_advice_type].include?(
      I18n.t("coronavirus_form.questions.#{controller_name}.options.other.label"),
    )
  end

  def previous_path
    offer_staff_url
  end
end
