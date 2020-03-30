# frozen_string_literal: true

class ApplicationController < ActionController::Base
  include ActionView::Helpers::SanitizeHelper
  include CheckAnswersHelper
  include FieldValidationHelper
  include FormFlowHelper
  include ProductHelper

  before_action :check_first_question_answered, only: :show

  if ENV["REQUIRE_BASIC_AUTH"]
    http_basic_authenticate_with(
      name: ENV.fetch("BASIC_AUTH_USERNAME"),
      password: ENV.fetch("BASIC_AUTH_PASSWORD"),
    )
  end

  def show
    render controller_path
  end

private

  helper_method :previous_path

  def previous_path
    raise NotImplementedError, "Define a previous path"
  end
end
