# frozen_string_literal: true

require "spec_helper"

RSpec.describe CoronavirusForm::OfferSpaceController, type: :controller do
  let(:current_template) { "coronavirus_form/offer_space" }
  let(:session_key) { :offer_space }

  describe "GET show" do
    it "renders the form" do
      get :show
      expect(response).to render_template(current_template)
    end
  end

  describe "POST submit" do
    let(:selected) { permitted_values.sample }
    let(:permitted_values) do
      I18n.t("coronavirus_form.offer_space.options").map { |_, item| item[:label] }
    end

    it "sets session variables" do
      post :submit, params: { offer_space: selected }
      expect(session[session_key]).to eq selected
    end

    it "redirects to next step for a 'No' response" do
      post :submit, params: { offer_space: "No" }
      expect(response).to redirect_to(coronavirus_form_expert_advice_path)
    end

    it "redirects to next step for a 'Yes' response" do
      post :submit, params: { offer_space: "Yes" }
      expect(response).to redirect_to(coronavirus_form_what_kind_of_space_path)
    end

    it "redirects to check your answers if check your answers previously seen" do
      session[:check_answers_seen] = true
      post :submit, params: { offer_space: selected }

      expect(response).to redirect_to(coronavirus_form_check_your_answers_path)
    end

    it "validates any option is chosen" do
      post :submit, params: { offer_space: "" }

      expect(response).to render_template(current_template)
    end

    it "validates a valid option is chosen" do
      post :submit, params: { offer_space: "<script></script>" }

      expect(response).to render_template(current_template)
    end
  end
end
