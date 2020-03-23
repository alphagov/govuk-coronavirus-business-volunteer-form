# frozen_string_literal: true

class CoronavirusForm::TransportTypeController < ApplicationController
  include ActionView::Helpers::SanitizeHelper
  include FieldValidationHelper
  include FormFlowHelper

  before_action :check_first_question_answered, only: :show

  def show
    session[:transport_type] ||= []
    render "coronavirus_form/#{PAGE}"
  end

  def submit
    transport_type = Array(params[:transport_type]).map { |item| sanitize(item).presence }.compact

    session[:transport_type] = transport_type

    invalid_fields = validate_checkbox_field(
      PAGE,
      values: transport_type,
      allowed_values: I18n.t("coronavirus_form.#{PAGE}.options").map { |_, item| item.dig(:label) },
    )

    if invalid_fields.any?
      flash.now[:validation] = invalid_fields
      render "coronavirus_form/#{PAGE}"
    elsif session["check_answers_seen"]
      redirect_to controller: "coronavirus_form/check_answers", action: "show"
    else
      redirect_to controller: "coronavirus_form/offer_space", action: "show"
    end
  end

private

  PAGE = "transport_type"

  def previous_path
    offer_transport_path
  end
end
