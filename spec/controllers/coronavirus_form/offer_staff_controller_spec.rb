# frozen_string_literal: true

require "spec_helper"

RSpec.describe CoronavirusForm::OfferStaffController, type: :controller do
  include_examples "session expiry"

  let(:current_template) { "coronavirus_form/offer_staff" }
  let(:session_key) { :offer_staff }

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
      I18n.t("coronavirus_form.questions.offer_staff.options").map { |_, item| item[:label] }
    end
    let(:selected_yes) { I18n.t("coronavirus_form.questions.offer_staff.options.option_yes.label") }
    let(:selected_no) { I18n.t("coronavirus_form.questions.offer_staff.options.option_no.label") }

    it "sets session variables" do
      post :submit, params: { offer_staff: selected }
      expect(session[session_key]).to eq selected
    end

    it "redirects to next step for a 'No' response" do
      post :submit, params: { offer_staff: selected_no }
      expect(response).to redirect_to(expert_advice_type_path)
    end

    it "redirects to next step for a 'Yes' response" do
      post :submit, params: { offer_staff: selected_yes }
      expect(response).to redirect_to(offer_staff_type_path)
    end

    it "clears previously entered answers given a 'No' response" do
      session[:offer_staff_type] = permitted_values
      session[:offer_staff_description] = "Gludwch destun ar hap yma."
      session[:offer_staff_number] = 1000
      session[:offer_staff_charge] = I18n.t("coronavirus_form.how_much_charge.options").map { |_, item| item[:label] }.sample

      post :submit, params: { offer_staff: selected_no }

      expect(session[:offer_staff_type]).to be nil
      expect(session[:offer_staff_description]).to be nil
      expect(session[:offer_staff_number]).to be nil
      expect(session[:offer_staff_charge]).to be nil
    end

    it "redirects to check your answers if check your answers previously seen" do
      session[:check_answers_seen] = true
      post :submit, params: { offer_staff: selected_no }

      expect(response).to redirect_to(check_your_answers_path)
    end

    it "redirects to check your answers if answer is Yes regardless of check your answers state" do
      session[:check_answers_seen] = true
      post :submit, params: { offer_staff: selected_yes }

      expect(response).to redirect_to(offer_staff_type_path)
    end

    it "validates any option is chosen" do
      post :submit, params: { offer_staff: "" }

      expect(response).to have_http_status(:unprocessable_entity)
      expect(response).to render_template(current_template)
    end

    it "validates a valid option is chosen" do
      post :submit, params: { offer_staff: "<script></script>" }

      expect(response).to have_http_status(:unprocessable_entity)
      expect(response).to render_template(current_template)
    end
  end
end
