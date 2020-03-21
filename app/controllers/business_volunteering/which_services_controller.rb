# frozen_string_literal: true

class BusinessVolunteering::WhichServicesController < ApplicationController
  include ActionView::Helpers::SanitizeHelper
  include FieldValidationHelper

  def show
    session[:which_services] ||= []
    render "business_volunteering/#{PAGE}"
  end

  def submit
    which_services = Array(params[:which_services]).map { |item| sanitize(item).presence }.compact

    session[:which_services] = which_services

    invalid_fields = validate_checkbox_field(
      PAGE,
      values: which_services,
      allowed_values: I18n.t("business_volunteering.#{PAGE}.options").map { |_, item| item.dig(:label) },
    )

    if invalid_fields.any?
      flash.now[:validation] = invalid_fields
      render "business_volunteering/#{PAGE}"
    else
      redirect_to controller: session["check_answers_seen"] ? "business_volunteering/check_answers" : "business_volunteering/#{NEXT_PAGE}", action: "show"
    end
  end

private

  PAGE = "which_services"
  NEXT_PAGE = "thank_you"

  def previous_path
    "/coronavirus-form/which-goods"
  end
end
