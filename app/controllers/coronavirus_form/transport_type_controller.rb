# frozen_string_literal: true

class CoronavirusForm::TransportTypeController < ApplicationController
  before_action :check_first_question_answered, only: :show

  REQUIRED_FIELDS = %w(transport_description).freeze
  TEXT_FIELDS = %w(transport_description).freeze

  def show
    session[:transport_type] ||= []
    render "coronavirus_form/#{PAGE}"
  end

  def submit
    transport_type = Array(params[:transport_type]).map { |item| strip_tags(item).presence }.compact

    session[:transport_type] = transport_type
    session[:transport_description] = params[:transport_description]

    invalid_fields = validate_checkbox_field(
      PAGE,
      values: transport_type,
      allowed_values: I18n.t("coronavirus_form.questions.#{PAGE}.options").map { |_, item| item.dig(:label) },
                      ) +
      validate_mandatory_text_fields(PAGE, REQUIRED_FIELDS) +
      validate_field_response_length(PAGE, TEXT_FIELDS)

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
