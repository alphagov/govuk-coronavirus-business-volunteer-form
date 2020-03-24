# frozen_string_literal: true

class CoronavirusForm::AreYouAManufacturerController < ApplicationController
  include ActionView::Helpers::SanitizeHelper
  include FieldValidationHelper
  include FormFlowHelper

  before_action :check_first_question_answered, only: :show

  def show
    session["are_you_a_manufacturer"] ||= []
    render "coronavirus_form/#{PAGE}"
  end

  def submit
    are_you_a_manufacturer = Array(params[:are_you_a_manufacturer]).map { |item| sanitize(item).presence }.compact
    session["are_you_a_manufacturer"] = are_you_a_manufacturer

    invalid_fields = validate_checkbox_field(
      PAGE,
      values: are_you_a_manufacturer,
      allowed_values: I18n.t("coronavirus_form.questions.#{PAGE}.options").map { |_, item| item.dig(:label) },
    )

    if invalid_fields.any?
      flash.now[:validation] = invalid_fields
      render "coronavirus_form/#{PAGE}"
    elsif session["check_answers_seen"]
      redirect_to controller: "coronavirus_form/check_answers", action: "show"
    else
      redirect_to controller: "coronavirus_form/medical_equipment_type", action: "show"
    end
  end

private

  PAGE = "are_you_a_manufacturer"

  def previous_path
    medical_equipment_path
  end
end
