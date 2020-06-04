# frozen_string_literal: true

class CoronavirusForm::ItServicesController < ApplicationController
  TEXT_FIELDS = %w[it_services_other].freeze

  def submit
    @form_responses = {
      it_services: Array(params[:it_services]).map { |item| strip_tags(item).presence }.compact,
      it_services_other: strip_tags(params[:it_services_other]).presence,
      it_cost: strip_tags(params[:it_cost]).presence,
    }

    invalid_fields =
      [
        validate_checkbox_field(
          controller_name,
          values: @form_responses[:it_services],
          allowed_values: I18n.t("coronavirus_form.questions.#{controller_name}.options").map { |_, item| item.dig(:label) },
        ),
        validate_field_response_length(controller_name, TEXT_FIELDS),
        validate_charge_field("it_cost", @form_responses[:it_cost]),
      ].flatten.compact

    if invalid_fields.any?
      flash.now[:validation] = invalid_fields
      log_validation_error(invalid_fields)
      render controller_path, status: :unprocessable_entity
    elsif session["check_answers_seen"]
      update_session_store
      redirect_to check_your_answers_url
    else
      update_session_store
      redirect_to offer_care_url
    end
  end

private

  def update_session_store
    session[:it_services] = @form_responses[:it_services]
    session[:it_services_other] = @form_responses[:it_services_other]
    session[:it_cost] = @form_responses[:it_cost]
  end

  def previous_path
    if session[:expert_advice_type]&.include?(I18n.t("coronavirus_form.questions.expert_advice_type.options.construction.label"))
      construction_services_path
    else
      expert_advice_type_path
    end
  end
end
