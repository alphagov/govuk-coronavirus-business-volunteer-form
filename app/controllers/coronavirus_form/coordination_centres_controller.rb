# frozen_string_literal: true

class CoronavirusForm::CoordinationCentresController < ApplicationController
  skip_before_action :check_first_question_answered

private

  def previous_path
    medical_equipment_type_url
  end
end
