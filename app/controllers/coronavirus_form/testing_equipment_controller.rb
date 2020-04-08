# frozen_string_literal: true

class CoronavirusForm::TestingEquipmentController < ApplicationController
  def show
    super
  end

private

  def previous_path
    return check_your_answers_url if session["check_answers_seen"]

    medical_equipment_type_url
  end
end
