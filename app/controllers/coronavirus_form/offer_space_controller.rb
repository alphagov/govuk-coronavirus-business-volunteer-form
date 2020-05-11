# frozen_string_literal: true

class CoronavirusForm::OfferSpaceController < ApplicationController
  def submit
    @form_responses = {
      offer_space: strip_tags(params[:offer_space]).presence,
    }

    invalid_fields = validate_radio_field(controller_name, radio: @form_responses[:offer_space])

    if invalid_fields.any?
      flash.now[:validation] = invalid_fields
      log_validation_error(invalid_fields)
      render controller_path, status: :unprocessable_entity
    elsif @form_responses[:offer_space].eql? I18n.t("coronavirus_form.questions.#{controller_name}.options.option_yes.label")
      update_session_store
      redirect_to offer_space_type_url
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
    session[:offer_space] = @form_responses[:offer_space]

    if @form_responses[:offer_space] == I18n.t("coronavirus_form.questions.#{controller_name}.options.option_no.label")
      session[:space_cost] = nil
    end
  end

  def previous_path
    offer_transport_url
  end
end
