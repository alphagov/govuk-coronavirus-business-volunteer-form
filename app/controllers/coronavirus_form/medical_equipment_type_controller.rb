# frozen_string_literal: true

class CoronavirusForm::MedicalEquipmentTypeController < ApplicationController
  include ActionView::Helpers::SanitizeHelper
  include FieldValidationHelper
  include FormFlowHelper

  before_action :check_first_question_answered, only: :show

  def show
    render "coronavirus_form/#{PAGE}"
  end

  def submit
    medical_equipment_type = sanitize(params[:medical_equipment_type]).presence
    medical_equipment_type_other = sanitize(params[:medical_equipment_type_other]).presence
    session[:medical_equipment_type] = medical_equipment_type
    session[:medical_equipment_type_other] = medical_equipment_type_other
    invalid_fields = validate_radio_field(
      PAGE,
      radio: medical_equipment_type,
      other: medical_equipment_type_other,
    )

    if invalid_fields.any?
      flash.now[:validation] = invalid_fields
      render "coronavirus_form/#{PAGE}"
    else
      redirect_to controller: session["check_answers_seen"] ? "coronavirus_form/check_answers" : "coronavirus_form/#{NEXT_PAGE}", action: "show"
    end
  end

private

  PAGE = "medical_equipment_type"
  NEXT_PAGE = "product_details"

  def selected_other?(medical_equipment_type)
    medical_equipment_type == I18n.t("coronavirus_form.#{PAGE}.options.other.label")
  end

  def previous_path
    are_you_a_manufacturer_path
  end
end
