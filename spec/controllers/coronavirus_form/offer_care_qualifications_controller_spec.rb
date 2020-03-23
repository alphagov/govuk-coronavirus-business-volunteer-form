# frozen_string_literal: true

require "spec_helper"

RSpec.describe CoronavirusForm::OfferCareQualificationsController, type: :controller do
  let(:current_template) { "coronavirus_form/offer_care_qualifications" }
  let(:session_key) { :offer_care_qualifications }

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
    let(:selected) { ["DBS check"] }
    it "sets session variables" do
      post :submit, params: { offer_care_qualifications: selected }

      expect(session[session_key]).to eq selected
    end

    it "redirects to next step" do
      post :submit, params: { offer_care_qualifications: selected }

      expect(response).to redirect_to(offer_community_support_path)
    end

    it "redirects to check your answers if check your answers already seen" do
      session[:check_answers_seen] = true
      post :submit, params: { offer_care_qualifications: selected }

      expect(response).to redirect_to(check_your_answers_path)
    end

    it "validates any option is chosen" do
      post :submit, params: { offer_care_qualifications: [] }

      expect(response).to render_template(current_template)
    end

    context "when Nursing or other healthcare qualification option is selected" do
      it "validates the Nursing or other healthcare qualification option description is provided" do
        post :submit, params: { offer_care_qualifications: ["DBS check", "Nursing or other healthcare qualification"] }

        expect(response).to render_template(current_template)
      end

      it "adds the details to the session" do
        post :submit, params: {
          offer_care_qualifications: ["DBS check", "Nursing or other healthcare qualification"],
          offer_care_qualifications_type: "Registered Nurse",
        }

        expect(response).to redirect_to(offer_community_support_path)
        expect(session[session_key]).to eq ["DBS check", "Nursing or other healthcare qualification"]
        expect(session[:offer_care_qualifications_type]).to eq "Registered Nurse"
      end
    end

    it "validates a valid option is chosen" do
      post :submit, params: {
        offer_care_qualifications: ["<script></script", "invalid option", "DBS check"],
      }

      expect(response).to render_template(current_template)
    end
  end
end
