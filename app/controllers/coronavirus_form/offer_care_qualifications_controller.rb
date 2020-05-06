# frozen_string_literal: true

class CoronavirusForm::OfferCareQualificationsController < ApplicationController
  TEXT_FIELDS = %w[offer_care_qualifications_type].freeze

  def submit
    @form_responses = {
      offer_care_type: Array(params[:offer_care_type]).map { |item| strip_tags(item).presence }.compact,
      offer_care_qualifications: Array(params[:offer_care_qualifications]).map { |item| strip_tags(item).presence }.compact,
      offer_care_qualifications_type: strip_tags(params[:offer_care_qualifications_type]).presence,
      care_cost: strip_tags(params[:care_cost]).presence,
    }

    invalid_fields = validate_fields

    if invalid_fields.any?
      flash.now[:validation] = invalid_fields
      log_validation_error(invalid_fields)
      render controller_path, status: :unprocessable_entity
    elsif session["check_answers_seen"]
      update_session_store
      redirect_to check_your_answers_url
    else
      update_session_store
      redirect_to offer_other_support_url
    end
  end

private

  def validate_fields
    [
      validate_field_response_length("#{controller_name}.care_qualifcations", TEXT_FIELDS),
      validate_missing_offer_care_type_fields,
      validate_missing_offer_care_qualifications_fields,
      validate_selecting_of_offer_care_qualifications_fields,
      validate_charge_field("care_cost", @form_responses[:care_cost]),
    ].flatten.compact
  end

  def validate_missing_offer_care_type_fields
    validate_checkbox_field(
      "#{controller_name}.offer_care_type",
      values: @form_responses[:offer_care_type],
      allowed_values: I18n.t("coronavirus_form.questions.#{controller_name}.offer_care_type.options").map { |_, item| item.dig(:label) },
    )
  end

  def validate_missing_offer_care_qualifications_fields
    validate_checkbox_field(
      "#{controller_name}.care_qualifications",
      values: @form_responses[:offer_care_qualifications],
      allowed_values: I18n.t("coronavirus_form.questions.#{controller_name}.care_qualifications.options").map { |_, item| item.dig(:label) },
      other: @form_responses[:offer_care_qualifications_type],
      other_field: "nursing_or_healthcare_qualification",
    )
  end

  def validate_selecting_of_offer_care_qualifications_fields
    validate_qualification_or_not("#{controller_name}.care_qualifications", values: @form_responses[:offer_care_qualifications])
  end

  def validate_qualification_or_not(page, values:)
    if values.length > 1 && values.include?(t("coronavirus_form.questions.#{page}.options.no_qualification.label"))
      [{ field: page.to_s.sub(".", "_"),
         text: t(
           "coronavirus_form.questions.#{page}.custom_select_error_qualification_or_not",
         ) }]
    else
      []
    end
  end

  def update_session_store
    session[:offer_care_type] = @form_responses[:offer_care_type]
    session[:offer_care_qualifications] = @form_responses[:offer_care_qualifications]
    session[:offer_care_qualifications_type] = @form_responses[:offer_care_qualifications_type]
    session[:care_cost] = @form_responses[:care_cost]
  end

  def previous_path
    offer_care_url
  end
end
