# frozen_string_literal: true

class CoronavirusForm::LocationController < ApplicationController
  before_action :check_first_question_answered, only: :show

  def show
    session[:location] ||= []
    render "coronavirus_form/#{PAGE}"
  end

  def submit
    location = Array(params[:location]).map { |item| strip_tags(item).presence }.compact

    session[:location] = location

    invalid_fields = validate_checkbox_field(
      PAGE,
      values: location,
      allowed_values: I18n.t("coronavirus_form.questions.#{PAGE}.options").map { |_, item| item.dig(:label) },
    )

    if invalid_fields.any?
      flash.now[:validation] = invalid_fields
      render "coronavirus_form/#{PAGE}"
    elsif session["check_answers_seen"]
      redirect_to controller: "coronavirus_form/check_answers", action: "show"
    else
      redirect_to controller: "coronavirus_form/business_details", action: "show"
    end
  end

private

  PAGE = "location"

  def previous_path
    offer_other_support_path
  end
end
