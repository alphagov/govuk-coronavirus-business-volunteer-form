# frozen_string_literal: true

class CoronavirusForm::ContactDetailsController < ApplicationController
  REQUIRED_FIELDS = %w(contact_name phone_number).freeze
  TEXT_FIELDS = %w(contact_name role phone_number email).freeze

  def show
    session[:contact_details] ||= {}
    super
  end

  def submit
    session[:contact_details] ||= {}
    session[:contact_details]["contact_name"] = strip_tags(params[:contact_name]).presence
    session[:contact_details]["role"] = strip_tags(params[:role]).presence
    session[:contact_details]["phone_number"] = strip_tags(params[:phone_number]).presence
    session[:contact_details]["email"] = strip_tags(params[:email]).presence

    invalid_fields = validate_field_response_length(controller_name, TEXT_FIELDS) +
      validate_fields(session[:contact_details])

    if invalid_fields.any?
      flash.now[:validation] = invalid_fields
      render controller_path
    else
      redirect_to check_your_answers_path
    end
  end

private

  def validate_fields(contact_details)
    missing_fields = validate_missing_fields(contact_details)
    email_validation = validate_email_address("email", contact_details["email"])
    missing_fields + email_validation
  end

  def validate_missing_fields(product)
    REQUIRED_FIELDS.each_with_object([]) do |field, invalid_fields|
      next if product[field].present?

      invalid_fields << {
        field: field.to_s,
        text: t("coronavirus_form.questions.#{controller_name}.#{field}.custom_error",
                default: t("coronavirus_form.errors.missing_mandatory_text_field",
                           field: t("coronavirus_form.questions.#{controller_name}.#{field}.label")).humanize),
      }
    end
  end

  def previous_path
    business_details_path
  end
end
