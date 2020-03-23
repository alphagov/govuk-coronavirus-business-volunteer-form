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
    let(:options) do
      I18n.t("coronavirus_form.expert_advice.options").map { |_, item| item[:label] }
    end
    let(:selected) { options.first(2) }
    it "sets session variables" do
      post :submit, params: { expert_advice: selected }

      expect(session[session_key]).to eq selected
    end

    it "redirects to next step" do
      post :submit, params: { expert_advice: selected }

      expect(response).to redirect_to(offer_care_path)
    end

    it "redirects to check your answers if check your answers already seen" do
      session[:check_answers_seen] = true
      post :submit, params: { expert_advice: selected }

      expect(response).to redirect_to(check_your_answers_path)
    end

    it "validates any option is chosen" do
      post :submit, params: { expert_advice: [] }

      expect(response).to render_template(current_template)
    end

    context "when Other option is selected" do
      it "validates the Other option description is provided" do
        post :submit, params: { expert_advice: %w[Other] }

        expect(response).to render_template(current_template)
      end

      it "adds the other option description to the session" do
        post :submit, params: {
          expert_advice: %w[Other] + selected,
          expert_advice_other: "Demo text",
        }

        expect(session[session_key]).to eq %w[Other] + selected
        expect(session[:expert_advice_other]).to eq "Demo text"
        expect(response).to redirect_to(offer_care_path)
      end
    end

    it "validates a valid option is chosen" do
      post :submit, params: {
        expert_advice: ["<script></script", "invalid option"],
      }

      expect(response).to render_template(current_template)
    end

    it "validates only valid options are chosen" do
      post :submit, params: {
        expert_advice: ["<script></script", "invalid option"] + selected,
      }

      expect(response).to render_template(current_template)
    end
  end
end
