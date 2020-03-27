# frozen_string_literal: true

class ApplicationController < ActionController::Base
  include ActionView::Helpers::SanitizeHelper
  include CheckAnswersHelper
  include FieldValidationHelper
  include FormFlowHelper
  include ProductHelper

  if ENV["REQUIRE_BASIC_AUTH"]
    http_basic_authenticate_with(
      name: ENV.fetch("BASIC_AUTH_USERNAME"),
      password: ENV.fetch("BASIC_AUTH_PASSWORD"),
    )
  end

private

  helper_method :previous_path
  helper_method :publishing_components_version

  def previous_path
    raise NotImplementedError, "Define a previous path"
  end

  def publishing_components_version
    Gem.loaded_specs["govuk_publishing_components"].version.version
  end
end
