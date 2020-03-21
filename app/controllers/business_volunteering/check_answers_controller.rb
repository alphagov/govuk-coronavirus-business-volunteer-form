# frozen_string_literal: true

class BusinessVolunteering::CheckAnswersController < ApplicationController
  include ActionView::Helpers::SanitizeHelper

  def show
    session[:check_answers_seen] = true
    render "business_volunteering/check_answers"
  end
end
