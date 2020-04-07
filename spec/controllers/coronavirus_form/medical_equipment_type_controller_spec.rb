# frozen_string_literal: true

require "spec_helper"

RSpec.describe CoronavirusForm::MedicalEquipmentTypeController, type: :controller do
  include_examples "session expiry"

  let(:current_template) { "coronavirus_form/medical_equipment_type" }
  let(:session_key) { :product_details }

  before { allow(SecureRandom).to receive(:uuid).and_return("abcd1234") }

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
    let(:selected) { "Personal protection equipment" }
    it "sets session variables" do
      post :submit, params: { medical_equipment_type: selected }

      expect(session[session_key][0][:medical_equipment_type]).to eq selected
    end

    it "redirects to next step" do
      post :submit, params: { medical_equipment_type: selected }

      expect(response).to redirect_to(
        controller: "coronavirus_form/product_details",
        action: :show,
        params: { product_id: "abcd1234" },
      )
    end

    it "validates any option is chosen" do
      post :submit, params: { medical_equipment_type: nil }

      expect(response).to render_template(current_template)
    end

    it "doesn't store my response if it is invalid" do
      post :submit, params: { medical_equipment_type: nil }
      expect(session[session_key]).to eq []
    end

    context "when Other option is selected" do
      it "validates the Other option description is provided" do
        post :submit, params: { medical_equipment_type: "Other" }

        expect(response).to render_template(current_template)
      end

      it "adds the other option description to the session" do
        post :submit, params: {
          medical_equipment_type: "Other",
          medical_equipment_type_other: "Demo text",
        }

        expect(response).to redirect_to(
          controller: "coronavirus_form/product_details",
          action: :show,
          params: { product_id: "abcd1234" },
        )
        expect(session[session_key][0][:medical_equipment_type]).to eq "Other"
        expect(session[session_key][0][:medical_equipment_type_other]).to eq "Demo text"
      end
    end

    it "validates a valid option is chosen" do
      post :submit, params: {
        medical_equipment_type: "<script></script",
      }

      expect(response).to render_template(current_template)
    end

    described_class::TEXT_FIELDS.each do |field|
      it "validates that #{field} is 1000 or fewer characters" do
        params = { medical_equipment_type: selected }
        params[field] = SecureRandom.hex(1001)
        post :submit, params: params

        expect(response).to render_template(current_template)
      end
    end
  end
end
