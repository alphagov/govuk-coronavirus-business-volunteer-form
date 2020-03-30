# frozen_string_literal: true

class CoronavirusForm::BusinessDetailsController < ApplicationController
  REQUIRED_FIELDS = %w(company_name).freeze
  TEXT_FIELDS = %w(company_name company_number).freeze

  def submit
    @business_details = sanitized_business_details(params)
    session[:business_details] = @business_details

    invalid_fields = validate_field_response_length(controller_name, TEXT_FIELDS) +
      validate_fields(@business_details)

    if invalid_fields.any?
      flash.now[:validation] = invalid_fields
      render controller_path
    elsif session["check_answers_seen"]
      redirect_to check_your_answers_path
    else
      redirect_to contact_details_path
    end
  end

private

  def validate_fields(business_details)
    missing_fields = validate_mandatory_text_fields(controller_name, REQUIRED_FIELDS)
    company_size_validation = validate_radio_field("#{controller_name}.company_size", radio: business_details["company_size"])
    company_location_validation = validate_radio_field("#{controller_name}.company_location", radio: business_details["company_location"])
    missing_fields + company_size_validation + company_location_validation
  end

  def sanitized_business_details(params)
    {
      "company_name" => strip_tags(params[:company_name]).presence,
      "company_number" => strip_tags(params[:company_number]).presence,
      "company_size" => strip_tags(params[:company_size]).presence,
      "company_location" => strip_tags(params[:company_location]).presence,
    }
  end

  def previous_path
    location_path
  end
end
