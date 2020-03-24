# frozen_string_literal: true

class CoronavirusForm::ProductDetailsController < ApplicationController
  include ActionView::Helpers::SanitizeHelper
  include FieldValidationHelper
  include FormFlowHelper
  include ProductHelper

  before_action :check_first_question_answered, only: :show

  REQUIRED_FIELDS = %w(product_name product_cost certification_details product_location lead_time).freeze

  def show
    session["product_details"] ||= []
    @product = find_product(params["product_id"], session["product_details"])
    render "coronavirus_form/#{PAGE}"
  end

  def submit
    @product = current_product(params[:product_id], session[:product_details]).merge(sanitized_product(params))
    add_product_to_session(@product)

    invalid_fields = validate_fields(@product)

    if invalid_fields.any?
      flash.now[:validation] = invalid_fields
      render "coronavirus_form/#{PAGE}"
    else
      redirect_to controller: session["check_answers_seen"] ? "coronavirus_form/check_answers" : "coronavirus_form/#{NEXT_PAGE}", action: "show"
    end
  end

private

  NEXT_PAGE = "additional_product"
  PAGE = "product_details"

  helper_method :selected_ppe?

  def selected_ppe?
    @product["medical_equipment_type"] == I18n.t(
      "coronavirus_form.questions.medical_equipment_type.options.number_ppe.label",
    )
  end

  def selected_made_in_uk?
    @product["product_location"] == I18n.t(
      "coronavirus_form.questions.product_details.product_location.options.option_uk.label",
    )
  end

  def validate_fields(product)
    missing_fields = validate_missing_fields(product)
    postcode_validation = validate_product_postcode(product)
    missing_fields + postcode_validation
  end

  def validate_product_postcode(product)
    return [] unless selected_made_in_uk?

    if product["product_postcode"].blank?
      return [{
        field: "product_postcode".to_s,
        text: t("coronavirus_form.questions.#{PAGE}.product_location.options.option_uk.input.custom_error"),
      }]
    end

    validate_postcode("product_postcode", product["product_postcode"])
  end

  def validate_missing_fields(product)
    required = []
    required.concat REQUIRED_FIELDS
    required << "equipment_type" if selected_ppe?
    required.each_with_object([]) do |field, invalid_fields|
      next if product[field].present?

      invalid_fields << {
        field: field.to_s,
        text: t("coronavirus_form.questions.#{PAGE}.#{field}.custom_error",
                default: t("coronavirus_form.errors.missing_mandatory_text_field",
                           field: t("coronavirus_form.questions.#{PAGE}.#{field}.label")).humanize),
      }
    end
  end

  def sanitized_product(params)
    {
      "product_id" => sanitize(params[:product_id]).presence || SecureRandom.uuid,
      "equipment_type" => sanitize(params[:equipment_type]).presence,
      "product_name" => sanitize(params[:product_name]).presence,
      "product_cost" => sanitize(params[:product_cost]).presence,
      "certification_details" => sanitize(params[:certification_details]).presence,
      "product_location" => sanitize(params[:product_location]).presence,
      "product_postcode" => sanitize(params[:product_postcode]).presence,
      "product_url" => sanitize(params[:product_url]).presence,
      "lead_time" => sanitize(params[:lead_time]).presence,
    }
  end

  def previous_path
    return additional_product_path if params["product_id"]

    return check_your_answers_path if session["check_answers_seen"]

    medical_equipment_type_path
  end
end
