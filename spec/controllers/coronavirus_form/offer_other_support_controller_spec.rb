# frozen_string_literal: true

require "spec_helper"

RSpec.describe CoronavirusForm::OfferOtherSupportController, type: :controller do
  let(:current_template) { "coronavirus_form/offer_other_support" }
  let(:session_key) { :offer_other_support }

  describe "GET show" do
    it "renders the form" do
      get :show
      expect(response).to render_template(current_template)
    end
  end

  describe "POST submit" do
    let(:text_response) { "I have an army of voulenteer medical wizard doctors" }
    let(:evil_script_response) { "I offer you, my hacking script!<script></script>" }

    it "sets session variables" do
      post :submit, params: { offer_other_support: text_response }
      expect(session[session_key]).to eq text_response
    end

    it "cleans sanitizers any html in the text response" do
      post :submit, params: { offer_other_support: evil_script_response }
      expect(session[session_key]).to eq "I offer you, my hacking script!"
    end

    it "redirects to check your answers if check your answers previously seen" do
      session[:check_answers_seen] = true
      post :submit, params: { offer_other_support: text_response }

      expect(response).to redirect_to(coronavirus_form_check_your_answers_path)
    end
  end
end
