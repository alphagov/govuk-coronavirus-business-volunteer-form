# frozen_string_literal: true

class CoronavirusForm::AdditionalProductController < ApplicationController
  include ActionView::Helpers::SanitizeHelper
  include FieldValidationHelper
  include FormFlowHelper

  before_action :check_first_question_answered, only: :show

  def show
    render "coronavirus_form/#{PAGE}"
  end

  def submit
    additional_product = sanitize(params[:additional_product]).presence

    invalid_fields = validate_radio_field(
      PAGE,
      radio: additional_product,
    )

    if invalid_fields.any?
      flash.now[:validation] = invalid_fields
      render "coronavirus_form/#{PAGE}"
    elsif additional_product == I18n.t("coronavirus_form.questions.additional_product.options.option_yes.label")
      redirect_to controller: "coronavirus_form/product_details", action: "show"
    elsif session["check_answers_seen"]
      redirect_to controller: "coronavirus_form/check_answers", action: "show"
    else
      redirect_to controller: "coronavirus_form/hotel_rooms", action: "show"
    end
  end

private

  PAGE = "additional_product"

  def previous_path
    session["product_details"] ||= []
    latest_product_id = (session["product_details"].last || {}).dig("product_id")
    "/product-details?product_id=#{latest_product_id}"
  end
end
