# frozen_string_literal: true

class CoronavirusForm::ExpertAdviceTypeController < ApplicationController
  TEXT_FIELDS = %w(expert_advice_type_other).freeze

  def submit
    expert_advice_type = Array(params[:expert_advice_type]).map { |item| strip_tags(item).presence }.compact
    expert_advice_type_other = strip_tags(params[:expert_advice_type_other]).presence
    session[:expert_advice_type] = expert_advice_type
    session[:expert_advice_type_other] = if selected_other?(expert_advice_type)
                                           expert_advice_type_other
                                         else
                                           ""
                                         end

    invalid_fields = validate_field_response_length(controller_name, TEXT_FIELDS) +
      validate_checkbox_field(
        controller_name,
        values: expert_advice_type,
        allowed_values: I18n.t("coronavirus_form.questions.#{controller_name}.options").map { |_, item| item.dig(:label) },
        other: expert_advice_type_other,
      )

    if invalid_fields.any?
      flash.now[:validation] = invalid_fields
      log_validation_error(invalid_fields)
      render controller_path
    elsif session["check_answers_seen"]
      redirect_to check_your_answers_url
    else
      redirect_to offer_care_url
    end
  end

private

  def selected_other?(expert_advice_type)
    expert_advice_type.include?(
      I18n.t("coronavirus_form.questions.#{controller_name}.options.other.label"),
    )
  end

  def previous_path
    offer_space_url
  end
end
