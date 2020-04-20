# frozen_string_literal: true

require "spec_helper"

RSpec.describe CoronavirusForm::OfferCareController, type: :controller do
  include_examples "session expiry"

  let(:current_template) { "coronavirus_form/offer_care" }
  let(:session_key) { :offer_care }

  describe "GET show" do
    it "renders the form when first question answered" do
      session["medical_equipment"] = "Yes"
      get :show
      expect(response).to render_template(current_template)
    end

    it "redirects to first question when first question not answered" do
      get :show
      expect(response).to redirect_to({
        controller: "medical_equipment",
        action: "show",
      })
    end
  end

  describe "POST submit" do
    let(:selected_yes) { I18n.t("coronavirus_form.questions.offer_care.options.option_yes.label") }
    let(:selected_no) { I18n.t("coronavirus_form.questions.offer_care.options.option_no.label") }

    it "sets session variables" do
      post :submit, params: { offer_care: selected_yes }
      expect(session[session_key]).to eq selected_yes
    end

    it "redirects to check your answers if check your answers previously seen and response is No" do
      session[:check_answers_seen] = true
      post :submit, params: { offer_care: selected_no }

      expect(response).to redirect_to(check_your_answers_path)
    end

    it "redirects to next sub-question if check your answers previously seen and response is Yes" do
      session[:check_answers_seen] = true
      post :submit, params: { offer_care: selected_yes }

      expect(response).to redirect_to(offer_care_qualifications_path)
    end

    it "redirects to next sub-question for a Yes response" do
      post :submit, params: { offer_care: selected_yes }
      expect(response).to redirect_to(offer_care_qualifications_path)
    end

    it "redirects to next step for a No response" do
      post :submit, params: { offer_care: selected_no }
      expect(response).to redirect_to(offer_other_support_path)
    end

    it "validates any option is chosen" do
      post :submit, params: { offer_care: "" }

      expect(response).to have_http_status(:unprocessable_entity)
      expect(response).to render_template(current_template)
    end

    it "validates a valid option is chosen" do
      post :submit, params: { offer_care: "<script></script>" }

      expect(response).to have_http_status(:unprocessable_entity)
      expect(response).to render_template(current_template)
    end
  end
end
