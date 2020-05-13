# frozen_string_literal: true

require "spec_helper"

RSpec.describe CoronavirusForm::OfferTransportController, type: :controller do
  include_examples "session expiry"

  let(:current_template) { "coronavirus_form/offer_transport" }
  let(:session_key) { :offer_transport }

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
    let(:selected_yes) { I18n.t("coronavirus_form.questions.offer_transport.options.option_yes.label") }
    let(:selected_no) { I18n.t("coronavirus_form.questions.offer_transport.options.option_no.label") }

    it "sets session variables" do
      post :submit, params: { offer_transport: selected_yes }
      expect(session[session_key]).to eq selected_yes
    end

    it "redirects to next step for a YES response" do
      post :submit, params: { offer_transport: selected_yes }
      expect(response).to redirect_to(transport_type_path)
    end

    it "redirects to next step for a NO response" do
      post :submit, params: { offer_transport: selected_no }
      expect(response).to redirect_to(offer_space_path)
    end

    it "clears previously entered transport cost for a NO response" do
      session[:transport_cost] = I18n.t("coronavirus_form.questions.how_much_charge.options").map { |_, item| item[:label] }.sample

      post :submit, params: { offer_transport: selected_no }

      expect(session[:transport_cost]).to be nil
    end

    it "redirects to check your answers if answer = NO and check your answers previously seen" do
      session[:check_answers_seen] = true
      post :submit, params: { offer_transport: selected_no }

      expect(response).to redirect_to(check_your_answers_path)
    end

    it "redirects to next step if answer = Yes even if check your answers previously seen" do
      session[:check_answers_seen] = true
      post :submit, params: { offer_transport: selected_yes }

      expect(response).to redirect_to(transport_type_path)
    end

    it "validates any option is chosen" do
      post :submit, params: { offer_transport: "" }

      expect(response).to have_http_status(:unprocessable_entity)
      expect(response).to render_template(current_template)
    end

    it "validates a valid option is chosen" do
      post :submit, params: { offer_transport: "<script></script>" }

      expect(response).to have_http_status(:unprocessable_entity)
      expect(response).to render_template(current_template)
    end
  end
end
