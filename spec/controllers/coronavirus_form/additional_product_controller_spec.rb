# frozen_string_literal: true

require "spec_helper"

RSpec.describe CoronavirusForm::AdditionalProductController, type: :controller do
  include_examples "session expiry"

  let(:current_template) { "coronavirus_form/additional_product" }

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
    it "redirects to next step for yes response" do
      post :submit, params: { additional_product: I18n.t("coronavirus_form.questions.additional_product.options.option_yes.label") }
      expect(response).to redirect_to(medical_equipment_type_path)
    end

    it "redirects to next sub-question for no response" do
      post :submit, params: { additional_product: I18n.t("coronavirus_form.questions.additional_product.options.option_no.label") }

      expect(response).to redirect_to(hotel_rooms_path)
    end

    it "redirects to check your answers if check your answers previously seen" do
      session[:check_answers_seen] = true
      post :submit, params: { additional_product: I18n.t("coronavirus_form.questions.additional_product.options.option_no.label") }

      expect(response).to redirect_to(check_your_answers_path)
    end

    it "does not redirect to check your answers if answers seen but additional product selected" do
      session[:check_answers_seen] = true
      post :submit, params: { additional_product: I18n.t("coronavirus_form.questions.additional_product.options.option_yes.label") }

      expect(response).to redirect_to(medical_equipment_type_path)
    end

    it "validates any option is chosen" do
      post :submit, params: { additional_product: "" }

      expect(response).to render_template(current_template)
    end

    it "validates a valid option is chosen" do
      post :submit, params: { additional_product: "<script></script>" }

      expect(response).to render_template(current_template)
    end
  end
end
