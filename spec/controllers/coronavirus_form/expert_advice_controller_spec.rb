# frozen_string_literal: true

require "spec_helper"

RSpec.describe CoronavirusForm::ExpertAdviceController, type: :controller do
  let(:current_template) { "coronavirus_form/expert_advice" }
  let(:session_key) { :expert_advice }

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
    let(:selected) { permitted_values.sample }
    let(:permitted_values) do
      I18n.t("coronavirus_form.expert_advice.options").map { |_, item| item[:label] }
    end

    it "sets session variables" do
      post :submit, params: { expert_advice: selected }
      expect(session[session_key]).to eq selected
    end

    it "redirects to next step for a 'No' response" do
      post :submit, params: { expert_advice: "No" }
      expect(response).to redirect_to(offer_care_path)
    end

    it "redirects to next step for a 'Yes' response" do
      post :submit, params: { expert_advice: "Yes" }
      expect(response).to redirect_to(expert_advice_type_path)
    end

    it "redirects to check your answers if check your answers previously seen" do
      session[:check_answers_seen] = true
      post :submit, params: { expert_advice: selected }

      expect(response).to redirect_to(check_your_answers_path)
    end

    it "validates any option is chosen" do
      post :submit, params: { expert_advice: "" }

      expect(response).to render_template(current_template)
    end

    it "validates a valid option is chosen" do
      post :submit, params: { expert_advice: "<script></script>" }

      expect(response).to render_template(current_template)
    end
  end
end
