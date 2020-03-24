# frozen_string_literal: true

require "spec_helper"

RSpec.describe CoronavirusForm::CheckAnswersController, type: :controller do
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
      @time = Time.zone.local(2020, 11, 1, 3, 3, 3)
      allow_any_instance_of(described_class).to receive(:reference_number).and_return("abc")
      allow_any_instance_of(ActiveSupport::TimeZone).to receive(:now).and_return(@time)
    end

    it "saves the form response to the database" do
      session["attribute"] = "key"
      post :submit

      expect(FormResponse.first).to have_attributes(
        ReferenceId: "abc",
        UnixTimestamp: @time,
        FormResponse: { "attribute": "key", "reference_id": "abc" },
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
