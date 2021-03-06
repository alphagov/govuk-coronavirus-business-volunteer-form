# frozen_string_literal: true

require "spec_helper"

RSpec.describe CoronavirusForm::OfferOtherSupportController, type: :controller do
  include_examples "session expiry"

  let(:current_template) { "coronavirus_form/offer_other_support" }
  let(:session_key) { :offer_other_support }

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
    let(:text_response) { "I have an army of voulenteer medical wizard doctors" }
    let(:evil_script_response) { "I offer you, my hacking script!<script></script>" }

    it "sets session variables" do
      post :submit, params: { offer_other_support: text_response }
      expect(session[session_key]).to eq text_response
    end

    it "sanitizers any html in the text response" do
      post :submit, params: { offer_other_support: evil_script_response }
      expect(session[session_key]).to eq "I offer you, my hacking script!"
    end

    it "strips html characters" do
      params = {
        "offer_other_support" => '<a href="https://www.example.com">Link</a>',
      }

      post :submit, params: params
      expect(session[session_key]).to eq "Link"
    end

    it "takes you to the next page regardless of input" do
      post :submit
      expect(response).to redirect_to(location_path)
    end

    it "redirects to check your answers if check your answers previously seen" do
      session[:check_answers_seen] = true
      post :submit, params: { offer_other_support: text_response }

      expect(response).to redirect_to(check_your_answers_path)
    end

    described_class::TEXT_FIELDS.each do |field|
      it "validates that #{field} is 1000 or fewer characters" do
        params = { offer_other_support: evil_script_response }
        params[field] = SecureRandom.hex(1001)
        post :submit, params: params

        expect(response).to have_http_status(:unprocessable_entity)
        expect(response).to render_template(current_template)
      end
    end
  end
end
