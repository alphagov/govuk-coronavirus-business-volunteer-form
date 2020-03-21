# frozen_string_literal: true

class BusinessVolunteering::MedicalEquipmentController < ApplicationController
  include ActionView::Helpers::SanitizeHelper
  include FieldValidationHelper

  def show
    render "business_volunteering/#{PAGE}"
  end

  def submit
    medical_equipment = sanitize(params[:medical_equipment]).presence

    session[:medical_equipment] = medical_equipment

    invalid_fields = validate_radio_field(
      PAGE,
      radio: medical_equipment,
    )

    if invalid_fields.any?
      flash.now[:validation] = invalid_fields
      render "business_volunteering/#{PAGE}"
    elsif session["check_answers_seen"]
      redirect_to controller: "business_volunteering/check_answers", action: "show"
    elsif session[:medical_equipment] == I18n.t("business_volunteering.medical_equipment.options.option_yes.label")
      redirect_to controller: "business_volunteering/medical_equipment_type", action: "show"
    else
      redirect_to controller: "business_volunteering/hotel_rooms", action: "show"
    end
  end

private

  PAGE = "medical_equipment"

  def previous_path
    "/"
  end
end
