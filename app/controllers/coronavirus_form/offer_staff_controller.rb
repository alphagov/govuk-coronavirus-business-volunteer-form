# frozen_string_literal: true

class CoronavirusForm::OfferStaffController < ApplicationController
  def submit
    @form_responses = {
      offer_staff: strip_tags(params[:offer_staff]).presence,
    }

    invalid_fields = validate_radio_field(controller_name, radio: @form_responses[:offer_staff])

    if invalid_fields.any?
      flash.now[:validation] = invalid_fields
      log_validation_error(invalid_fields)
      render controller_path, status: :unprocessable_entity
    elsif @form_responses[:offer_staff].eql? I18n.t("coronavirus_form.questions.#{controller_name}.options.option_yes.label")
      update_session_store
      redirect_to offer_staff_type_url
    elsif session["check_answers_seen"]
      update_session_store
      redirect_to check_your_answers_url
    else
      update_session_store
      redirect_to expert_advice_type_url
    end
  end

private

  def update_session_store
    session[:offer_staff] = @form_responses[:offer_staff]
  end

  def previous_path
    offer_space_url
  end
end
