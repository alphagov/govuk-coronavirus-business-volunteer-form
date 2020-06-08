# frozen_string_literal: true

require "spec_helper"

RSpec.describe CoronavirusForm::ItServicesController, type: :controller do
  include_examples "session expiry"

  let(:current_template) { "coronavirus_form/it_services" }

  describe "GET show" do
    it "renders the form" do
      session["medical_equipment"] = I18n.t("coronavirus_form.questions.medical_equipment.options.option_yes.label")
      get :show
      expect(response).to render_template(current_template)
    end
  end

  describe "POST submit" do
    let(:options) do
      I18n.t("coronavirus_form.questions.it_services.options").map { |_, item| item[:label] }
    end
    let(:selected) { options.first(2) }

    let(:cost) do
      I18n.t("coronavirus_form.how_much_charge.options").map { |_, item| item[:label] }.sample
    end

    it "sets session variables" do
      post :submit,
           params: {
             it_services: selected,
             it_services_other: "Demo text",
             it_cost: cost,
           }

      expect(session[:it_services]).to eq selected
      expect(session[:it_services_other]).to eq "Demo text"
      expect(session[:it_cost]).to eq cost
    end

    it "redirects to next step" do
      post :submit,
           params: {
             it_services: selected,
             it_cost: cost,
           }

      expect(response).to redirect_to(offer_care_path)
    end

    it "redirects to check your answers if check your answers already seen" do
      session[:check_answers_seen] = true
      post :submit,
           params: {
             it_services: selected,
             it_cost: cost,
           }

      expect(response).to redirect_to(check_your_answers_path)
    end

    it "validates any it services option is chosen" do
      post :submit,
           params: {
             it_services: [],
             it_cost: cost,
           }

      expect(response).to have_http_status(:unprocessable_entity)
      expect(response).to render_template(current_template)
    end

    it "validates an it cost option is chosen" do
      post :submit, params: { it_services: selected }

      expect(response).to have_http_status(:unprocessable_entity)
      expect(response).to render_template(current_template)
    end

    described_class::TEXT_FIELDS.each do |field|
      it "validates that #{field} is 1000 or fewer characters" do
        params = {
          it_services: selected,
          it_cost: cost,
        }
        params[field] = SecureRandom.hex(1001)
        post :submit, params: params

        expect(response).to have_http_status(:unprocessable_entity)
        expect(response).to render_template(current_template)
      end
    end
  end
end
