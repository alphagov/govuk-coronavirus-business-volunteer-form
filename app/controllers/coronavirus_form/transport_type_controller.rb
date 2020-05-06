# frozen_string_literal: true

class CoronavirusForm::TransportTypeController < ApplicationController
  REQUIRED_FIELDS = %w[transport_description].freeze
  TEXT_FIELDS = %w[transport_description].freeze

  def submit
    @form_responses = {
      transport_type: Array(params[:transport_type]).map { |item| strip_tags(item).presence }.compact,
      transport_description: params[:transport_description],
      transport_cost: strip_tags(params[:transport_cost]).presence,
    }

    invalid_fields = validate_checkbox_field(
      controller_name,
      values: @form_responses[:transport_type],
      allowed_values: I18n.t("coronavirus_form.questions.#{controller_name}.options").map { |_, item| item.dig(:label) },
    ) +
      validate_mandatory_text_fields(controller_name, REQUIRED_FIELDS) +
      validate_field_response_length(controller_name, TEXT_FIELDS)

    if invalid_fields.any?
      flash.now[:validation] = invalid_fields
      log_validation_error(invalid_fields)
      render controller_path, status: :unprocessable_entity
    elsif session["check_answers_seen"]
      update_session_store
      redirect_to check_your_answers_url
    else
      update_session_store
      redirect_to offer_space_url
    end
  end

private

  def update_session_store
    session[:transport_type] = @form_responses[:transport_type]
    session[:transport_description] = @form_responses[:transport_description]
    session[:transport_cost] = @form_responses[:transport_cost]
  end

  def previous_path
    offer_transport_url
  end
end
