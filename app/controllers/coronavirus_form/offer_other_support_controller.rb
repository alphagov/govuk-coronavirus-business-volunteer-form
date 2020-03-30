# frozen_string_literal: true

class CoronavirusForm::OfferOtherSupportController < ApplicationController
  before_action :check_first_question_answered, only: :show

  TEXT_FIELDS = %w(offer_other_support).freeze

  def show
    render "coronavirus_form/#{PAGE}"
  end

  def submit
    offer_other_support = strip_tags(params[:offer_other_support]).presence

    session[:offer_other_support] = offer_other_support

    invalid_fields = validate_field_response_length(PAGE, TEXT_FIELDS)

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

  PAGE = "offer_other_support"
  NEXT_PAGE = "location"

  def previous_path
    offer_care_path
  end
end
