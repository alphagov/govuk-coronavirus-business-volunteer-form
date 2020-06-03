# frozen_string_literal: true

class CoronavirusForm::ConstructionServicesController < ApplicationController
  TEXT_FIELDS = %w[construction_services_other].freeze

  def submit
    @form_responses = {
      construction_services: Array(params[:construction_services]).map { |item| strip_tags(item).presence }.compact,
      construction_cost: strip_tags(params[:construction_cost]).presence,
    }
    @form_responses[:construction_services_other] = strip_tags(params[:construction_services_other]).presence

    invalid_fields =
      [
        validate_checkbox_field(
          controller_name,
          values: @form_responses[:construction_services],
          allowed_values: I18n.t("coronavirus_form.questions.#{controller_name}.options").map { |_, item| item.dig(:label) },
        ),
        validate_field_response_length(controller_name, TEXT_FIELDS),
        validate_charge_field("construction_cost", @form_responses[:construction_cost]),
      ].flatten.compact

    if invalid_fields.any?
      flash.now[:validation] = invalid_fields
      log_validation_error(invalid_fields)
      render controller_path, status: :unprocessable_entity
    else
      update_session_store
      redirect_to polymorphic_url(next_page)
    end
  end

private

  def update_session_store
    session[:construction_services] = @form_responses[:construction_services]
    session[:construction_services_other] = @form_responses[:construction_services_other]
    session[:construction_cost] = @form_responses[:construction_cost]
  end

  def previous_path
    expert_advice_type_url
  end

  def next_page
    return "it_services" if it_services?
    return "check_your_answers" if session["check_answers_seen"]

    "offer_care"
  end

  def it_services?
    session[:it_services].blank? &&
      session[:expert_advice_type]&.include?(
        I18n.t("coronavirus_form.questions.expert_advice_type.options.it.label"),
      )
  end
end
