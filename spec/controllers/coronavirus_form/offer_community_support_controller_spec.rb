# frozen_string_literal: true

require "spec_helper"

RSpec.describe CoronavirusForm::OfferCommunitySupportController, type: :controller do
  let(:current_template) { "coronavirus_form/offer_community_support" }
  let(:session_key) { :offer_community_support }

  describe "GET show" do
    it "renders the form" do
      get :show
      expect(response).to render_template(current_template)
    end
  end

  describe "POST submit" do
    let(:selected_yes) { I18n.t("coronavirus_form.offer_community_support.options.option_yes.label") }

    it "sets session variables" do
      post :submit, params: { offer_community_support: selected_yes }
      expect(session[session_key]).to eq selected_yes
    end

    it "redirects to check your answers if check your answers previously seen" do
      session[:check_answers_seen] = true
      post :submit, params: { offer_community_support: selected_yes }

      expect(response).to redirect_to(check_your_answers_path)
    end

    it "validates any option is chosen" do
      post :submit, params: { offer_community_support: "" }

      expect(response).to render_template(current_template)
    end

    it "validates a valid option is chosen" do
      post :submit, params: { offer_community_support: "<script></script>" }

      expect(response).to render_template(current_template)
    end
  end
end
