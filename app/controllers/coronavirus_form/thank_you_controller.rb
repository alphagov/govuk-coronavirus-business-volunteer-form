# frozen_string_literal: true

class CoronavirusForm::ThankYouController < ApplicationController
  skip_before_action :check_first_question_answered

  def show
    @enough_items = params[:enough_items]
    super
  end
end
