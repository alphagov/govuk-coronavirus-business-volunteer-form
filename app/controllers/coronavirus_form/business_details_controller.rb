# frozen_string_literal: true

class CoronavirusForm::BusinessDetailsController < ApplicationController
  REQUIRED_FIELDS = %w[company_name company_is_uk_registered].freeze
  TEXT_FIELDS = %w[company_name company_number].freeze

  def submit
    @form_responses = {
      business_details: sanitized_business_details(params),
    }

    @form_responses[:business_details][:company_number] = "" if @form_responses[:business_details][:company_is_uk_registered] == I18n.t("coronavirus_form.questions.business_details.company_is_uk_registered.options.not_united_kingdom.label")

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
      redirect_to contact_details_url
    end
  end

private

  def update_session_store
    session[:business_details] = @form_responses[:business_details]
  end

  def validate_fields
    errors = []

    errors << validate_field_response_length(controller_name, TEXT_FIELDS)
    errors << validate_mandatory_text_fields(controller_name, REQUIRED_FIELDS)
    errors << validate_radio_field("#{controller_name}.company_size", radio: @form_responses.dig(:business_details, :company_size))
    errors << validate_radio_field("#{controller_name}.company_location", radio: @form_responses.dig(:business_details, :company_location))

    errors << if @form_responses[:business_details][:company_location] == I18n.t("coronavirus_form.questions.business_details.company_location.options.united_kingdom.label") &&
        @form_responses[:business_details][:company_postcode].blank?
                { field: "company_postcode",
                  text: t("coronavirus_form.questions.#{controller_name}.company_location.options.united_kingdom.input.custom_error") }
              elsif @form_responses[:business_details][:company_location] == I18n.t("coronavirus_form.questions.business_details.company_location.options.united_kingdom.label")
                validate_postcode("company_postcode", @form_responses[:business_details][:company_postcode])
              end

    errors << if @form_responses[:business_details][:company_is_uk_registered] == I18n.t("coronavirus_form.questions.business_details.company_is_uk_registered.options.united_kingdom.label") &&
        @form_responses[:business_details][:company_number].blank?
                { field: "company_number",
                  text: t("coronavirus_form.questions.#{controller_name}.company_is_uk_registered.options.united_kingdom.company_number.custom_error") }
              elsif @form_responses[:business_details][:company_is_uk_registered] == I18n.t("coronavirus_form.questions.business_details.company_is_uk_registered.options.united_kingdom.label")
                validate_company_number(controller_name, @form_responses[:business_details][:company_number])
              end

    errors.compact.flatten
  end

  def sanitized_business_details(params)
    {
      company_name: strip_tags(params[:company_name]).presence,
      company_is_uk_registered: strip_tags(params[:company_is_uk_registered]).presence,
      company_number: strip_tags(params[:company_number]).presence,
      company_size: strip_tags(params[:company_size]).presence,
      company_location: strip_tags(params[:company_location]).presence,
      company_postcode: strip_tags(params[:company_postcode]&.gsub(/[[:space:]]+/, "")).presence,
    }
  end

  def previous_path
    location_url
  end
end
