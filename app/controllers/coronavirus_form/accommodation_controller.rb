# frozen_string_literal: true

class CoronavirusForm::AccommodationController < ApplicationController
  def submit
    @form_responses = {
      accommodation: strip_tags(params[:accommodation]).presence,
    }

    invalid_fields = validate_radio_field(
      controller_name,
      radio: @form_responses[:accommodation],
    )

    if invalid_fields.any?
      flash.now[:validation] = invalid_fields
      log_validation_error(invalid_fields)
      render controller_path, status: :unprocessable_entity
    elsif @form_responses[:accommodation] == I18n.t("coronavirus_form.questions.accommodation.options.yes_staying_in.label") ||
        @form_responses[:accommodation] == I18n.t("coronavirus_form.questions.accommodation.options.yes_all_uses.label")
      update_session_store
      redirect_to rooms_number_url
    elsif session["check_answers_seen"]
      update_session_store
      redirect_to check_your_answers_url
    else
      update_session_store
      redirect_to offer_transport_url
    end
  end

private

  def update_session_store
    session[:accommodation] = @form_responses[:accommodation]

    if @form_responses[:accommodation] == I18n.t("coronavirus_form.questions.#{controller_name}.options.no_option.label")
      session[:accommodation_cost] = nil
    end
  end

  def previous_path
    medical_equipment_url
  end
end
