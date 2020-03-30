# frozen_string_literal: true

class CoronavirusForm::AreYouAManufacturerController < ApplicationController
  def submit
    are_you_a_manufacturer = Array(params[:are_you_a_manufacturer]).map { |item| strip_tags(item).presence }.compact
    session["are_you_a_manufacturer"] = are_you_a_manufacturer

    invalid_fields = validate_checkbox_field(
      controller_name,
      values: are_you_a_manufacturer,
      allowed_values: I18n.t("coronavirus_form.questions.#{controller_name}.options").map { |_, item| item.dig(:label) },
    )

    if invalid_fields.any?
      flash.now[:validation] = invalid_fields
      render controller_path
    elsif session["check_answers_seen"]
      redirect_to check_your_answers_path
    else
      redirect_to medical_equipment_type_path
    end
  end

private

  def previous_path
    medical_equipment_path
  end
end
