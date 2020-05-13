# frozen_string_literal: true

class CoronavirusForm::ContactDetailsController < ApplicationController
  REQUIRED_FIELDS = %w[contact_name phone_number].freeze
  TEXT_FIELDS = %w[contact_name role phone_number email].freeze

  def submit
    @form_responses = {
      contact_details: {
        contact_name: strip_tags(params[:contact_name]).presence,
        role: strip_tags(params[:role]).presence,
        phone_number: strip_tags(params[:phone_number]).presence,
        email: strip_tags(params[:email]).presence,
      },
    }

    invalid_fields = validate_fields

    if invalid_fields.any?
      flash.now[:validation] = invalid_fields
      log_validation_error(invalid_fields)
      render controller_path, status: :unprocessable_entity
    else
      session[:contact_details] = @form_responses[:contact_details]
      redirect_to check_your_answers_url
    end
  end

private

  def validate_fields
    [
      validate_field_response_length(controller_name, TEXT_FIELDS),
      validate_missing_fields,
      validate_email_address("email", @form_responses.dig(:contact_details, :email)),
    ].flatten.compact
  end

  def validate_missing_fields
    REQUIRED_FIELDS.each_with_object([]) do |field, invalid_fields|
      next if @form_responses[:contact_details][field.to_sym].present?

      invalid_fields << {
        field: field,
        text: t(
          "coronavirus_form.questions.#{controller_name}.#{field}.custom_error",
          default: t(
            "coronavirus_form.errors.missing_mandatory_text_field",
            field: t("coronavirus_form.questions.#{controller_name}.#{field}.label"),
          ).humanize,
        ),
      }
    end
  end

  def previous_path
    business_details_url
  end
end
