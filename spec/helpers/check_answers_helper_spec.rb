require "spec_helper"

RSpec.describe CheckAnswersHelper, type: :helper do
  describe "#product_details" do
    let(:products) do
      [{
        "medical_equipment_type" => I18n.t(
          "coronavirus_form.questions.medical_equipment_type.options.number_ppe.label",
        ),
        "product_name" => "Product name",
      }]
    end

    it "adds a link to edit each item" do
      helper.product_details(products).each do |product|
        expect(product[:edit][:href]).to include(product_details_url(product_id: product["product_id"]))
      end
    end

    it "adds a link to delete each item" do
      helper.product_details(products).each do |product|
        expect(product[:delete][:href]).to include("/product-details/#{product['product_id']}/delete")
      end
    end
  end

  describe "#product_info" do
    it "concatenates product information with a line break" do
      product = {
        "medical_equipment_type" => I18n.t(
          "coronavirus_form.questions.medical_equipment_type.options.number_ppe.label",
        ),
        "product_name" => "Product name",
        "equipment_type" => "Equipment type",
        "product_quantity" => 100,
        "product_cost" => 5,
        "certification_details" => "Certification",
        "product_location" => "UK",
        "product_postcode" => "E1 8QS",
        "product_url" => "https://www.example.com",
        "lead_time" => 5,
      }

      expected_answer = "Type: #{product['medical_equipment_type']}<br>" \
                          "Product: #{product['product_name']}<br>" \
                          "Equipment type: #{product['equipment_type']}<br>" \
                          "Quantity: #{product['product_quantity']}<br>" \
                          "Cost: #{product['product_cost']}<br>" \
                          "Certification details: #{product['certification_details']}<br>" \
                          "Location: #{product['product_location']}<br>" \
                          "Postcode: #{product['product_postcode']}<br>" \
                          "URL: #{product['product_url']}<br>" \
                          "Lead time: #{product['lead_time']}"

      expect(helper.product_info(product)).to eq(expected_answer)
    end

    it "only concatenates the fields that have a value" do
      product = {
        "medical_equipment_type" => I18n.t(
          "coronavirus_form.questions.medical_equipment_type.options.number_ppe.label",
        ),
        "product_name" => "Product name",
      }

      expected_answer = "Type: #{product['medical_equipment_type']}<br>Product: #{product['product_name']}"
      expect(helper.product_info(product)).to eq(expected_answer)
    end
  end

  describe "#transport_type" do
    it "adds a query string to the link for each item" do
      helper.transport_type.each do |item|
        expect(item[:edit][:href]).to include("?change-answer")
      end
    end
  end

  describe "#transport_type_info" do
    it "concates transport type and description" do
      session["transport_type"] = [
        I18n.t("coronavirus_form.questions.transport_type.options.moving_people.label"),
        I18n.t("coronavirus_form.questions.transport_type.options.moving_goods.label"),
        I18n.t("coronavirus_form.questions.transport_type.options.other.label"),
      ]

      session["transport_description"] = "Transport description"

      expected_answer = "#{I18n.t('coronavirus_form.questions.transport_type.options.moving_people.label')}, " \
                          "#{I18n.t('coronavirus_form.questions.transport_type.options.moving_goods.label')}, and " \
                          "#{I18n.t('coronavirus_form.questions.transport_type.options.other.label')}<br>" \
                          "#{session['transport_description']}"

      expect(helper.transport_type_info).to eq(expected_answer)
    end

    it "only concatenates the fields that have a value" do
      session["transport_type"] = [
        I18n.t("coronavirus_form.questions.transport_type.options.moving_people.label"),
      ]

      expected_answer = "#{I18n.t('coronavirus_form.questions.transport_type.options.moving_people.label')}<br>"
      expect(helper.transport_type_info).to eq(expected_answer)
    end
  end

  describe "#concat_answer" do
    context "contact_details" do
      let(:question) { "contact_details" }

      it "concatenates contact_details with a line break" do
        answer = {
          "contact_name" => "Snow White",
          "role" => "COO",
          "phone_number" => "012101234567",
          "email" => "me@example.com",
        }

        expected_answer =
          "Name: #{answer['contact_name']}<br>" \
            "Role: #{answer['role']}<br>" \
            "Phone number: #{answer['phone_number']}<br>" \
            "Email: #{answer['email']}"

        expect(helper.concat_answer(answer, question)).to eq(expected_answer)
      end

      it "returns nothing if the contact details are empty" do
        answer = {}

        expect(helper.concat_answer(answer, question)).to be_empty
      end

      it "only concatenates the fields that have a value" do
        answer = {
          "email" => "me@example.com",
        }

        expected_answer = "Email: #{answer['email']}"
        expect(helper.concat_answer(answer, question)).to eq(expected_answer)
      end
    end

    context "business_details" do
      let(:question) { "business_details" }

      it "concatenates business_details with a line break" do
        answer = {
          "company_name" => "Snow White Inc",
          "company_number" => rand(10),
          "company_size" => 1000,
          "company_location" => "UK",
        }

        expected_answer =
          "Company name: #{answer['company_name']}<br>" \
            "Company number: #{answer['company_number']}<br>" \
            "Company size number: #{answer['company_size']}<br>" \
            "Company location: #{answer['company_location']}"

        expect(helper.concat_answer(answer, question)).to eq(expected_answer)
      end

      it "returns nothing if the business details are empty" do
        answer = {}

        expect(helper.concat_answer(answer, question)).to be_empty
      end

      it "only concatenates the fields that have a value" do
        answer = {
          "company_name" => "Snow White Inc",
        }

        expected_answer = "Company name: #{answer['company_name']}"
        expect(helper.concat_answer(answer, question)).to eq(expected_answer)
      end
    end

    context "general multipart questions" do
      let(:question) { "question" }

      it "concates other hash questions" do
        answer = {
          "one" => "One",
          "two" => "Two",
          "three" => "Three",
        }

        expected_answer = "One Two Three"
        expect(helper.concat_answer(answer, question)).to eq(expected_answer)
      end
    end
  end
end
