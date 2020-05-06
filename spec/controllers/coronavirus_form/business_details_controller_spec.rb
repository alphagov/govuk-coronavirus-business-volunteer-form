# frozen_string_literal: true

require "spec_helper"

RSpec.describe CoronavirusForm::BusinessDetailsController, type: :controller do
  include_examples "session expiry"

  let(:current_template) { "coronavirus_form/business_details" }
  let(:session_key) { :business_details }

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
    let(:params) do
      {
        company_name: "My Company Ltd",
        company_number: "1234",
        company_size: "under_50_people",
        company_location: "united_kingdom",
        company_postcode: "AB11AA",
      }
    end

    it "sets session variables" do
      post :submit, params: params

      expect(session[:business_details]).to eq params
    end

    it "removes extra whitespace from the postcode" do
      post :submit, params: params.merge(company_postcode: "AB1 1AA")

      expect(session[:business_details][:company_postcode]).to eq "AB11AA"
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
      post :submit, params: params.merge(company_name: "")

      expect(response).to have_http_status(:unprocessable_entity)
      expect(response).to render_template(current_template)
    end

    it "validates company size option is chosen" do
      post :submit, params: params.merge(company_size: "")

      expect(response).to have_http_status(:unprocessable_entity)
      expect(response).to render_template(current_template)
    end

    it "validates company location option is chosen" do
      post :submit, params: params.merge(company_location: "")

      expect(response).to have_http_status(:unprocessable_entity)
      expect(response).to render_template(current_template)
    end

    it "does not require postcode is provided if company location is not UK" do
      post :submit, params: params.merge(
        company_location: I18n.t("coronavirus_form.questions.business_details.company_location.options.european_union.label"),
      ).except(:company_postcode)

      expect(response).to redirect_to(contact_details_path)
    end

    it "validates postcode is provided if company location is UK" do
      post :submit, params: params.merge(
        company_location: I18n.t("coronavirus_form.questions.business_details.company_location.options.united_kingdom.label"),
      ).except(:company_postcode)

      expect(response).to have_http_status(:unprocessable_entity)
      expect(response).to render_template(current_template)
    end

    it "redirects to next step when a valid postcode is provided" do
      valid_postcodes = [
        "AA9A 9AA",
        "A9A 9AA",
        "A9 9AA",
        "A99 9AA",
        "AA9 9AA",
        "AA99 9AA",
        "BFPO 1",
        "BFPO 9",
      ]

      valid_postcodes.each do |postcode|
        post :submit, params: params.merge(
          company_location: I18n.t("coronavirus_form.questions.business_details.company_location.options.united_kingdom.label"),
          company_postcode: postcode,
        )

        expect(response).to redirect_to(contact_details_path)
      end
    end

    it "does not redirect to next step when postcode is invalid" do
      post :submit, params: params.merge(
        company_location: I18n.t("coronavirus_form.questions.business_details.company_location.options.united_kingdom.label"),
        company_postcode: "AAA1 1AA",
      )

      expect(response).to have_http_status(:unprocessable_entity)
      expect(response).to render_template(current_template)
    end

    described_class::TEXT_FIELDS.each do |field|
      it "validates that #{field} is 1000 or fewer characters" do
        params[field] = SecureRandom.hex(1001)
        post :submit, params: params

        expect(response).to have_http_status(:unprocessable_entity)
        expect(response).to render_template(current_template)
      end
    end
  end
end
