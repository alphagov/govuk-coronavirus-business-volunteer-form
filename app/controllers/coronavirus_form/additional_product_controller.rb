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
      render controller_path
    elsif additional_product == I18n.t("coronavirus_form.questions.additional_product.options.option_yes.label")
      redirect_to medical_equipment_type_path
    elsif session["check_answers_seen"]
      redirect_to check_your_answers_path
    else
      redirect_to hotel_rooms_path
    end
  end

private

  def previous_path
    session["product_details"] ||= []
    latest_product_id = (session["product_details"].last || {}).dig("product_id")
    "/product-details?product_id=#{latest_product_id}"
  end
end
