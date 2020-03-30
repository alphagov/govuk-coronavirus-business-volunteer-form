# frozen_string_literal: true

require "spec_helper"

RSpec.describe CoronavirusForm::ProductDetailsController, type: :controller do
  let(:current_template) { "coronavirus_form/product_details" }
  let(:session_key) { :product_details }
  let(:product_id) { SecureRandom.uuid }
  let(:params) do
    {
      "product_id" => product_id,
      "product_name" => "Defibrillator",
      "product_quantity" => "100",
      "product_cost" => "£10.99",
      "certification_details" => "CE",
      "product_location" => "United Kingdom",
      "product_postcode" => "SW1A 2AA",
      "product_url" => nil,
      "lead_time" => "2",
    }
  end

  describe "GET show" do
    it "renders the form when first question answered" do
      session["medical_equipment"] = "Yes"
      get :show, params: { product_id: product_id }
      expect(response).to render_template(current_template)
    end

    it "redirects to first question when first question not answered" do
      get :show
      expect(response).to redirect_to({
        controller: "medical_equipment",
        action: "show",
      })
    end

    context "when there are existing products" do
      let(:product_id) { SecureRandom.uuid }
      let(:product) {
        params.merge(
          "product_id" => product_id,
          "product_name" => "My product",
        )
      }
      before :each do
        session["medical_equipment"] = "Yes"
        session[session_key] = [
          product,
          params.merge("product_id" => SecureRandom.uuid),
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
      params.merge("product_id" => product_id)
    end
    let(:product_2) do
      params.merge("product_id" => SecureRandom.uuid)
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
        "product_id" => product_id,
        "medical_equipment_type" => I18n.t(
          "coronavirus_form.medical_equipment_type.options.number_ppe.label",
        ),
      }]
    end

    it "sets session variables" do
      post :submit, params: params

      uuid_regex = /\A[0-9a-f]{8}-[0-9a-f]{4}-[1-5][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}\Z/i.freeze

      expect(session[session_key].last).to include params
      expect(session[session_key].last["product_id"]).to match uuid_regex
    end

    context "there are existing products" do
      let(:product_id) { SecureRandom.uuid }
      let(:product) {
        params.merge(
          "product_id" => product_id,
          "product_name" => "My product",
          "equipment_type" => nil,
        )
      }
      let(:product_2) {
        params.merge("product_id" => SecureRandom.uuid, "equipment_type" => nil)
      }

      before :each do
        session[session_key] = [product, product_2]
      end

      context "when editing an existing product" do
        let(:new_product) { product.merge("product_name" => "New name") }
        it "edits the existing the existing product" do
          post :submit, params: new_product
          expect(session[session_key]).to contain_exactly(new_product, product_2)
          expect(response).to redirect_to(additional_product_path)
        end
      end

      context "when adding a new product" do
        let(:new_product) {
          product.except("product_id").merge("product_name" => "New product")
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
          "product_id" => product_id,
          "medical_equipment_type" => "Some field",
        }]
      end

      it "redirects to next step when given valid product details" do
        post :submit, params: params

        expect(response).to redirect_to(additional_product_path)
      end

      described_class::REQUIRED_FIELDS.each do |field|
        it "requires that key #{field} be provided" do
          post :submit, params: params.except(field)

          expect(response).to render_template(current_template)
        end
      end

      it "requires that product postcode be provided only if product is in UK" do
        post :submit, params: params.merge("product_postcode" => nil)
        expect(response).to render_template(current_template)

        post :submit, params: params.merge("product_postcode" => "SW1A 2AA")
        expect(response).to redirect_to(additional_product_path)
      end

      it "validates valid text is provided" do
        post :submit, params: params.merge({ "product_postcode": "<script></script>" })

        expect(response).to render_template(current_template)
      end
    end

    context "when the user has selected PPE" do
      before :each do
        session[session_key] = [{
          "product_id" => product_id,
          "medical_equipment_type" => I18n.t(
            "coronavirus_form.questions.medical_equipment_type.options.number_ppe.label",
          ),
        }]
      end

      it "errors if the user has selected has not told us the equipment type" do
        post :submit, params: params

        expect(response).to render_template(current_template)
      end

      it "redirects to next step if we're given the equipment type" do
        post :submit, params: params.merge("equipment_type" => "Gloves")

        expect(response).to redirect_to(additional_product_path)
      end

      it "saves equipment type when given" do
        post :submit, params: params.merge("equipment_type" => "Gloves")

        expect(session[session_key].first["equipment_type"]).to eq "Gloves"
      end
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
