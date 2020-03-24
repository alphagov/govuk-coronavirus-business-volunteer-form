# frozen_string_literal: true

class CoronavirusForm::MedicalEquipmentTypeController < ApplicationController
  include ActionView::Helpers::SanitizeHelper
  include FieldValidationHelper
  include FormFlowHelper
  include ProductHelper

  before_action :check_first_question_answered, only: :show

  def show
    session[:product_details] ||= []
    @product = find_product(params["product_id"], session[:product_details])
    render "coronavirus_form/#{PAGE}"
  end

  def submit
    session[:product_details] ||= []
    @product = sanitized_product(params)
    add_product_to_session(@product)

    invalid_fields = validate_radio_field(
      PAGE,
      radio: @product["medical_equipment_type"],
      other: @product["medical_equipment_type_other"],
    )

    if invalid_fields.any?
      flash.now[:validation] = invalid_fields
      render "coronavirus_form/#{PAGE}"
    elsif session["check_answers_seen"]
      redirect_to controller: "coronavirus_form/check_answers", action: "show"
    else
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

  def selected_other?(medical_equipment_type)
    medical_equipment_type == I18n.t("coronavirus_form.questions.#{PAGE}.options.other.label")
  end

  def previous_path
    are_you_a_manufacturer_path
  end

  def sanitized_product(params)
    {
      "product_id" => sanitize(params[:product_id]).presence || SecureRandom.uuid,
      "medical_equipment_type" => sanitize(params[:medical_equipment_type]).presence,
      "medical_equipment_type_other" => sanitize(params[:medical_equipment_type_other]).presence,
    }
  end
end
