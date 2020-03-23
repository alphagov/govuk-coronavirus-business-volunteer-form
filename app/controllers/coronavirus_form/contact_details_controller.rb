# frozen_string_literal: true

class CoronavirusForm::ContactDetailsController < ApplicationController
  include ActionView::Helpers::SanitizeHelper
  include FieldValidationHelper

  REQUIRED_FIELDS = %w(name phone_number email).freeze

  def show
    session[:contact_details] ||= {}
    render "coronavirus_form/#{PAGE}"
  end

  def submit
    session[:contact_details] ||= {}
    session[:contact_details]["name"] = sanitize(params[:name]).presence
    session[:contact_details]["role"] = sanitize(params[:role]).presence
    session[:contact_details]["phone_number"] = sanitize(params[:phone_number]).presence
    session[:contact_details]["email"] = sanitize(params[:email]).presence

    invalid_fields = validate_fields(session[:contact_details])

    if invalid_fields.any?
      flash.now[:validation] = invalid_fields
      render "coronavirus_form/#{PAGE}"
    else
      redirect_to controller: "coronavirus_form/check_answers", action: "show"
    end
  end

private

  PAGE = "contact_details"

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
        text: t("coronavirus_form.#{PAGE}.#{field}.custom_error",
                default: t("coronavirus_form.errors.missing_mandatory_text_field",
                           field: t("coronavirus_form.#{PAGE}.#{field}.label")).humanize),
      }
    end
  end

  def previous_path
    business_details_path
  end
end
