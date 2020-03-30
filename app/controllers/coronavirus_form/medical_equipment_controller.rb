# frozen_string_literal: true

class CoronavirusForm::MedicalEquipmentController < ApplicationController
  skip_before_action :check_first_question_answered

  def submit
    medical_equipment = strip_tags(params[:medical_equipment]).presence

    session[:medical_equipment] = medical_equipment

    invalid_fields = validate_radio_field(
      controller_name,
      radio: medical_equipment,
    )

    if invalid_fields.any?
      flash.now[:validation] = invalid_fields
      render controller_path
    elsif session["check_answers_seen"]
      redirect_to check_your_answers_path
    elsif session[:medical_equipment] == I18n.t("coronavirus_form.questions.#{controller_name}.options.option_yes.label")
      # YES goes to what kind of business are you / are_you_a_manufacturer
      redirect_to are_you_a_manufacturer_path
    elsif session[:medical_equipment] == I18n.t("coronavirus_form.questions.#{controller_name}.options.option_no.label")
      # NO goes to hotel rooms
      redirect_to hotel_rooms_path
    else
      render controller_path
    end
  end

private

  def previous_path
    "/"
  end
end
