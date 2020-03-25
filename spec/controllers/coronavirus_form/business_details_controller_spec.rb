# frozen_string_literal: true

require "spec_helper"

RSpec.describe CoronavirusForm::BusinessDetailsController, type: :controller do
  let(:current_template) { "coronavirus_form/business_details" }
  let(:session_key) { :business_details }

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
    let(:params) do
      {
        company_name: "My Company Ltd",
        company_number: "1234",
        company_size: "under_50_people",
        company_location: "united_kingdom",
      }
    end

    it "sets session variables" do
      post :submit, params: params

      expect(session[:business_details]).to eq params.stringify_keys
    end

    it "redirects to next step" do
      post :submit, params: params

      expect(response).to redirect_to(contact_details_path)
    end

    it "redirects to check your answers if check your answers already seen" do
      session[:check_answers_seen] = true
      post :submit, params: params

      expect(response).to redirect_to(check_your_answers_path)
    end

    it "validates company name is entered" do
      post :submit, params: { company_name: "" }

      expect(response).to render_template(current_template)
    end

    it "validates company size option is chosen" do
      post :submit, params: { company_size: "" }

      expect(response).to render_template(current_template)
    end

    it "validates company location option is chosen" do
      post :submit, params: { company_location: "" }

      expect(response).to render_template(current_template)
    end

    described_class::TEXT_FIELDS.each do |field|
      it "validates that #{field} is 1000 or fewer characters" do
        params[field] = SecureRandom.hex(1001)
        post :submit, params: params

        expect(response).to render_template(current_template)
      end
    end
  end
end
