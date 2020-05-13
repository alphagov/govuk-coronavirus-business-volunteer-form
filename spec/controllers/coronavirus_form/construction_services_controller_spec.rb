# frozen_string_literal: true

require "spec_helper"

RSpec.describe CoronavirusForm::ConstructionServicesController, type: :controller do
  include_examples "session expiry"

  let(:current_template) { "coronavirus_form/construction_services" }

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

    let(:cost) do
      I18n.t("coronavirus_form.questions.how_much_charge.options").map { |_, item| item[:label] }.sample
    end

    it "sets session variables" do
      post :submit,
           params: {
             construction_services: selected,
             construction_services_other: "Demo text",
             construction_cost: cost,
           }

      expect(session[:construction_services]).to eq selected
      expect(session[:construction_services_other]).to eq "Demo text"
      expect(session[:construction_cost]).to eq cost
    end

    describe "#next_page" do
      it "redirects to it_services path if IT was been selected on expert_advice_type page" do
        session[:expert_advice_type] = [I18n.t("coronavirus_form.questions.expert_advice_type.options.it.label")]
        post :submit,
             params: {
               construction_services: selected,
               construction_cost: cost,
             }

        expect(response).to redirect_to(it_services_path)
      end

      it "redirects to offer_care path if IT was not selected on expert_advice_type page" do
        post :submit,
             params: {
               construction_services: selected,
               construction_cost: cost,
             }

        expect(response).to redirect_to(offer_care_path)
      end

      it "redirects to check your answers if check your answers already seen" do
        session[:check_answers_seen] = true
        post :submit,
             params: {
               construction_services: selected,
               construction_cost: cost,
             }

        expect(response).to redirect_to(check_your_answers_path)
      end

      it "redirects to check your answers if user has already answered the IT services question" do
        session[:check_answers_seen] = true
        session[:expert_advice_type] = [I18n.t("coronavirus_form.questions.expert_advice_type.options.it.label")]
        session[:it_services] = [I18n.t("coronavirus_form.questions.it_services.options.broadband.label")]

        post :submit,
             params: {
               construction_services: selected,
               construction_cost: cost,
             }

        expect(response).to redirect_to(check_your_answers_path)
      end

      it "redirects to it_services_path user has not answered the IT questions but check your answers has been seen" do
        session[:check_answers_seen] = true
        session[:expert_advice_type] = [I18n.t("coronavirus_form.questions.expert_advice_type.options.it.label")]

        post :submit,
             params: {
               construction_services: selected,
               construction_cost: cost,
             }

        expect(response).to redirect_to(it_services_path)
      end
    end

    it "validates any construction services option is chosen" do
      post :submit,
           params: {
             construction_services: [],
             construction_cost: cost,
           }

      expect(response).to have_http_status(:unprocessable_entity)
      expect(response).to render_template(current_template)
    end

    it "validates a construction services cost option is chosen" do
      post :submit, params: { construction_services: selected }

      expect(response).to have_http_status(:unprocessable_entity)
      expect(response).to render_template(current_template)
    end

    described_class::TEXT_FIELDS.each do |field|
      it "validates that #{field} is 1000 or fewer characters" do
        params = {
          construction_services: selected,
          construction_cost: cost,
        }
        params[field] = SecureRandom.hex(1001)
        post :submit, params: params

        expect(response).to have_http_status(:unprocessable_entity)
        expect(response).to render_template(current_template)
      end
    end
  end
end
