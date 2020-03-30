# frozen_string_literal: true

class CoronavirusForm::OfferCareQualificationsController < ApplicationController
  TEXT_FIELDS = %w(offer_care_qualifications_type).freeze

  def submit
    offer_care_qualifications = Array(params[:offer_care_qualifications]).map { |item| strip_tags(item).presence }.compact
    offer_care_qualifications_type = strip_tags(params[:offer_care_qualifications_type]).presence

    session[:offer_care_qualifications] = offer_care_qualifications
    session[:offer_care_qualifications_type] = offer_care_qualifications_type

    invalid_fields = validate_field_response_length(controller_name, TEXT_FIELDS) +
      validate_checkbox_field(
        controller_name,
        values: offer_care_qualifications,
        allowed_values: I18n.t("coronavirus_form.questions.#{controller_name}.options").map { |_, item| item.dig(:label) },
        other: offer_care_qualifications_type,
        other_field: "nursing_or_healthcare_qualification",
      )

    if invalid_fields.any?
      flash.now[:validation] = invalid_fields
      render controller_path
    elsif session["check_answers_seen"]
      redirect_to check_your_answers_path
    else
      redirect_to offer_other_support_path
    end
  end

private

  def previous_path
    offer_care_path
  end
end
