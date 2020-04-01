# frozen_string_literal: true

class CoronavirusForm::AdditionalProductController < ApplicationController
  def submit
    additional_product = strip_tags(params[:additional_product]).presence

    invalid_fields = validate_radio_field(
      controller_name,
      radio: additional_product,
    )

    if invalid_fields.any?
      flash.now[:validation] = invalid_fields
      log_validation_error(invalid_fields)
      render controller_path
    elsif additional_product == I18n.t("coronavirus_form.questions.additional_product.options.option_yes.label")
      redirect_to medical_equipment_type_url
    elsif session["check_answers_seen"]
      redirect_to check_your_answers_url
    else
      redirect_to hotel_rooms_url
    end
  end

private

  def previous_path
    session["product_details"] ||= []
    latest_product_id = (session["product_details"].last || {}).dig("product_id")
    product_details_url(product_id: latest_product_id)
  end
end
