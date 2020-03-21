# frozen_string_literal: true

module FieldValidationHelper
  def validate_mandatory_text_fields(mandatory_fields, page)
    invalid_fields = []
    mandatory_fields.each do |field|
      next if session[field].present?

      invalid_fields << { field: field.to_s,
                          text: t("business_volunteering.#{page}.#{field}.custom_error",
                                  default: t("business_volunteering.errors.missing_mandatory_text_field", field: t("business_volunteering.#{page}.#{field}.label")).humanize) }
    end
    invalid_fields
  end

  def validate_radio_field(page, radio:, other: false)
    if radio.blank?
      return [{ field: page.to_s,
                text: t(
                  "business_volunteering.#{page}.custom_select_error",
                  default: t("business_volunteering.errors.radio_field", field: t("business_volunteering.#{page}.title")).humanize,
                ) }]
    end

    if other != false && other.blank? && %w[Yes Other].include?(radio)
      return [{ field: page.to_s,
                text: t(
                  "business_volunteering.#{page}.custom_enter_error",
                  default: t("business_volunteering.errors.missing_mandatory_text_field", field: t("business_volunteering.#{page}.title")).humanize,
                ) }]
    end

    []
  end

  def validate_checkbox_field(page, values:, allowed_values:)
    if values.blank? || values.empty?
      return [{ field: page.to_s,
                text: t(
                  "business_volunteering.#{page}.custom_select_error",
                  default: t("business_volunteering.errors.checkbox_field", field: t("business_volunteering.#{page}.title")).humanize,
                ) }]
    end

    if (values - allowed_values).any?
      return [{ field: page.to_s,
                text: t(
                  "business_volunteering.#{page}.custom_select_error",
                  default: t("business_volunteering.errors.missing_mandatory_text_field", field: t("business_volunteering.#{page}.title")).humanize,
                ) }]
    end

    []
  end

  def validate_email_address(field, email_address)
    if email_address =~ /@/
      []
    else
      [{ field: field.to_s, text: t("business_volunteering.errors.email_format") }]
    end
  end

  def validate_postcode(field, postcode)
    if postcode =~ /^(([A-Z]{1,2}[0-9][A-Z0-9]?|ASCN|STHL|TDCU|BBND|[BFS]IQQ|PCRN|TKCA) ?[0-9][A-Z]{2}|BFPO ?[0-9]{1,4}|(KY[0-9]|MSR|VG|AI)[ -]?[0-9]{4}|[A-Z]{2} ?[0-9]{2}|GE ?CX|GIR ?0A{2}|SAN ?TA1)$/i
      []
    else
      [{ field: field.to_s, text: t("business_volunteering.errors.postcode_format") }]
    end
  end
end
