# frozen_string_literal: true

require "spec_helper"

RSpec.describe CoronavirusForm::TransportTypeController, type: :controller do
  let(:current_template) { "coronavirus_form/transport_type" }
  let(:session_key) { :transport_type }
  let(:session_key_text) { :transport_description }

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
      I18n.t("coronavirus_form.questions.transport_type.options").map { |_, item| item[:label] }
    end
    let(:selected) { [options, [options.sample]].sample }
    let(:description) { "Something" }

    it "sets session variables" do
      post :submit, params: {
        transport_type: selected,
      transport_description: description,
    }

      expect(session[session_key]).to eq selected
      expect(session[session_key_text]).to eq description
    end

    it "redirects to next step" do
      post :submit, params: {
        transport_type: selected,
        transport_description: description,
      }

      expect(response).to redirect_to(offer_space_path)
    end

    it "redirects to check your answers if check your answers previously seen" do
      session[:check_answers_seen] = true
      post :submit, params: {
        transport_type: selected,
      transport_description: description,
}

      expect(response).to redirect_to("/check-your-answers")
    end

    it "validates any option is chosen" do
      post :submit, params: { transport_type: [] }

      expect(response).to render_template(current_template)
    end

    it "validates a valid option is chosen" do
      post :submit, params: { transport_type: ["<script></script", "invalid option", "Medical equipment"] }

      expect(response).to render_template(current_template)
    end

    it "validates a description is entered" do
      session[:check_answers_seen] = true
      post :submit, params: {
        transport_type: selected,
      transport_description: "",
}

      expect(response).to render_template(current_template)
    end
  end
end
