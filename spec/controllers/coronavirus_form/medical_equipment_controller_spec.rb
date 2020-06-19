# frozen_string_literal: true

require "spec_helper"

RSpec.describe CoronavirusForm::MedicalEquipmentController, type: :controller do
  include_examples "session expiry"

  let(:current_template) { "coronavirus_form/medical_equipment" }
  let(:session_key) { :medical_equipment }

  describe "GET show" do
    it "renders the form" do
      get :show
      expect(response).to render_template(current_template)
    end
  end

  describe "POST submit" do
    it "sets session variables" do
      post :submit, params: { medical_equipment: I18n.t("coronavirus_form.questions.medical_equipment.options.option_yes.label") }

      expect(session[session_key]).to eq I18n.t("coronavirus_form.questions.medical_equipment.options.option_yes.label")
    end

    it "redirects to next step for yes response" do
      post :submit, params: { medical_equipment: I18n.t("coronavirus_form.questions.medical_equipment.options.option_yes.label") }

      expect(response).to redirect_to(medical_equipment_type_path)
    end

    it "redirects to next sub-question for no response" do
      post :submit, params: { medical_equipment: I18n.t("coronavirus_form.questions.medical_equipment.options.option_no.label") }

      expect(response).to redirect_to(accommodation_path)
    end

    it "redirects to check your answers if check your answers previously seen" do
      session[:check_answers_seen] = true
      post :submit, params: { medical_equipment: I18n.t("coronavirus_form.questions.medical_equipment.options.option_yes.label") }

      expect(response).to redirect_to(check_your_answers_path)
    end

    it "validates any option is chosen" do
      post :submit, params: { medical_equipment: "" }

      expect(response).to have_http_status(:unprocessable_entity)
      expect(response).to render_template(current_template)
    end

    it "validates a valid option is chosen" do
      post :submit, params: { medical_equipment: "<script></script>" }

      expect(response).to have_http_status(:unprocessable_entity)
      expect(response).to render_template(current_template)
    end
  end
end
