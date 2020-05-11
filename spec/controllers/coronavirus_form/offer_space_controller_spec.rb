# frozen_string_literal: true

require "spec_helper"

RSpec.describe CoronavirusForm::OfferSpaceController, type: :controller do
  include_examples "session expiry"

  let(:current_template) { "coronavirus_form/offer_space" }
  let(:session_key) { :offer_space }

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
    let(:selected) { permitted_values.sample }
    let(:permitted_values) do
      I18n.t("coronavirus_form.questions.offer_space.options").map { |_, item| item[:label] }
    end

    it "sets session variables" do
      post :submit, params: { offer_space: selected }
      expect(session[session_key]).to eq selected
    end

    it "redirects to next step for a 'No' response" do
      post :submit, params: { offer_space: I18n.t("coronavirus_form.questions.offer_space.options.option_no.label") }
      expect(response).to redirect_to(expert_advice_type_path)
    end

    it "clears previously entered space cost for a 'No' response" do
      session[:space_cost] = I18n.t("coronavirus_form.questions.how_much_charge.options").map { |_, item| item[:label] }.sample

      post :submit, params: { offer_space: I18n.t("coronavirus_form.questions.offer_space.options.option_no.label") }

      expect(session[:space_cost]).to be nil
    end

    it "redirects to next step for a 'Yes' response" do
      post :submit, params: { offer_space: I18n.t("coronavirus_form.questions.offer_space.options.option_yes.label") }
      expect(response).to redirect_to(offer_space_type_path)
    end

    it "redirects to check your answers if check your answers previously seen" do
      session[:check_answers_seen] = true
      post :submit, params: { offer_space: I18n.t("coronavirus_form.questions.offer_space.options.option_no.label") }

      expect(response).to redirect_to(check_your_answers_path)
    end

    it "redirects to check your answers if answer is Yes regardless of check your answers state" do
      session[:check_answers_seen] = true
      post :submit, params: { offer_space: I18n.t("coronavirus_form.questions.offer_space.options.option_yes.label") }

      expect(response).to redirect_to(offer_space_type_path)
    end

    it "validates any option is chosen" do
      post :submit, params: { offer_space: "" }

      expect(response).to have_http_status(:unprocessable_entity)
      expect(response).to render_template(current_template)
    end

    it "validates a valid option is chosen" do
      post :submit, params: { offer_space: "<script></script>" }

      expect(response).to have_http_status(:unprocessable_entity)
      expect(response).to render_template(current_template)
    end
  end
end
