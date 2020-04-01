# frozen_string_literal: true

require "spec_helper"

RSpec.describe CoronavirusForm::OfferCareQualificationsController, type: :controller do
  let(:current_template) { "coronavirus_form/offer_care_qualifications" }
  let(:session_key_type) { :offer_care_type }
  let(:session_key_qualifcation) { :offer_care_qualifications }

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
    let(:selected_type) { ["Care for adults"] }
    let(:selected_qualification) { ["DBS check"] }

    it "sets session variables" do
      post :submit, params: {
        offer_care_type: selected_type,
        offer_care_qualifications: selected_qualification,
      }

      expect(session[session_key_type]).to eq selected_type
      expect(session[session_key_qualifcation]).to eq selected_qualification
    end

    it "redirects to next step" do
      post :submit, params: {
        offer_care_type: selected_type,
        offer_care_qualifications: selected_qualification,
      }
      expect(response).to redirect_to(offer_other_support_path)
    end

    it "redirects to check your answers if check your answers already seen" do
      session[:check_answers_seen] = true
      post :submit, params: {
        offer_care_type: selected_type,
        offer_care_qualifications: selected_qualification,
      }
      expect(response).to redirect_to(check_your_answers_path)
    end

    it "validates any care type is chosen" do
      post :submit, params: {
        offer_care_type: [],
        offer_care_qualifications: selected_qualification,
      }
      expect(response).to render_template(current_template)
    end

    it "validates any qualification is chosen" do
      post :submit, params: {
        offer_care_type: selected_type,
        offer_care_qualifications: [],
      }
      expect(response).to render_template(current_template)
    end

    context "when Nursing or other healthcare qualification option is selected" do
      it "validates the Nursing or other healthcare qualification option description is provided" do
        post :submit, params: {
          offer_care_type: selected_type,
          offer_care_qualifications: ["DBS check", "Nursing or other healthcare qualification"],
        }

        expect(response).to render_template(current_template)
      end

      it "adds the details to the session" do
        post :submit, params: {
          offer_care_type: selected_type,
          offer_care_qualifications: ["DBS check", "Nursing or other healthcare qualification"],
        offer_care_qualifications_type: "Registered Nurse",
      }

        expect(response).to redirect_to(offer_other_support_path)
        expect(session[session_key_qualifcation]).to eq ["DBS check", "Nursing or other healthcare qualification"]
        expect(session[:offer_care_qualifications_type]).to eq "Registered Nurse"
      end
    end

    it "validates a valid care type is chosen" do
      post :submit, params: {
        offer_care_type: ["<script></script", "invalid option", "DBS check"],
        offer_care_qualifications: selected_qualification,
      }

      expect(response).to render_template(current_template)
    end

    it "validates a valid qualification is chosen" do
      post :submit, params: {
        offer_care_type: selected_type,
        offer_care_qualifications: ["<script></script", "invalid option", "DBS check"],
      }

      expect(response).to render_template(current_template)
    end

    described_class::TEXT_FIELDS.each do |field|
      it "validates that #{field} is 1000 or fewer characters" do
        params = {
          offer_care_type: selected_type,
          offer_care_qualifications: ["DBS check", "Nursing or other healthcare qualification"],
          offer_care_qualifications_type: "Registered Nurse",
        }
        params[field] = SecureRandom.hex(1001)
        post :submit, params: params

        expect(response).to render_template(current_template)
      end
    end
  end
end
