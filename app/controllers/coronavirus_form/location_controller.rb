# frozen_string_literal: true

class CoronavirusForm::LocationController < ApplicationController
  def submit
    @form_responses = {
      location: Array(params[:location]).map { |item| strip_tags(item).presence }.compact,
    }

    invalid_fields = validate_checkbox_field(
      controller_name,
      values: @form_responses[:location],
      allowed_values: I18n.t("coronavirus_form.questions.#{controller_name}.options").map { |_, item| item.dig(:label) },
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
      redirect_to business_details_url
    end
  end

private

  def update_session_store
    session[:location] = @form_responses[:location]
  end

  def previous_path
    offer_other_support_url
  end
end
