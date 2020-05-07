# frozen_string_literal: true

require "spec_helper"

RSpec.describe CoronavirusForm::ConstructionServicesController, type: :controller do
  include_examples "session expiry"

  let(:current_template) { "coronavirus_form/construction_services" }
  let(:session_key) { :construction_services }

  describe "GET show" do
    it "renders the form" do
      session["medical_equipment"] = I18n.t("coronavirus_form.questions.medical_equipment.options.option_yes.label")
      get :show
      expect(response).to render_template(current_template)
    end
  end

  describe "POST submit" do
    let(:options) do
      I18n.t("coronavirus_form.questions.construction_services.options").map { |_, item| item[:label] }
    end
    let(:selected) { options.first(2) }
    it "sets session variables" do
      post :submit, params: { construction_services: selected }

      expect(session[session_key]).to eq selected
    end

    it "redirects to next step" do
      post :submit, params: { construction_services: selected }

      expect(response).to redirect_to(offer_care_path)
    end

    it "redirects to check your answers if check your answers already seen" do
      session[:check_answers_seen] = true
      post :submit, params: { construction_services: selected }

      expect(response).to redirect_to(check_your_answers_path)
    end

    it "validates any option is chosen" do
      post :submit, params: { construction_services: [] }

      expect(response).to have_http_status(:unprocessable_entity)
      expect(response).to render_template(current_template)
    end

    it "adds the other option description to the session" do
      post :submit, params: {
        construction_services: selected,
        construction_services_other: "Demo text",
      }

      expect(session[session_key]).to eq selected
      expect(session[:construction_services_other]).to eq "Demo text"
      expect(response).to redirect_to(offer_care_path)
    end

    described_class::TEXT_FIELDS.each do |field|
      it "validates that #{field} is 1000 or fewer characters" do
        params = { construction_services: selected }
        params[field] = SecureRandom.hex(1001)
        post :submit, params: params

        expect(response).to have_http_status(:unprocessable_entity)
        expect(response).to render_template(current_template)
      end
    end
  end
end
