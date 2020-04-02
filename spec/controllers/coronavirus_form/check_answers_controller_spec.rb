# frozen_string_literal: true

require "spec_helper"

RSpec.describe CoronavirusForm::CheckAnswersController, type: :controller do
  include_examples "session expiry"

  let(:current_template) { "coronavirus_form/check_answers" }

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
    before do
      allow_any_instance_of(described_class).to receive(:reference_number).and_return("abc")
    end

    it "saves the form response to the database" do
      session["attribute"] = "key"
      post :submit

      expect(FormResponse.first.form_response).to eq(
        [%w[attribute key], %w[reference_number abc]],
      )
    end

    it "resets session" do
      post :submit
      expect(session.to_hash).to eq({})
    end

    it "redirects to thank you if sucessfully creates record" do
      post :submit

      expect(response).to redirect_to({
        controller: "thank_you",
        action: "show",
        params: { reference_number: "abc" },
      })
    end
  end
end
