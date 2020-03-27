# frozen_string_literal: true

class CoronavirusForm::MedicalEquipmentTypeController < ApplicationController
  before_action :check_first_question_answered, only: :show

  TEXT_FIELDS = %w(medical_equipment_type_other).freeze

  def show
    session[:product_details] ||= []
    @product = find_product(params["product_id"], session[:product_details])
    render "coronavirus_form/#{PAGE}"
  end

  def submit
    session[:product_details] ||= []
    @product = sanitized_product(params)

    invalid_fields = validate_field_response_length(PAGE, TEXT_FIELDS) +
      validate_radio_field(
        PAGE,
        radio: @product["medical_equipment_type"],
        other: @product["medical_equipment_type_other"],
      )

    if invalid_fields.any?
      flash.now[:validation] = invalid_fields
      render "coronavirus_form/#{PAGE}"
    else
      add_product_to_session(@product)
      redirect_to(
        controller: "coronavirus_form/#{NEXT_PAGE}",
        action: "show",
        params: { product_id: @product["product_id"] },
      )
    end
  end

private

  PAGE = "medical_equipment_type"
  NEXT_PAGE = "product_details"
  OTHER = I18n.t("coronavirus_form.questions.#{PAGE}.options.other.label")

  def selected_other?(medical_equipment_type)
    medical_equipment_type == OTHER
  end

  def previous_path
    session[:product_details].empty? ? are_you_a_manufacturer_path : additional_product_path
  end

  def sanitized_product(params)
    {
      "product_id" => strip_tags(params[:product_id]).presence || SecureRandom.uuid,
      "medical_equipment_type" => strip_tags(params[:medical_equipment_type]).presence,
      "medical_equipment_type_other" => strip_tags(params[:medical_equipment_type_other]).presence,
    }
  end
end
