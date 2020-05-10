# frozen_string_literal: true

require "spec_helper"

RSpec.describe CoronavirusForm::OfferStaffTypeController, type: :controller do
  include_examples "session expiry"

  let(:current_template) { "coronavirus_form/offer_staff_type" }
  let(:session_key) { :offer_staff_type }

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
    let(:selected) do
      [
        I18n.t("coronavirus_form.questions.offer_staff_type.offer_staff_type.options.cleaners.label"),
        I18n.t("coronavirus_form.questions.offer_staff_type.offer_staff_type.options.developers.label"),
      ]
    end

    let(:params) do
      {
        offer_staff_type: [
          I18n.t("coronavirus_form.questions.offer_staff_type.offer_staff_type.options.cleaners.label"),
          I18n.t("coronavirus_form.questions.offer_staff_type.offer_staff_type.options.developers.label"),
          I18n.t("coronavirus_form.questions.offer_staff_type.offer_staff_type.options.medical_staff.label"),
          I18n.t("coronavirus_form.questions.offer_staff_type.offer_staff_type.options.office_staff.label"),
          I18n.t("coronavirus_form.questions.offer_staff_type.offer_staff_type.options.security_staff.label"),
          I18n.t("coronavirus_form.questions.offer_staff_type.offer_staff_type.options.trainers.label"),
          I18n.t("coronavirus_form.questions.offer_staff_type.offer_staff_type.options.translators.label"),
          I18n.t("coronavirus_form.questions.offer_staff_type.offer_staff_type.options.other_staff.label"),
        ],
        cleaners_number: "20",
        developers_number: "10",
        medical_staff_number: "10",
        office_staff_number: "20",
        security_staff_number: "30",
        trainers_number: "20",
        translators_number: "10",
        other_staff_number: "30",
        offer_staff_description: "Some description",
        offer_staff_charge: "A standard price",
      }
    end

    it "sets session variables" do
      post :submit, params: params

      expected_number_hash = {
        cleaners_number: params[:cleaners_number],
        developers_number: params[:developers_number],
        medical_staff_number: params[:medical_staff_number],
        office_staff_number: params[:office_staff_number],
        security_staff_number: params[:security_staff_number],
        trainers_number: params[:trainers_number],
        translators_number: params[:translators_number],
        other_staff_number: params[:other_staff_number],
      }

      expect(session[:offer_staff_type]).to eq params[:offer_staff_type]
      expect(session[:offer_staff_description]).to eq params[:offer_staff_description]
      expect(session[:offer_staff_charge]).to eq params[:offer_staff_charge]
      expect(session[:offer_staff_number]).to eq expected_number_hash
    end

    it "redirects to next step" do
      post :submit, params: params

      expect(response).to redirect_to(expert_advice_type_path)
    end

    it "redirects to check your answers if check your answers already seen" do
      session[:check_answers_seen] = true
      post :submit, params: params

      expect(response).to redirect_to("/check-your-answers")
    end

    described_class::OPTIONS.each do |(option_id, option)|
      context "when the option #{option_id} is selected" do
        description_id = option.dig(:description, :id).to_sym

        context "when the option #{option_id} is not provided" do
          let(:acceptable_params) do
            params.merge(
              offer_staff_type: params[:offer_staff_type].reject do |type|
                type == option.dig(:label)
              end,
            ).except(description_id)
          end
          it "doesn't require the number field #{description_id}" do
            post :submit, params: acceptable_params
            expect(response).to redirect_to(expert_advice_type_path)
          end
        end

        context "when the corresponding number field #{description_id} is not provided" do
          it "won't accept the input" do
            post :submit, params: params.except(description_id)
            expect(response).to have_http_status(:unprocessable_entity)
            expect(response).to render_template(current_template)
          end
        end
      end
    end

    it "validates any option is chosen" do
      post :submit, params: { offer_staff_type: "" }

      expect(response).to have_http_status(:unprocessable_entity)
      expect(response).to render_template(current_template)
    end

    it "validates a type of staff is chosen" do
      post :submit, params: params.except(:offer_staff_type)

      expect(response).to have_http_status(:unprocessable_entity)
      expect(response).to render_template(current_template)
    end

    it "validates a charge radio button is chosen" do
      post :submit, params: params.except(:offer_staff_charge)

      expect(response).to have_http_status(:unprocessable_entity)
      expect(response).to render_template(current_template)
    end

    it "redirects to check your answers if check your answers previously seen" do
      session[:check_answers_seen] = true
      post :submit, params: params

      expect(response).to redirect_to(check_your_answers_path)
    end
  end
end
