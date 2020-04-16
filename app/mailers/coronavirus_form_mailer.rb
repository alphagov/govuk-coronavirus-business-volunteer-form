class CoronavirusFormMailer < ApplicationMailer
  self.delivery_job = EmailDeliveryJob

  def thank_you(email_address)
    @name = params[:name]
    mail(to: email_address, subject: I18n.t("emails.thank_you.subject"))
  end
end
