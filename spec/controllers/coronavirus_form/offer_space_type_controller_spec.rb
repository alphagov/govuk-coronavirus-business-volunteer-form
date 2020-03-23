# frozen_string_literal: true

require "spec_helper"

RSpec.describe CoronavirusForm::OfferSpaceTypeController, type: :controller do
  let(:current_template) { "coronavirus_form/offer_space_type" }
  let(:session_key) { :offer_space_type }

  describe "GET show" do
    it "renders the form" do
      get :show
      expect(response).to render_template(current_template)
    end
  end

  describe "POST submit" do
    let(:selected) { ["Warehouse space", "Office space"] }
    it "sets session variables" do
      post :submit, params: { offer_space_type: selected }

      expect(session[session_key]).to eq selected
    end

    it "redirects to next step" do
      post :submit, params: { offer_space_type: selected }

      expect(response).to redirect_to(expert_advice_path)
    end

    it "redirects to check your answers if check your answers already seen" do
      session[:check_answers_seen] = true
      post :submit, params: { offer_space_type: selected }

      expect(response).to redirect_to("/check-your-answers")
    end

    context "when Other option is selected" do
      it "validates the Other option description is provided" do
        post :submit, params: { offer_space_type: ["Other", "Office space"] }

        expect(response).to render_template(current_template)
      end

      it "adds the other option description to the session" do
        post :submit, params: {
          offer_space_type: ["Other", "Office space"],
          offer_space_type_other: "A really big garden.",
        }

        expect(response).to redirect_to(expert_advice_path)
        expect(session[session_key]).to eq ["Other", "Office space"]
        expect(session[:offer_space_type_other]).to eq "A really big garden."
      end
    end

    it "validates any option is chosen" do
      post :submit, params: { offer_space: "" }

      expect(response).to render_template(current_template)
    end

    it "validates a valid option is chosen" do
      post :submit, params: { offer_space: "<script></script>" }

      expect(response).to render_template(current_template)
    end

    it "redirects to check your answers if check your answers previously seen" do
      session[:check_answers_seen] = true
      post :submit, params: { offer_space_type: selected }

      expect(response).to redirect_to(check_your_answers_path)
    end
  end
end
