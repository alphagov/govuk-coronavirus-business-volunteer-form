# frozen_string_literal: true

class CoronavirusForm::OfferOtherSupportController < ApplicationController
  include ActionView::Helpers::SanitizeHelper
  include FieldValidationHelper
  include FormFlowHelper

  before_action :check_first_question_answered, only: :show

  def show
    render "coronavirus_form/#{PAGE}"
  end

  def submit
    offer_other_support = sanitize(params[:offer_other_support]).presence

    session[:offer_other_support] = offer_other_support

    if session["check_answers_seen"]
      redirect_to controller: "coronavirus_form/check_answers", action: "show"
    else
      redirect_to controller: "coronavirus_form/#{NEXT_PAGE}", action: "show"
    end
  end

private

  PAGE = "offer_other_support"
  NEXT_PAGE = "business_details"

  def previous_path
    offer_community_support_path
  end
end
