# frozen_string_literal: true

require "spec_helper"

RSpec.describe CoronavirusForm::ExpertAdviceController, type: :controller do
  let(:current_template) { "coronavirus_form/expert_advice" }
  let(:session_key) { :expert_advice }

  describe "GET show" do
    it "renders the form" do
      get :show
      expect(response).to render_template(current_template)
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
      post :submit, params: {
        expert_advice: I18n.t("coronavirus_form.expert_advice.options.option_no.label"),
      }
      expect(response).to redirect_to(offer_space_path)
    end

    it "redirects to next sub-question for a 'Yes' response" do
      post :submit, params: {
         expert_advice: I18n.t("coronavirus_form.expert_advice.options.option_yes.label"),
       }
      expect(response).to redirect_to(expert_advice_type_path)
    end

    it "redirects to check your answers if check your answers previously seen and response is 'No'" do
      session[:check_answers_seen] = true
      post :submit, params: {
         expert_advice: I18n.t("coronavirus_form.expert_advice.options.option_no.label"),
       }
      expect(response).to redirect_to(check_your_answers_path)
    end

    it "redirects to next sub-question if check your answers previously seen and response is 'Yes'" do
      session[:check_answers_seen] = true
      post :submit, params: {
         expert_advice: I18n.t("coronavirus_form.expert_advice.options.option_yes.label"),
       }
      expect(response).to redirect_to(expert_advice_type_path)
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
