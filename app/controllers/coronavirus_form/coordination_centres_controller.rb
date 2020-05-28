# frozen_string_literal: true

class CoronavirusForm::CoordinationCentresController < ApplicationController
  skip_before_action :check_first_question_answered

private

  def previous_path
    return first_question_path if session[:previous_path].blank?

    path = URI(session[:previous_path]).path
    path.presence || first_question_path
  end
end
