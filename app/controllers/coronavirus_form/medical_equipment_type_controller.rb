# frozen_string_literal: true

class CoronavirusForm::MedicalEquipmentTypeController < ApplicationController
  def submit
    @form_responses = {
      medical_equipment_type: strip_tags(params[:medical_equipment_type]).presence,
    }

    invalid_fields = validate_radio_field(
      controller_name,
      radio: @form_responses[:medical_equipment_type],
    )

    if invalid_fields.any?
      flash.now[:validation] = invalid_fields
      log_validation_error(invalid_fields)
      render controller_path, status: :unprocessable_entity
    elsif selected_testing_equipment?
      update_session_store
      redirect_to testing_equipment_url
    else
      update_session_store
      redirect_to coordination_centres_url
    end
  end

private

  def selected_testing_equipment?
    @form_responses[:medical_equipment_type] == I18n.t(
      "coronavirus_form.questions.medical_equipment_type.options.number_testing_equipment.label",
    )
  end

  def update_session_store
    session[:medical_equipment_type] = @form_responses[:medical_equipment_type]
  end

  def previous_path
    medical_equipment_url
  end
end
