# frozen_string_literal: true

class CoronavirusForm::OfferTransportController < ApplicationController
  def submit
    @form_responses = {
      offer_transport: strip_tags(params[:offer_transport]).presence,
    }

    invalid_fields = validate_radio_field(
      controller_name,
      radio: @form_responses[:offer_transport],
    )

    if invalid_fields.any?
      flash.now[:validation] = invalid_fields
      log_validation_error(invalid_fields)
      render controller_path, status: :unprocessable_entity
    elsif @form_responses[:offer_transport] == I18n.t("coronavirus_form.questions.#{controller_name}.options.option_yes.label")
      update_session_store
      redirect_to transport_type_url
    elsif session["check_answers_seen"]
      update_session_store
      redirect_to check_your_answers_url
    elsif @form_responses[:offer_transport] == I18n.t("coronavirus_form.questions.#{controller_name}.options.option_no.label")
      update_session_store
      redirect_to offer_space_url
    end
  end

private

  def update_session_store
    session[:offer_transport] = @form_responses[:offer_transport]

    if @form_responses[:offer_transport] == I18n.t("coronavirus_form.questions.#{controller_name}.options.option_no.label")
      session[:transport_cost] = nil
    end
  end

  def previous_path
    accommodation_url
  end
end
