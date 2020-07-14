# frozen_string_literal: true

class CoronavirusForm::OfferCareController < ApplicationController
  def submit
    @form_responses = {
      offer_care: strip_tags(params[:offer_care]).presence,
    }

    invalid_fields = validate_radio_field(
      controller_name,
      radio: @form_responses[:offer_care],
    )

    if invalid_fields.any?
      flash.now[:validation] = invalid_fields
      log_validation_error(invalid_fields)
      render controller_path, status: :unprocessable_entity
    elsif @form_responses[:offer_care] == I18n.t("coronavirus_form.questions.#{controller_name}.options.option_yes.label")
      update_session_store
      redirect_to offer_care_qualifications_url
    elsif session["check_answers_seen"]
      update_session_store
      redirect_to check_your_answers_url
    else
      update_session_store
      redirect_to offer_other_support_url
    end
  end

private

  def update_session_store
    session[:offer_care] = @form_responses[:offer_care]

    if @form_responses[:offer_care] == I18n.t("coronavirus_form.questions.#{controller_name}.options.option_no.label")
      session[:offer_care_type] = nil
      session[:offer_care_qualifications] = nil
      session[:offer_care_qualifications_type] = nil
      session[:care_cost] = nil
    end
  end

  def previous_path
    if session[:expert_advice_type]&.include?(I18n.t("coronavirus_form.questions.expert_advice_type.options.it.label"))
      it_services_path
    elsif session[:expert_advice_type]&.include?(I18n.t("coronavirus_form.questions.expert_advice_type.options.construction.label"))
      construction_services_path
    else
      expert_advice_type_path
    end
  end
end
