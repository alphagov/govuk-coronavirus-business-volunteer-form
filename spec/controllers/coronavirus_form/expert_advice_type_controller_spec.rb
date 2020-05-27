# frozen_string_literal: true

require "spec_helper"

RSpec.describe CoronavirusForm::ExpertAdviceTypeController, type: :controller do
  include_examples "session expiry"

  let(:current_template) { "coronavirus_form/expert_advice_type" }
  let(:session_key) { :expert_advice_type }

  describe "GET show" do
    it "renders the form" do
      session["medical_equipment"] = I18n.t("coronavirus_form.questions.medical_equipment.options.option_yes.label")
      get :show
      expect(response).to render_template(current_template)
    end
  end

  describe "POST submit" do
    let(:options) do
      I18n.t("coronavirus_form.questions.expert_advice_type.options").map { |_, item| item[:label] }
    end
    let(:selected) { options.first(2) }
    it "sets session variables" do
      post :submit, params: { expert_advice_type: selected }

      expect(session[session_key]).to eq selected
    end

    describe "#next_page" do
      it "redirects to construction_services path if construction has been selected" do
        post :submit, params: { expert_advice_type: [I18n.t("coronavirus_form.questions.expert_advice_type.options.construction.label")] }

        expect(response).to redirect_to(construction_services_path)
      end

      it "redirects to construction_services path if both construction and IT have been selected" do
        post :submit,
             params: {
               expert_advice_type: [
                 I18n.t("coronavirus_form.questions.expert_advice_type.options.construction.label"),
                 I18n.t("coronavirus_form.questions.expert_advice_type.options.it.label"),
               ],
             }

        expect(response).to redirect_to(construction_services_path)
      end

      it "redirects to it_services path if IT has been selected but construction has not" do
        post :submit, params: { expert_advice_type: [I18n.t("coronavirus_form.questions.expert_advice_type.options.it.label")] }

        expect(response).to redirect_to(it_services_path)
      end

      it "redirects to offer_care path if neither construction or IT has been selected" do
        post :submit, params: { expert_advice_type: selected }

        expect(response).to redirect_to(offer_care_path)
      end

      it "redirects to check your answers if check your answers already seen" do
        session[:check_answers_seen] = true
        post :submit, params: { expert_advice_type: selected }

        expect(response).to redirect_to(check_your_answers_path)
      end

      context "user changes answer to expert_advice_type" do
        before do
          session[:check_answers_seen] = true
        end

        it "asks IT services questions if the construction questions have already been answered" do
          session[:expert_advice_type] = [I18n.t("coronavirus_form.questions.expert_advice_type.options.construction.label")]
          session[:construction_services] = [I18n.t("coronavirus_form.questions.construction_services.options.building_materials.label")]

          post :submit,
               params: {
                 expert_advice_type: [
                   I18n.t("coronavirus_form.questions.expert_advice_type.options.construction.label"),
                   I18n.t("coronavirus_form.questions.expert_advice_type.options.it.label"),
                 ],
               }

          expect(response).to redirect_to(it_services_path)
        end

        it "redirects to check your answers if the construction and IT services questions have already been answered" do
          session[:expert_advice_type] = [
            I18n.t("coronavirus_form.questions.expert_advice_type.options.construction.label"),
            I18n.t("coronavirus_form.questions.expert_advice_type.options.it.label"),
          ]
          session[:construction_services] = [I18n.t("coronavirus_form.questions.construction_services.options.building_materials.label")]
          session[:it_services] = [I18n.t("coronavirus_form.questions.it_services.options.broadband.label")]

          post :submit,
               params: {
                 expert_advice_type: [
                   I18n.t("coronavirus_form.questions.expert_advice_type.options.medical.label"),
                   I18n.t("coronavirus_form.questions.expert_advice_type.options.construction.label"),
                   I18n.t("coronavirus_form.questions.expert_advice_type.options.it.label"),
                 ],
               }

          expect(response).to redirect_to(check_your_answers_path)
        end
      end
    end

    it "clears previously entered construction data if construction is no longer selected" do
      session[:construction_services] = I18n.t("coronavirus_form.questions.construction_services.options").map { |_, item| item[:label] }.sample
      session[:construction_services_other] = "Foo"
      session[:construction_cost] = I18n.t("coronavirus_form.questions.how_much_charge.options").map { |_, item| item[:label] }.sample

      post :submit, params: { expert_advice_type: selected }

      expect(session[:construction_services]).to be nil
      expect(session[:construction_services_other]).to be nil
      expect(session[:construction_cost]).to be nil
    end

    it "clears previously entered it_cost if construction is no longer selected" do
      session[:it_services] = I18n.t("coronavirus_form.questions.it_services.options").map { |_, item| item[:label] }.sample
      session[:it_services_other] = "Foo"
      session[:it_cost] = I18n.t("coronavirus_form.questions.how_much_charge.options").map { |_, item| item[:label] }.sample

      post :submit, params: { expert_advice_type: selected }

      expect(session[:it_services]).to be nil
      expect(session[:it_services_other]).to be nil
      expect(session[:it_cost]).to be nil
    end

    it "validates any option is chosen" do
      post :submit, params: { expert_advice_type: [] }

      expect(response).to have_http_status(:unprocessable_entity)
      expect(response).to render_template(current_template)
    end

    context "when Other option is selected" do
      it "validates the Other option description is provided" do
        post :submit, params: { expert_advice_type: [I18n.t("coronavirus_form.questions.expert_advice_type.options.other.label")] }

        expect(response).to have_http_status(:unprocessable_entity)
        expect(response).to render_template(current_template)
      end

      it "adds the other option description to the session" do
        post :submit,
             params: {
               expert_advice_type: [I18n.t("coronavirus_form.questions.expert_advice_type.options.other.label")] + selected,
               expert_advice_type_other: "Demo text",
             }

        expect(session[session_key]).to eq [I18n.t("coronavirus_form.questions.expert_advice_type.options.other.label")] + selected
        expect(session[:expert_advice_type_other]).to eq "Demo text"
        expect(response).to redirect_to(offer_care_path)
      end
    end

    it "validates a valid option is chosen" do
      post :submit,
           params: {
             expert_advice_type: ["<script></script", "invalid option"],
           }

      expect(response).to have_http_status(:unprocessable_entity)
      expect(response).to render_template(current_template)
    end

    it "validates only valid options are chosen" do
      post :submit,
           params: {
             expert_advice_type: ["<script></script", "invalid option"] + selected,
           }

      expect(response).to have_http_status(:unprocessable_entity)
      expect(response).to render_template(current_template)
    end

    it "validates only the exclusive option is selected" do
      post :submit, params: { expert_advice_type: [I18n.t("coronavirus_form.questions.expert_advice_type.options.no_expertise.label")] + selected }

      expect(response).to have_http_status(:unprocessable_entity)
      expect(response).to render_template(current_template)
    end

    described_class::TEXT_FIELDS.each do |field|
      it "validates that #{field} is 1000 or fewer characters" do
        params = { expert_advice_type: %w[Other] }
        params[field] = SecureRandom.hex(1001)
        post :submit, params: params

        expect(response).to have_http_status(:unprocessable_entity)
        expect(response).to render_template(current_template)
      end
    end
  end
end
