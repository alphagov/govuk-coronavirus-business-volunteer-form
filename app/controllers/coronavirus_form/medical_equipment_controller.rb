# frozen_string_literal: true

class CoronavirusForm::MedicalEquipmentController < ApplicationController
  skip_before_action :check_first_question_answered

  def submit
    @form_responses = {
      medical_equipment: strip_tags(params[:medical_equipment]).presence,
    }

    invalid_fields = validate_radio_field(
      controller_name,
      radio: @form_responses[:medical_equipment],
    )

    if invalid_fields.any?
      flash.now[:validation] = invalid_fields
      log_validation_error(invalid_fields)
      render controller_path
    elsif session["check_answers_seen"]
      update_session_store
      redirect_to check_your_answers_url
    elsif @form_responses[:medical_equipment] == I18n.t("coronavirus_form.questions.#{controller_name}.options.option_yes.label")
      update_session_store
      redirect_to are_you_a_manufacturer_url
    elsif @form_responses[:medical_equipment] == I18n.t("coronavirus_form.questions.#{controller_name}.options.option_no.label")
      update_session_store
      redirect_to hotel_rooms_url
    end
  end

private

  def update_session_store
    session[:medical_equipment] = @form_responses[:medical_equipment]
  end

  def previous_path
    "/"
  end
end
