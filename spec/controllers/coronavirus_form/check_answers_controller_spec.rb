# frozen_string_literal: true

require "spec_helper"

RSpec.describe CoronavirusForm::CheckAnswersController, type: :controller do
  include FormResponseHelper
  include SchemaHelper
  include_examples "session expiry"

  let(:current_template) { "coronavirus_form/check_answers" }

  describe "GET show" do
    it "renders the form when first question answered" do
      session["accommodation"] = I18n.t("coronavirus_form.questions.accommodation.options.option_yes.label")

      get :show
      expect(response).to render_template(current_template)
    end

    it "redirects to first question when first question not answered" do
      get :show
      expect(response).to redirect_to(accommodation_path)
    end
  end

  describe "POST submit" do
    before do
      allow_any_instance_of(described_class).to receive(:reference_number).and_return("abc")
    end

    it "saves the form response to the database" do
      data = valid_data
      session.merge!(data)
      post :submit

      expected_data = data.deep_stringify_keys.merge("reference_number" => "abc")
      expect(FormResponse.first.form_response).to eq(expected_data)
    end

    context "when unwanted fields are present in the session" do
      it "excludes those fields from the FormResponse" do
        data = valid_data
        session.merge!(data)
        session["_csrf_token"] = "1234"
        session["current_path"] = "/current"
        session["previous_path"] = "/previous"
        session["check_answers_seen"] = true
        session["session_id"] = "12345"
        post :submit

        expected_data = data.deep_stringify_keys.merge("reference_number" => "abc")
        expect(FormResponse.first.form_response).to eq(expected_data)
        expect(validate_against_form_response_schema(FormResponse.first.form_response)).to be_empty
      end
    end

    it "provides the data in an expected exportable format" do
      data = valid_data
      session.merge!(data)
      post :submit

      expect(validate_against_form_response_schema(FormResponse.last.form_response)).to be_empty

      expect(JSON.parse(FormResponse.last.form_response.to_json).to_h).to eq(data.merge("reference_number" => "abc").deep_stringify_keys)
    end

    it "sends an email" do
      ActiveJob::Base.queue_adapter = :test
      session[:contact_details] = {
        contact_name: "Harry Potter",
        email: "harry@example.org",
      }
      expect {
        post :submit
      }.to have_enqueued_mail(CoronavirusFormMailer, :thank_you)
        .with(a_hash_including(name: "Harry Potter"), "harry@example.org").on_queue("mailers")
    end

    it "does not send an email when no email address provided" do
      ActiveJob::Base.queue_adapter = :test
      session[:contact_details] = {
        contact_name: "Harry Potter",
        email: "",
      }
      expect {
        post :submit
      }.to have_enqueued_mail(CoronavirusFormMailer, :thank_you).on_queue("mailers").exactly(0).times
    end

    it "resets session" do
      post :submit
      expect(session.to_hash).to eq({})
    end

    it "redirects to thank you if sucessfully creates record" do
      post :submit

      expect(response).to redirect_to(thank_you_path(reference_number: "abc"))
    end

    it "doesn't create a FormResponse if the user is the smoke tester" do
      session[:contact_details] = { email: Rails.application.config.courtesy_copy_email }
      session["accommodation"] = I18n.t("coronavirus_form.questions.accommodation.options.option_yes.label")
      expect {
        post :submit
      }.to_not(change { FormResponse.count })
    end

    context "schema validation" do
      it "sends a notification to Sentry if the schema validation fails" do
        expect(GovukError).to receive(:notify)
        post :submit
      end

      it "does not send a notification to Sentry if the data is valid" do
        expect(GovukError).to_not receive(:notify)

        session.merge!(valid_data)
        post :submit
      end
    end
  end
end
