# frozen_string_literal: true

require "spec_helper"

RSpec.describe CoronavirusForm::ProductDetailsController, type: :controller do
  include_examples "session expiry"

  let(:current_template) { "coronavirus_form/product_details" }
  let(:session_key) { :product_details }
  let(:product_id) { SecureRandom.uuid }
  let(:params) do
    {
      product_id: product_id,
      product_name: "Hand sanitizer",
      equipment_type: I18n.t("coronavirus_form.questions.product_details.equipment_type.options.hand_gel.label"),
      product_quantity: "100",
      product_cost: "10.99",
      certification_details: "CE",
      product_location: "United Kingdom",
      product_postcode: "SW1A2AA",
      product_url: nil,
      lead_time: "2",
    }
  end

  describe "GET show" do
    it "renders the form when first question answered" do
      session[:medical_equipment] = I18n.t("coronavirus_form.questions.medical_equipment.options.option_yes.label")
      get :show, params: { product_id: product_id }
      expect(response).to render_template(current_template)
    end

    it "redirects to first question when first question not answered" do
      get :show
      expect(response).to redirect_to(medical_equipment_path)
    end

    context "when there are existing products" do
      let(:product_id) { SecureRandom.uuid }
      let(:product) {
        params.merge(
          product_id: product_id,
          product_name: "My product",
        )
      }
      before :each do
        session["medical_equipment"] = I18n.t("coronavirus_form.questions.medical_equipment.options.option_yes.label")
        session[session_key] = [
          product,
          params.merge(product_id: SecureRandom.uuid),
        ]
      end

      context "when editing an existing product" do
        it "should render the existing product" do
          get :show, params: { product_id: product_id }
          expect(@controller.instance_variable_get(:@product)).to eq(product)
        end
      end

      context "when adding an additional product" do
        it "should not render an existing product" do
          get :show
          expect(@controller.instance_variable_get(:@product)).to eq({})
        end
      end

      context "when providing an unknown product_id" do
        it "should not render an existing product" do
          get :show, params: { product_id: SecureRandom.uuid }
          expect(@controller.instance_variable_get(:@product)).to eq({})
        end
      end
    end
  end

  describe "GET destroy" do
    let(:product_1) do
      params.merge(product_id: product_id)
    end
    let(:product_2) do
      params.merge(product_id: SecureRandom.uuid)
    end
    before :each do
      session[session_key] = [product_1, product_2]
    end
    it "deletes a product" do
      get :destroy, params: { id: product_id }
      expect(session[session_key]).to contain_exactly(product_2)
    end

    it "redirects to the check answers page" do
      get :destroy, params: { id: product_id }
      expect(response).to redirect_to(check_your_answers_path)
    end
  end

  describe "POST submit" do
    before :each do
      session[session_key] = [{
        product_id: product_id,
        medical_equipment_type: I18n.t(
          "coronavirus_form.questions.medical_equipment_type.options.number_testing_equipment.label",
        ),
      }]
    end

    it "sets session variables" do
      post :submit, params: params

      uuid_regex = /\A[0-9a-f]{8}-[0-9a-f]{4}-[1-5][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}\Z/i.freeze

      expect(session[session_key].last).to include params
      expect(session[session_key].last[:product_id]).to match uuid_regex
    end

    context "there are existing products" do
      let(:product_id) { SecureRandom.uuid }
      let(:product) {
        params.merge(
          product_id: product_id,
          product_name: "My product",
        )
      }
      let(:product_2) {
        params.merge(product_id: SecureRandom.uuid)
      }

      before :each do
        session[session_key] = [product, product_2]
      end

      context "when editing an existing product" do
        let(:new_product) { product.merge(product_name: "New name") }
        it "edits the existing the existing product" do
          post :submit, params: new_product
          expect(session[session_key]).to contain_exactly(new_product, product_2)
          expect(response).to redirect_to(additional_product_path)
        end
      end

      context "when adding a new product" do
        let(:new_product) {
          product.except(:product_id).merge(product_name: "New product")
        }
        it "edits the existing the existing product" do
          post :submit, params: new_product
          expect(session[session_key]).to include(product, product_2)
          expect(session[session_key].last).to include(new_product)
          expect(response).to redirect_to(additional_product_path)
        end
      end

      it "redirects to check your answers if check your answers previously seen" do
        session[:check_answers_seen] = true
        post :submit, params: params

        expect(response).to redirect_to(check_your_answers_path)
      end
    end

    context "when there are not existing products" do
      before :each do
        session[:product_details] = [{
          product_id: product_id,
          medical_equipment_type: "Some field",
        }]
      end

      it "redirects to next step when given valid product details" do
        post :submit, params: params

        expect(response).to redirect_to(additional_product_path)
      end

      described_class::REQUIRED_FIELDS.each do |field|
        it "requires that key #{field} be provided" do
          post :submit, params: params.except(field.to_sym)

          expect(response).to have_http_status(:unprocessable_entity)
          expect(response).to render_template(current_template)
        end
      end

      it "requires that product postcode be provided only if product is in UK" do
        post :submit, params: params.merge(product_postcode: nil)
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response).to render_template(current_template)

        post :submit, params: params.merge(product_postcode: "SW1A2AA")
        expect(response).to redirect_to(additional_product_path)
      end

      it "removes extra whitespace from the product postcode" do
        post :submit, params: params.merge(product_postcode: "SW1A 2AA")

        expect(session[:product_details].first[:product_postcode]).to eq("SW1A2AA")
      end

      it "validates valid text is provided" do
        post :submit, params: params.merge({ product_postcode: "<script></script>" })

        expect(response).to have_http_status(:unprocessable_entity)
        expect(response).to render_template(current_template)
      end

      context "product_quantity" do
        it "errors if the user doesn't provide a product_quantity" do
          post :submit, params: params.except(:product_quantity)
          expect(response).to have_http_status(:unprocessable_entity)
          expect(response).to render_template(current_template)
        end

        it "errors if the user enters an invalid product quantity" do
          post :submit, params: params.merge(product_quantity: "Ten")
          expect(response).to have_http_status(:unprocessable_entity)
          expect(response).to render_template(current_template)
        end

        it "errors if the product quantity is below zero" do
          post :submit, params: params.merge(product_quantity: "-10")
          expect(response).to have_http_status(:unprocessable_entity)
          expect(response).to render_template(current_template)
        end
      end

      context "product_cost" do
        it "errors if the user doesn't provide a product_cost" do
          post :submit, params: params.except(:product_cost)
          expect(response).to have_http_status(:unprocessable_entity)
          expect(response).to render_template(current_template)
        end

        it "errors if the user enters an invalid product_cost" do
          post :submit, params: params.merge(product_cost: "Ten pounds")
          expect(response).to have_http_status(:unprocessable_entity)
          expect(response).to render_template(current_template)
        end

        it "errors if the product_cost is below zero" do
          post :submit, params: params.merge(product_cost: "-10")
          expect(response).to have_http_status(:unprocessable_entity)
          expect(response).to render_template(current_template)
        end

        it "errors if the product_cost has more than two decimal places" do
          post :submit, params: params.merge(product_cost: "10.99999")
          expect(response).to have_http_status(:unprocessable_entity)
          expect(response).to render_template(current_template)
        end

        it "allows the product_cost to be zero" do
          post :submit, params: params.merge(product_cost: "0")
          expect(response).to redirect_to(additional_product_path)
        end

        it "removes £ from product_cost" do
          post :submit, params: params.merge(product_cost: "£10.99")
          expect(session[:product_details].first[:product_cost]).to eq("10.99")
        end

        it "removes words from product_cost" do
          post :submit, params: params.merge(product_cost: "10.99 GBP")
          expect(session[:product_details].first[:product_cost]).to eq("10.99")
        end
      end

      context "lead_time" do
        it "errors if the user doesn't provide a lead_time" do
          post :submit, params: params.except(:lead_time)
          expect(response).to have_http_status(:unprocessable_entity)
          expect(response).to render_template(current_template)
        end

        it "errors if the user enters an invalid lead_time" do
          post :submit, params: params.merge(lead_time: "Ten days")
          expect(response).to have_http_status(:unprocessable_entity)
          expect(response).to render_template(current_template)
        end

        it "errors if the lead_time is below zero" do
          post :submit, params: params.merge(lead_time: "-10")
          expect(response).to have_http_status(:unprocessable_entity)
          expect(response).to render_template(current_template)
        end

        it "allows the lead_time to be zero" do
          post :submit, params: params.merge(lead_time: "0")
          expect(response).to redirect_to(additional_product_path)
        end

        it "removes words from lead_time" do
          post :submit, params: params.merge(lead_time: "10 days")
          expect(session[:product_details].first[:lead_time]).to eq("10")
        end
      end
    end

    context "when the user has selected PPE" do
      before :each do
        session[session_key] = [{
          product_id: product_id,
          medical_equipment_type: I18n.t(
            "coronavirus_form.questions.medical_equipment_type.options.number_ppe.label",
          ),
        }]
      end

      it "errors if the user has selected has not told us the equipment type" do
        post :submit, params: params.except(:equipment_type)

        expect(response).to have_http_status(:unprocessable_entity)
        expect(response).to render_template(current_template)
      end

      it "redirects to next step if we're given the equipment type" do
        post :submit, params: params

        expect(response).to redirect_to(additional_product_path)
      end

      it "saves equipment type when given" do
        post :submit, params: params.merge(equipment_type: "Gloves")

        expect(session[session_key].first[:equipment_type]).to eq "Gloves"
      end
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
