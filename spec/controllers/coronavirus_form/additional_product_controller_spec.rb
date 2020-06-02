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

  describe "#previous_path" do
    context "products have been added" do
      it "includes a query parameter for the last added product" do
        session["product_details"] = [{ product_id: "first" }, { product_id: "last" }]
        expect(URI.parse(@controller.send(:previous_path)).request_uri).to eq("/product-details?product_id=last")
      end
    end

    context "products have not been added" do
      it "returns a link to the previous page" do
        expect(URI.parse(@controller.send(:previous_path)).request_uri).to eq("/product-details")
      end
    end
  end

  describe "POST submit" do
    it "redirects to next step for yes response" do
      post :submit, params: { additional_product: I18n.t("coronavirus_form.questions.additional_product.options.option_yes.label") }
      expect(response).to redirect_to(medical_equipment_type_path)
    end

    it "redirects to next sub-question for no response" do
      post :submit, params: { additional_product: I18n.t("coronavirus_form.questions.additional_product.options.option_no.label") }

      expect(response).to redirect_to(accommodation_path)
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

      expect(response).to have_http_status(:unprocessable_entity)
      expect(response).to render_template(current_template)
    end

    it "validates a valid option is chosen" do
      post :submit, params: { additional_product: "<script></script>" }

      expect(response).to have_http_status(:unprocessable_entity)
      expect(response).to render_template(current_template)
    end
  end
end
