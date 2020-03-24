# frozen_string_literal: true

require "spec_helper"

RSpec.describe CoronavirusForm::MedicalEquipmentTypeController, type: :controller do
  let(:current_template) { "coronavirus_form/medical_equipment_type" }
  let(:session_key) { :medical_equipment_type }

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

      expect(session[session_key]).to eq selected
    end

    it "redirects to next step" do
      post :submit, params: { medical_equipment_type: selected }

      expect(response).to redirect_to(product_details_path)
    end

    it "redirects to check your answers if check your answers already seen" do
      session[:check_answers_seen] = true
      post :submit, params: { medical_equipment_type: selected }

      expect(response).to redirect_to(check_your_answers_path)
    end

    it "validates any option is chosen" do
      post :submit, params: { medical_equipment_type: nil }

      expect(response).to render_template(current_template)
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

        expect(response).to redirect_to(product_details_path)
        expect(session[session_key]).to eq "Other"
        expect(session[:medical_equipment_type_other]).to eq "Demo text"
      end
    end

    it "validates a valid option is chosen" do
      post :submit, params: {
        medical_equipment_type: "<script></script",
      }

      expect(response).to render_template(current_template)
    end
  end
end
