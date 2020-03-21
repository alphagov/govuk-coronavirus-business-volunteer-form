# frozen_string_literal: true

require "spec_helper"

RSpec.describe CoronavirusForm::OfferCareController, type: :controller do
  let(:current_template) { "coronavirus_form/offer_care" }
  let(:session_key) { :offer_care }

  describe "GET show" do
    it "renders the form" do
      get :show
      expect(response).to render_template(current_template)
    end
  end

  describe "POST submit" do
    let(:selected_yes) { I18n.t("coronavirus_form.offer_care.options.option_yes.label") }
    let(:selected_no) { I18n.t("coronavirus_form.offer_care.options.option_no.label") }
    let(:permitted_values) do
      I18n.t("coronavirus_form.offer_care.options").map { |_, item| item[:label] }
    end

    it "sets session variables" do
      post :submit, params: { offer_care: selected_yes }
      expect(session[session_key]).to eq selected_yes
    end

    it "redirects to check your answers if check your answers previously seen" do
      session[:check_answers_seen] = true
      post :submit, params: { offer_care: selected_yes }

      expect(response).to redirect_to(coronavirus_form_check_your_answers_path)
    end

    it "validates any option is chosen" do
      post :submit, params: { offer_care: "" }

      expect(response).to render_template(current_template)
    end

    it "validates a valid option is chosen" do
      post :submit, params: { offer_care: "<script></script>" }

      expect(response).to render_template(current_template)
    end
  end
end
