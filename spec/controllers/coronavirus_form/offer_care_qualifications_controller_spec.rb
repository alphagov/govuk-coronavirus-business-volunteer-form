# frozen_string_literal: true

require "spec_helper"

RSpec.describe CoronavirusForm::OfferCareQualificationsController, type: :controller do
  include_examples "session expiry"

  let(:current_template) { "coronavirus_form/offer_care_qualifications" }
  let(:session_key_type) { :offer_care_type }
  let(:session_key_qualifcation) { :offer_care_qualifications }
  let(:session_key_cost) { :care_cost }

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
    let(:selected_type) { [I18n.t("coronavirus_form.questions.offer_care_qualifications.offer_care_type.options.adult_care.label")] }
    let(:selected_qualification) { [I18n.t("coronavirus_form.questions.offer_care_qualifications.care_qualifications.options.dbs_check.label")] }
    let(:selected_care_cost) { I18n.t("coronavirus_form.questions.how_much_charge.options").map { |_, item| item[:label] }.sample }

    it "sets session variables" do
      post :submit,
           params: {
             offer_care_type: selected_type,
             offer_care_qualifications: selected_qualification,
             care_cost: selected_care_cost,
           }

      expect(session[session_key_type]).to eq selected_type
      expect(session[session_key_qualifcation]).to eq selected_qualification
      expect(session[session_key_cost]).to eq selected_care_cost
    end

    it "redirects to next step" do
      post :submit,
           params: {
             offer_care_type: selected_type,
             offer_care_qualifications: selected_qualification,
             care_cost: selected_care_cost,
           }
      expect(response).to redirect_to(offer_other_support_path)
    end

    it "redirects to check your answers if check your answers already seen" do
      session[:check_answers_seen] = true
      post :submit,
           params: {
             offer_care_type: selected_type,
             offer_care_qualifications: selected_qualification,
             care_cost: selected_care_cost,
           }
      expect(response).to redirect_to(check_your_answers_path)
    end

    it "validates any care type is chosen" do
      post :submit,
           params: {
             offer_care_type: [],
             offer_care_qualifications: selected_qualification,
             care_cost: selected_care_cost,
           }
      expect(response).to have_http_status(:unprocessable_entity)
      expect(response).to render_template(current_template)
    end

    it "validates any qualification is chosen" do
      post :submit,
           params: {
             offer_care_type: selected_type,
             offer_care_qualifications: [],
             care_cost: selected_care_cost,
           }
      expect(response).to have_http_status(:unprocessable_entity)
      expect(response).to render_template(current_template)
    end

    context "when Nursing or other healthcare qualification option is selected" do
      it "validates the Nursing or other healthcare qualification option description is provided" do
        post :submit,
             params: {
               offer_care_type: selected_type,
               offer_care_qualifications: [
                 I18n.t("coronavirus_form.questions.offer_care_qualifications.care_qualifications.options.dbs_check.label"),
                 I18n.t("coronavirus_form.questions.offer_care_qualifications.care_qualifications.options.nursing_or_healthcare_qualification.label"),
               ],
               care_cost: selected_care_cost,
             }
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response).to render_template(current_template)
      end

      it "adds the details to the session" do
        post :submit,
             params: {
               offer_care_type: selected_type,
               offer_care_qualifications: [
                 I18n.t("coronavirus_form.questions.offer_care_qualifications.care_qualifications.options.dbs_check.label"),
                 I18n.t("coronavirus_form.questions.offer_care_qualifications.care_qualifications.options.nursing_or_healthcare_qualification.label"),
               ],
               offer_care_qualifications_type: "Registered Nurse",
               care_cost: selected_care_cost,
             }

        expect(response).to redirect_to(offer_other_support_path)
        expect(session[session_key_qualifcation]).to eq [
          I18n.t("coronavirus_form.questions.offer_care_qualifications.care_qualifications.options.dbs_check.label"),
          I18n.t("coronavirus_form.questions.offer_care_qualifications.care_qualifications.options.nursing_or_healthcare_qualification.label"),
        ]
        expect(session[:offer_care_qualifications_type]).to eq "Registered Nurse"
      end
    end

    it "validates a valid care type is chosen" do
      post :submit,
           params: {
             offer_care_type: [
               "<script></script",
               "invalid option",
               I18n.t("coronavirus_form.questions.offer_care_qualifications.care_qualifications.options.dbs_check.label"),
             ],
             offer_care_qualifications: selected_qualification,
             care_cost: selected_care_cost,
           }
      expect(response).to have_http_status(:unprocessable_entity)
      expect(response).to render_template(current_template)
    end

    it "validates a valid qualification is chosen" do
      post :submit,
           params: {
             offer_care_type: selected_type,
             offer_care_qualifications: [
               "<script></script",
               "invalid option",
               I18n.t("coronavirus_form.questions.offer_care_qualifications.care_qualifications.options.dbs_check.label"),
             ],
             care_cost: selected_care_cost,
           }
      expect(response).to have_http_status(:unprocessable_entity)
      expect(response).to render_template(current_template)
    end

    it "validates only the exclusive option is selected" do
      post :submit,
           params: {
             offer_care_type: selected_type,
             offer_care_qualifications: [
               I18n.t("coronavirus_form.questions.offer_care_qualifications.care_qualifications.options.dbs_check.label"),
               I18n.t("coronavirus_form.questions.offer_care_qualifications.care_qualifications.options.no_qualification.label"),
             ],
             care_cost: selected_care_cost,
           }
      expect(response).to have_http_status(:unprocessable_entity)
      expect(response).to render_template(current_template)
    end

    it "validates a care cost option is chosen" do
      post :submit,
           params: {
             offer_care_type: selected_type,
             offer_care_qualifications: selected_qualification,
           }

      expect(response).to have_http_status(:unprocessable_entity)
      expect(response).to render_template(current_template)
    end

    described_class::TEXT_FIELDS.each do |field|
      it "validates that #{field} is 1000 or fewer characters" do
        params = {
          offer_care_type: selected_type,
          offer_care_qualifications: [
            I18n.t("coronavirus_form.questions.offer_care_qualifications.care_qualifications.options.dbs_check.label"),
            I18n.t("coronavirus_form.questions.offer_care_qualifications.care_qualifications.options.nursing_or_healthcare_qualification.label"),
          ],
          offer_care_qualifications_type: "Registered Nurse",
          care_cost: selected_care_cost,
        }
        params[field] = SecureRandom.hex(1001)
        post :submit, params: params

        expect(response).to have_http_status(:unprocessable_entity)
        expect(response).to render_template(current_template)
      end
    end
  end
end
