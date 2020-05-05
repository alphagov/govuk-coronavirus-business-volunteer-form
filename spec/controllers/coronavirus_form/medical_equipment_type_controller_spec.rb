# frozen_string_literal: true

require "spec_helper"

RSpec.describe CoronavirusForm::MedicalEquipmentTypeController, type: :controller do
  include_examples "session expiry"

  let(:current_template) { "coronavirus_form/medical_equipment_type" }
  let(:session_key) { :product_details }

  before { allow(SecureRandom).to receive(:uuid).and_return("abcd1234") }

  describe "GET show" do
    it "renders the form when first question answered" do
      session["medical_equipment"] = I18n.t("coronavirus_form.questions.medical_equipment.options.option_yes.label")
      get :show
      expect(response).to render_template(current_template)
    end

    it "redirects to first question when first question not answered" do
      get :show
      expect(response).to redirect_to(medical_equipment_path)
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

      expect(response).to redirect_to(product_details_path(product_id: "abcd1234"))
    end

    it "validates any option is chosen" do
      post :submit, params: { medical_equipment_type: nil }

      expect(response).to have_http_status(:unprocessable_entity)
      expect(response).to render_template(current_template)
    end

    it "doesn't store my response if it is invalid" do
      post :submit, params: { medical_equipment_type: nil }
      expect(session[session_key]).to eq []
    end

    it "validates a valid option is chosen" do
      post :submit, params: {
        medical_equipment_type: "<script></script",
      }

      expect(response).to have_http_status(:unprocessable_entity)
      expect(response).to render_template(current_template)
    end
  end
end
