# frozen_string_literal: true

class CoronavirusForm::MedicalEquipmentTypeController < ApplicationController
  TEXT_FIELDS = %w[medical_equipment_type_other].freeze

  def show
    session[:product_details] ||= []
    @product = find_product(params["product_id"], session[:product_details])
    super
  end

  def submit
    session[:product_details] ||= []
    @product = sanitized_product(params)

    invalid_fields = validate_field_response_length(controller_name, TEXT_FIELDS) +
      validate_radio_field(
        controller_name,
        radio: @product[:medical_equipment_type],
        other: @product[:medical_equipment_type_other],
      )

    if invalid_fields.any?
      flash.now[:validation] = invalid_fields
      log_validation_error(invalid_fields)
      render controller_path, status: :unprocessable_entity
    elsif selected_testing_equipment?
      add_product_to_session(@product)
      redirect_to testing_equipment_url
    else
      add_product_to_session(@product)
      redirect_to product_details_url(product_id: @product[:product_id])
    end
  end

private

  def selected_other?(medical_equipment_type)
    medical_equipment_type == I18n.t("coronavirus_form.questions.#{controller_name}.options.other.label")
  end

  def selected_testing_equipment?
    @product[:medical_equipment_type] == I18n.t(
      "coronavirus_form.questions.medical_equipment_type.options.number_testing_equipment.label",
    )
  end

  def previous_path
    session[:product_details].empty? ? are_you_a_manufacturer_url : additional_product_url
  end

  def sanitized_product(params)
    {
      product_id: strip_tags(params[:product_id]).presence || SecureRandom.uuid,
      medical_equipment_type: strip_tags(params[:medical_equipment_type]).presence,
      medical_equipment_type_other: strip_tags(params[:medical_equipment_type_other]).presence,
    }
  end
end
