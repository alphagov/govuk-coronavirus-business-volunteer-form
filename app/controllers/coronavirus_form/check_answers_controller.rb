# frozen_string_literal: true

class CoronavirusForm::CheckAnswersController < ApplicationController
  include SchemaHelper

  before_action :set_reference_number

  def show
    session[:check_answers_seen] = true
    super
  end

  def submit
    validation_errors = validate_against_form_response_schema(parsed_session)
    if validation_errors.any?
      GovukError.notify(
        FormResponseInvalidError.new,
        extra: { validation_errors: validation_errors },
      )
    end

    FormResponse.create(form_response: parsed_session) unless smoke_tester?

    send_confirmation_email if session.dig(:contact_details, :email).present?

    ref_number = session[:reference_number]
    reset_session

    redirect_to thank_you_url(reference_number: ref_number)
  end

private

  def parsed_session
    session.to_h.with_indifferent_access.except(:session_id, :_csrf_token, :current_path, :previous_path, :check_answers_seen)
  end

  def set_reference_number
    session[:reference_number] ||= reference_number
  end

  def send_confirmation_email
    mailer = CoronavirusFormMailer.with(name: session.dig(:contact_details, :contact_name))
    mailer.thank_you(user_email).deliver_later
  end

  def user_email
    if ENV["PAAS_ENV"] == "staging"
      Rails.application.config.courtesy_copy_email
    else
      session.dig(:contact_details, :email)
    end
  end

  def smoke_tester?
    email = session.dig(:contact_details, :email)
    email.present? && email == Rails.application.config.courtesy_copy_email
  end

  def reference_number
    @reference_number ||= begin
      timestamp = Time.zone.now.strftime("%Y%m%d-%H%M%S")
      random_id = SecureRandom.hex(3).upcase
      "#{timestamp}-#{random_id}"
    end
  end

  def previous_path
    contact_details_url
  end
end
