# frozen_string_literal: true

class CoronavirusForm::CheckAnswersController < ApplicationController
  def show
    session[:check_answers_seen] = true
    super
  end

  def submit
    submission_reference = reference_number

    session[:reference_number] = submission_reference
    FormResponse.create(form_response: session)

    mailer = CoronavirusFormMailer.with(name: session.dig(:contact_details, :contact_name))
    mailer.thank_you(session.dig(:contact_details, :email)).deliver_later

    reset_session

    redirect_to thank_you_url(reference_number: submission_reference)
  end

private

  def reference_number
    timestamp = Time.zone.now.strftime("%Y%m%d-%H%M%S")
    random_id = SecureRandom.hex(3).upcase
    "#{timestamp}-#{random_id}"
  end

  def previous_path
    contact_details_url
  end
end
