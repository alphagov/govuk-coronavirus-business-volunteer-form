# frozen_string_literal: true

class CoronavirusForm::OfferStaffTypeController < ApplicationController
  OPTIONS = I18n.t("coronavirus_form.questions.#{controller_name}.offer_staff_type.options")
  ALLOWED_VALUES = OPTIONS.map { |_, item| item.dig(:label) }
  DESCRIPTION_FIELDS = OPTIONS.map { |_, item| item.dig(:description, :id) }.freeze

  def submit
    @form_responses = {
      offer_staff_type: Array(params[:offer_staff_type]).map { |item| strip_tags(item).presence }.compact,
      offer_staff_number: {},
      offer_staff_description: strip_tags(params[:offer_staff_description]).presence,
      offer_staff_charge: strip_tags(params[:offer_staff_charge]).presence,
    }

    OPTIONS.map { |_, option| option[:description][:id].to_sym }.each do |field|
      next unless params[field]

      @form_responses[:offer_staff_number][field] = description(field, @form_responses[:offer_staff_type])
    end

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
      redirect_to expert_advice_type_url
    end
  end

private

  def update_session_store
    session[:offer_staff_type] = @form_responses[:offer_staff_type]
    session[:offer_staff_number] = @form_responses[:offer_staff_number]
    session[:offer_staff_description] = @form_responses[:offer_staff_description]
    session[:offer_staff_charge] = @form_responses[:offer_staff_charge]
  end

  def validate_fields
    [
      validate_checkbox_field("#{controller_name}.offer_staff_type", values: @form_responses[:offer_staff_type], allowed_values: ALLOWED_VALUES),
      validate_description_fields(@form_responses[:offer_staff_type]),
      validate_radio_field("#{controller_name}.offer_staff_charge", radio: @form_responses[:offer_staff_charge]),
    ].flatten.compact
  end

  def filter_options
    OPTIONS.map { |_, item| [item.dig(:description, :id), item.dig(:label)] }.to_h
  end

  def validate_description_fields(selected_options)
    errors = []
    filter_options.each do |field, label|
      if selected_options.include?(label) && @form_responses.dig(:offer_staff_number, field.to_sym).blank?
        field_name = field.gsub("_number", "")
        errors << {
          field: field,
          text: t("coronavirus_form.questions.#{controller_name}.offer_staff_type.options.#{field_name}.description.error_message"),
        }
      end
    end
    errors
  end

  def description(field, checkboxes)
    if selected_field?(field.to_s.gsub("_number", ""), checkboxes)
      strip_tags(params[field]).presence
    else
      ""
    end
  end

  def selected_field?(field, checkboxes)
    checkboxes.include?(
      I18n.t("coronavirus_form.questions.#{controller_name}.offer_staff_type.options.#{field}.label"),
    )
  end

  def previous_path
    offer_staff_url
  end
end
