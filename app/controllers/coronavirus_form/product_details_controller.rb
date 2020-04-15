# frozen_string_literal: true

class CoronavirusForm::ProductDetailsController < ApplicationController
  REQUIRED_FIELDS = %w(product_name certification_details).freeze
  TEXT_FIELDS = %w(product_name product_quantity product_cost certification_details product_postcode product_url lead_time).freeze

  def show
    session[:product_details] ||= []
    @product = find_product(params["product_id"], session[:product_details])
    super
  end

  def submit
    @product = current_product(params["product_id"], session[:product_details]).merge(sanitized_product(params))

    invalid_fields = validate_fields

    if invalid_fields.any?
      flash.now[:validation] = invalid_fields
      log_validation_error(invalid_fields)
      render controller_path
    elsif session["check_answers_seen"]
      add_product_to_session(@product)
      redirect_to check_your_answers_url
    else
      add_product_to_session(@product)
      redirect_to additional_product_url
    end
  end

  def destroy
    remove_product_from_session(params[:id])
    redirect_to check_your_answers_url
  end

private

  helper_method :selected_ppe?

  def selected_ppe?
    @product[:medical_equipment_type] == I18n.t(
      "coronavirus_form.questions.medical_equipment_type.options.number_ppe.label",
    )
  end

  def selected_made_in_uk?
    @product[:product_location] == I18n.t(
      "coronavirus_form.questions.product_details.product_location.options.option_uk.label",
    )
  end

  def validate_fields
    [
      validate_field_response_length(controller_name, TEXT_FIELDS),
      validate_missing_fields,
      selected_ppe? ? validate_radio_field("#{controller_name}.equipment_type", radio: @product[:equipment_type]) : [],
      validate_radio_field("#{controller_name}.product_location", radio: @product[:product_location]),
      validate_product_postcode,
      validate_product_quantity,
      validate_product_cost,
      validate_lead_time,
    ].compact.flatten
  end

  def validate_product_postcode
    return [] unless selected_made_in_uk?

    if @product[:product_postcode].blank?
      return [{
        field: "product_postcode",
        text: t("coronavirus_form.questions.#{controller_name}.product_location.options.option_uk.input.custom_error"),
      }]
    end

    validate_postcode("product_postcode", @product[:product_postcode])
  end

  def validate_missing_fields
    required = []
    required.concat REQUIRED_FIELDS
    required.each_with_object([]) do |field, invalid_fields|
      next if @product[field.to_sym].present?

      invalid_fields << error_response(field)
    end
  end

  def validate_product_quantity
    field = "product_quantity"
    return error_response(field) unless @product[field.to_sym]

    quantity = Integer(@product[field.to_sym])
    return if quantity && quantity.positive?

    error_response(field)
  rescue ArgumentError
    error_response(field)
  end

  def validate_product_cost
    field = "product_cost"
    return error_response(field) unless @product[field.to_sym]

    cost = Float(@product[field.to_sym])
    return if cost && (cost.positive? || cost.zero?)

    error_response(field)
  rescue ArgumentError
    error_response(field)
  end

  def validate_lead_time
    field = "lead_time"
    return error_response(field) unless @product[field.to_sym]

    days = Integer(@product[field.to_sym])
    return if days && (days.positive? || days.zero?)

    error_response(field)
  rescue ArgumentError
    error_response(field)
  end

  def sanitized_product(params)
    {
      product_id: strip_tags(params[:product_id]).presence || SecureRandom.uuid,
      equipment_type: strip_tags(params[:equipment_type]).presence,
      product_name: strip_tags(params[:product_name]).presence,
      product_quantity: strip_tags(params[:product_quantity]&.gsub(",", "")&.strip).presence,
      product_cost: strip_tags(params[:product_cost]&.gsub(/[,£a-zA-Z]/, "")&.strip).presence,
      certification_details: strip_tags(params[:certification_details]).presence,
      product_location: strip_tags(params[:product_location]).presence,
      product_postcode: strip_tags(params[:product_postcode]&.gsub(/[[:space:]]+/, "")).presence,
      product_url: strip_tags(params[:product_url]).presence,
      lead_time: strip_tags(params[:lead_time]&.gsub(/[,a-zA-Z]/, "")&.strip).presence,
    }
  end

  def error_response(field)
    {
      field: field,
      text: t("coronavirus_form.questions.#{controller_name}.#{field}.custom_error",
              default: t("coronavirus_form.errors.missing_mandatory_text_field",
                         field: t("coronavirus_form.questions.#{controller_name}.#{field}.label")).humanize),
    }
  end

  def previous_path
    return check_your_answers_url if session["check_answers_seen"]

    medical_equipment_type_url
  end
end
