# frozen_string_literal: true

require "spec_helper"

RSpec.describe CoronavirusForm::LocationController, type: :controller do
  let(:current_template) { "coronavirus_form/location" }
  let(:session_key) { :location }

  describe "GET show" do
    it "renders the form when first question answered" do
      session["medical_equipment"] = "Yes"
      get :show
      expect(response).to render_template(current_template)
    end

    it "redirects to first question when first question not answered" do
      get :show
      expect(response).to redirect_to({
        controller: "medical_equipment",
        action: "show",
      })
    end
  end

  describe "POST submit" do
    let(:options) do
      I18n.t("coronavirus_form.questions.location.options").map { |_, item| item[:label] }
    end
    let(:selected) { [options, [options.sample]].sample }

    it "sets session variables" do
      post :submit, params: { location: selected }

      expect(session[session_key]).to eq selected
    end

    it "redirects to next step" do
      post :submit, params: { location: selected }

      expect(response).to redirect_to(business_details_path)
    end

    it "redirects to check your answers if check your answers previously seen" do
      session[:check_answers_seen] = true
      post :submit, params: { location: selected }

      expect(response).to redirect_to(check_your_answers_path)
    end

    it "validates any option is chosen" do
      post :submit, params: { location: [] }

      expect(response).to render_template(current_template)
    end

    it "validates a valid option is chosen" do
      post :submit, params: { location: ["<script></script", "invalid option", "Medical equipment"] }

      expect(response).to render_template(current_template)
    end
  end
end
