# frozen_string_literal: true

class CoronavirusForm::OfferSpaceTypeController < ApplicationController
  before_action :check_first_question_answered, only: :show

  TEXT_FIELDS = %w(offer_space_type_other).freeze

  def show
    session[:offer_space_type] ||= []
    render "coronavirus_form/#{PAGE}"
  end

  def submit
    offer_space_type = Array(params[:offer_space_type]).map { |item| strip_tags(item).presence }.compact
    offer_space_type_other = strip_tags(params[:offer_space_type_other]).presence
    session[:offer_space_type] = offer_space_type
    session[:offer_space_type_other] = if selected_other?(offer_space_type)
                                         offer_space_type_other
                                       else
                                         ""
                                       end

    invalid_fields = validate_field_response_length(PAGE, TEXT_FIELDS) +
      validate_checkbox_field(
        PAGE,
        values: offer_space_type,
        allowed_values: I18n.t("coronavirus_form.questions.#{PAGE}.options").map { |_, item| item.dig(:label) },
        other: offer_space_type_other,
      )

    if invalid_fields.any?
      flash.now[:validation] = invalid_fields
      render "coronavirus_form/#{PAGE}"
    elsif session["check_answers_seen"]
      redirect_to controller: "coronavirus_form/check_answers", action: "show"
    else
      redirect_to controller: "coronavirus_form/#{NEXT_PAGE}", action: "show"
    end
  end

private

  PAGE = "offer_space_type"
  NEXT_PAGE = "expert_advice_type"

  def selected_other?(offer_space_type)
    offer_space_type.include?(
      I18n.t("coronavirus_form.questions.#{PAGE}.options.other.label"),
    )
  end

  def previous_path
    offer_space_path
  end
end
