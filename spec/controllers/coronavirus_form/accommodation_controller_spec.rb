# frozen_string_literal: true

require "spec_helper"

RSpec.describe CoronavirusForm::AccommodationController, type: :controller do
  include_examples "session expiry"

  let(:current_template) { "coronavirus_form/accommodation" }
  let(:session_key) { :accommodation }

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
      I18n.t("coronavirus_form.questions.accommodation.options").map { |_, item| item[:label] }
    end

    it "sets session variables" do
      post :submit, params: { accommodation: selected }
      expect(session[session_key]).to eq selected
    end

    it "redirects to room numbers for a yes stay in response" do
      post :submit, params: { accommodation: I18n.t("coronavirus_form.questions.accommodation.options.yes_staying_in.label") }
      expect(response).to redirect_to(rooms_number_path)
    end

    it "redirects to room numbers for a yes all uses response" do
      post :submit, params: { accommodation: I18n.t("coronavirus_form.questions.accommodation.options.yes_all_uses.label") }
      expect(response).to redirect_to(rooms_number_path)
    end

    it "redirects to transport for a no response" do
      post :submit, params: { accommodation: I18n.t("coronavirus_form.questions.accommodation.options.no_option.label") }
      expect(response).to redirect_to(offer_transport_path)
    end

    it "clears previously entered care cost for a 'No' response" do
      session[:accommodation_cost] = I18n.t("coronavirus_form.questions.how_much_charge.options").map { |_, item| item[:label] }.sample

      post :submit, params: { accommodation: I18n.t("coronavirus_form.questions.accommodation.options.no_option.label") }

      expect(session[:accommodation_cost]).to be nil
    end

    it "redirects to check your answers if check your answers previously seen and answer is no" do
      session[:check_answers_seen] = true
      post :submit, params: { accommodation: I18n.t("coronavirus_form.questions.accommodation.options.no_option.label") }

      expect(response).to redirect_to(check_your_answers_path)
    end

    it "validates any option is chosen" do
      post :submit, params: { accommodation: "" }

      expect(response).to have_http_status(:unprocessable_entity)
      expect(response).to render_template(current_template)
    end

    it "validates a valid option is chosen" do
      post :submit, params: { accommodation: "<script></script>" }

      expect(response).to have_http_status(:unprocessable_entity)
      expect(response).to render_template(current_template)
    end
  end
end
