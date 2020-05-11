# frozen_string_literal: true

class CoronavirusForm::AdditionalProductController < ApplicationController
  def submit
    @form_responses = {
      additional_product: strip_tags(params[:additional_product]).presence,
    }

    invalid_fields = validate_radio_field(
      controller_name,
      radio: @form_responses[:additional_product],
    )

    if invalid_fields.any?
      flash.now[:validation] = invalid_fields
      log_validation_error(invalid_fields)
      render controller_path, status: :unprocessable_entity
    elsif @form_responses[:additional_product] == I18n.t("coronavirus_form.questions.additional_product.options.option_yes.label")
      update_session_store
      redirect_to medical_equipment_type_url
    elsif session["check_answers_seen"]
      update_session_store
      redirect_to check_your_answers_url
    else
      update_session_store
      redirect_to accommodation_url
    end
  end

private

  def update_session_store
    session[:additional_product] = @form_responses[:additional_product]
  end

  def previous_path
    session["product_details"] ||= []
    latest_product_id = (session["product_details"].last || {}).dig("product_id")
    product_details_url(product_id: latest_product_id)
  end
end
