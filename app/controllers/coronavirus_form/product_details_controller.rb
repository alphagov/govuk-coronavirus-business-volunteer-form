# frozen_string_literal: true

class CoronavirusForm::ProductDetailsController < ApplicationController
  before_action :check_first_question_answered, only: :show

  REQUIRED_FIELDS = %w(product_name product_quantity product_cost certification_details lead_time).freeze
  TEXT_FIELDS = %w(product_name product_quantity product_cost certification_details product_postcode product_url lead_time).freeze

  def show
    session["product_details"] ||= []
    @product = find_product(params["product_id"], session["product_details"])
    render "coronavirus_form/#{PAGE}"
  end

  def submit
    @product = current_product(params[:product_id], session[:product_details]).merge(sanitized_product(params))
    add_product_to_session(@product)

    invalid_fields = validate_field_response_length(PAGE, TEXT_FIELDS) + validate_fields(@product)

    if invalid_fields.any?
      flash.now[:validation] = invalid_fields
      render "coronavirus_form/#{PAGE}"
    else
      redirect_to controller: session["check_answers_seen"] ? "coronavirus_form/check_answers" : "coronavirus_form/#{NEXT_PAGE}", action: "show"
    end
  end

  def destroy
    remove_product_from_session(params[:id])
    redirect_to check_your_answers_path, action: "show"
  end

private

  NEXT_PAGE = "additional_product"
  PAGE = "product_details"
  PPE = I18n.t("coronavirus_form.questions.medical_equipment_type.options.number_ppe.label")
  UK = I18n.t("coronavirus_form.questions.product_details.product_location.options.option_uk.label")

  helper_method :selected_ppe?

  def selected_ppe?
    @product["medical_equipment_type"] == PPE
  end

  def selected_made_in_uk?
    @product["product_location"] == UK
  end

  def validate_fields(product)
    missing_fields = validate_missing_fields(product)
    product_equipment_type = selected_ppe? ? validate_radio_field("#{PAGE}.equipment_type", radio: product["equipment_type"]) : []
    product_location_validation = validate_radio_field("#{PAGE}.product_location", radio: product["product_location"])
    postcode_validation = validate_product_postcode(product)
    missing_fields + product_equipment_type + product_location_validation + postcode_validation
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
      "product_id" => strip_tags(params[:product_id]).presence || SecureRandom.uuid,
      "equipment_type" => strip_tags(params[:equipment_type]).presence,
      "product_name" => strip_tags(params[:product_name]).presence,
      "product_quantity" => strip_tags(params[:product_quantity]).presence,
      "product_cost" => strip_tags(params[:product_cost]).presence,
      "certification_details" => strip_tags(params[:certification_details]).presence,
      "product_location" => strip_tags(params[:product_location]).presence,
      "product_postcode" => strip_tags(params[:product_postcode]).presence,
      "product_url" => strip_tags(params[:product_url]).presence,
      "lead_time" => strip_tags(params[:lead_time]).presence,
    }
  end

  def previous_path
    return check_your_answers_path if session["check_answers_seen"]

    medical_equipment_type_path
  end
end
