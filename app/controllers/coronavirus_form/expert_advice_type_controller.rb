# frozen_string_literal: true

class CoronavirusForm::ExpertAdviceTypeController < ApplicationController
  TEXT_FIELDS = %w(expert_advice_type_other).freeze

  def show
    session[:expert_advice_type] ||= []
    render "coronavirus_form/#{PAGE}"
  end

  def submit
    expert_advice_type = Array(params[:expert_advice_type]).map { |item| strip_tags(item).presence }.compact
    expert_advice_type_other = strip_tags(params[:expert_advice_type_other]).presence
    session[:expert_advice_type] = expert_advice_type
    session[:expert_advice_type_other] = if selected_other?(expert_advice_type)
                                           expert_advice_type_other
                                         else
                                           ""
                                         end

    invalid_fields = validate_field_response_length(PAGE, TEXT_FIELDS) +
      validate_checkbox_field(
        PAGE,
        values: expert_advice_type,
        allowed_values: ALLOWED_VALUES,
        other: expert_advice_type_other,
      )

    if invalid_fields.any?
      flash.now[:validation] = invalid_fields
      render "coronavirus_form/#{PAGE}"
    else
      redirect_to controller: session["check_answers_seen"] ? "coronavirus_form/check_answers" : "coronavirus_form/#{NEXT_PAGE}", action: "show"
    end
  end

private

  PAGE = "expert_advice_type"
  NEXT_PAGE = "offer_care"
  ALLOWED_VALUES = I18n.t("coronavirus_form.questions.#{PAGE}.options").map { |_, item| item.dig(:label) }
  OTHER = I18n.t("coronavirus_form.questions.#{PAGE}.options.other.label")

  def selected_other?(expert_advice_type)
    expert_advice_type.include?(OTHER)
  end

  def previous_path
    offer_space_path
  end
end
