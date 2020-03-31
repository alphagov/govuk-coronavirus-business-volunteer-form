# frozen_string_literal: true

class CoronavirusForm::LocationController < ApplicationController
  def submit
    location = Array(params[:location]).map { |item| strip_tags(item).presence }.compact

    session[:location] = location

    invalid_fields = validate_checkbox_field(
      controller_name,
      values: location,
      allowed_values: I18n.t("coronavirus_form.questions.#{controller_name}.options").map { |_, item| item.dig(:label) },
    )

    if invalid_fields.any?
      flash.now[:validation] = invalid_fields
      render controller_path
    elsif session["check_answers_seen"]
      redirect_to check_your_answers_url
    else
      redirect_to business_details_url
    end
  end

private

  def previous_path
    offer_other_support_url
  end
end
