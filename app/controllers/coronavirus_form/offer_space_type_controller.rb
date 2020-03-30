# frozen_string_literal: true

class CoronavirusForm::OfferSpaceTypeController < ApplicationController
  TEXT_FIELDS = %w(offer_space_type_other).freeze

  def submit
    offer_space_type = Array(params[:offer_space_type]).map { |item| strip_tags(item).presence }.compact
    offer_space_type_other = strip_tags(params[:offer_space_type_other]).presence
    session[:offer_space_type] = offer_space_type
    session[:offer_space_type_other] = if selected_other?(offer_space_type)
                                         offer_space_type_other
                                       else
                                         ""
                                       end

    invalid_fields = validate_field_response_length(controller_name, TEXT_FIELDS) +
      validate_checkbox_field(
        controller_name,
        values: offer_space_type,
        allowed_values: I18n.t("coronavirus_form.questions.#{controller_name}.options").map { |_, item| item.dig(:label) },
        other: offer_space_type_other,
      )

    if invalid_fields.any?
      flash.now[:validation] = invalid_fields
      render controller_path
    elsif session["check_answers_seen"]
      redirect_to check_your_answers_path
    else
      redirect_to expert_advice_type_path
    end
  end

private

  def selected_other?(offer_space_type)
    offer_space_type.include?(
      I18n.t("coronavirus_form.questions.#{controller_name}.options.other.label"),
    )
  end

  def previous_path
    offer_space_path
  end
end
