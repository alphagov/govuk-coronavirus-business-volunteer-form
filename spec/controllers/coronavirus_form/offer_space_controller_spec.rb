# frozen_string_literal: true

require "spec_helper"

RSpec.describe CoronavirusForm::OfferSpaceController, type: :controller do
  include_examples "session expiry"

  let(:current_template) { "coronavirus_form/offer_space" }
  let(:session_key) { :offer_space }

  describe "GET show" do
    it "renders the form when first question answered" do
      session["accommodation"] = I18n.t("coronavirus_form.questions.accommodation.options.option_yes.label")

      get :show
      expect(response).to render_template(current_template)
    end

    it "redirects to first question when first question not answered" do
      get :show
      expect(response).to redirect_to(accommodation_path)
    end
  end

  describe "POST submit" do
    let(:selected) { permitted_values.sample }
    let(:permitted_values) do
      I18n.t("coronavirus_form.questions.offer_space.options").map { |_, item| item[:label] }
    end
    let(:selected_yes) { I18n.t("coronavirus_form.questions.offer_space.options.option_yes.label") }
    let(:selected_no) { I18n.t("coronavirus_form.questions.offer_space.options.option_no.label") }

    it "sets session variables" do
      post :submit, params: { offer_space: selected }
      expect(session[session_key]).to eq selected
    end

    it "redirects to next step for a 'No' response" do
      post :submit, params: { offer_space: selected_no }
      expect(response).to redirect_to(offer_staff_path)
    end

    it "clears previously entered answers given a 'No' response" do
      session[:offer_space_type] = permitted_values
      session[:general_space_description] = "Gludwch destun ar hap yma."
      session[:space_cost] = I18n.t("coronavirus_form.how_much_charge.options").map { |_, item| item[:label] }.sample
      session[:offer_space_type_other] = "Gludwch destun ar hap yma."
      session[:warehouse_space_description] = "Gludwch destun ar hap yma."
      session[:office_space_description] = "Gludwch destun ar hap yma."

      post :submit, params: { offer_space: selected_no }

      expect(session[:offer_space_type]).to be nil
      expect(session[:general_space_description]).to be nil
      expect(session[:space_cost]).to be nil
      expect(session[:offer_space_type_other]).to be nil
      expect(session[:warehouse_space_description]).to be nil
      expect(session[:office_space_description]).to be nil
    end

    it "redirects to next step for a 'Yes' response" do
      post :submit, params: { offer_space: selected_yes }
      expect(response).to redirect_to(offer_space_type_path)
    end

    it "redirects to check your answers if check your answers previously seen" do
      session[:check_answers_seen] = true
      post :submit, params: { offer_space: selected_no }

      expect(response).to redirect_to(check_your_answers_path)
    end

    it "redirects to check your answers if answer is Yes regardless of check your answers state" do
      session[:check_answers_seen] = true
      post :submit, params: { offer_space: selected_yes }

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
