# frozen_string_literal: true

class CoronavirusForm::TransportTypeController < ApplicationController
  REQUIRED_FIELDS = %w(transport_description).freeze
  TEXT_FIELDS = %w(transport_description).freeze

  def submit
    transport_type = Array(params[:transport_type]).map { |item| strip_tags(item).presence }.compact

    session[:transport_type] = transport_type
    session[:transport_description] = params[:transport_description]

    invalid_fields = validate_checkbox_field(
      controller_name,
      values: transport_type,
      allowed_values: I18n.t("coronavirus_form.questions.#{controller_name}.options").map { |_, item| item.dig(:label) },
                      ) +
      validate_mandatory_text_fields(controller_name, REQUIRED_FIELDS) +
      validate_field_response_length(controller_name, TEXT_FIELDS)

    if invalid_fields.any?
      flash.now[:validation] = invalid_fields
      render controller_path
    elsif session["check_answers_seen"]
      redirect_to check_your_answers_url
    else
      redirect_to offer_space_url
    end
  end

private

  def previous_path
    offer_transport_url
  end
end
