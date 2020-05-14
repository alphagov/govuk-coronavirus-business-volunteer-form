# frozen_string_literal: true

require "spec_helper"

RSpec.describe CoronavirusForm::TransportTypeController, type: :controller do
  include_examples "session expiry"

  let(:current_template) { "coronavirus_form/transport_type" }
  let(:session_key) { :transport_type }
  let(:session_key_text) { :transport_description }

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
    let(:options) do
      I18n.t("coronavirus_form.questions.transport_type.options").map { |_, item| item[:label] }
    end
    let(:selected) { [options, [options.sample]].sample }

    let(:cost) do
      I18n.t("coronavirus_form.questions.how_much_charge.options").map { |_, item| item[:label] }.sample
    end

    let(:description) { "Something" }

    it "sets session variables" do
      post :submit,
           params: {
             transport_type: selected,
             transport_description: description,
             transport_cost: cost,
           }

      expect(session[session_key]).to eq selected
      expect(session[session_key_text]).to eq description
    end

    it "redirects to next step" do
      post :submit,
           params: {
             transport_type: selected,
             transport_description: description,
             transport_cost: cost,
           }

      expect(response).to redirect_to(offer_space_path)
    end

    it "redirects to check your answers if check your answers previously seen" do
      session[:check_answers_seen] = true
      post :submit,
           params: {
             transport_type: selected,
             transport_description: description,
             transport_cost: cost,
           }

      expect(response).to redirect_to("/check-your-answers")
    end

    it "validates any transport type option is chosen" do
      post :submit,
           params: {
             transport_type: [],
             transport_description: description,
             transport_cost: cost,
           }

      expect(response).to have_http_status(:unprocessable_entity)
      expect(response).to render_template(current_template)
    end

    it "validates a valid transport type option is chosen" do
      post :submit,
           params: {
             transport_type: ["<script></script", "invalid option", "Medical equipment"],
             transport_description: description,
             transport_cost: cost,
           }

      expect(response).to have_http_status(:unprocessable_entity)
      expect(response).to render_template(current_template)
    end

    it "validates a transport cost option is chosen" do
      post :submit,
           params: {
             transport_type: selected,
             transport_description: description,
             transport_cost: [],
           }

      expect(response).to have_http_status(:unprocessable_entity)
      expect(response).to render_template(current_template)
    end
  end
end
