require "spec_helper"

RSpec.describe CheckAnswersHelper, type: :helper do
  let(:answers_to_skippable_questions) do
    {
      are_you_a_manufacturer: [
        I18n.t("coronavirus_form.questions.are_you_a_manufacturer.options.manufacturer.label"),
      ],
      additional_product: I18n.t("coronavirus_form.questions.additional_product.options.option_no.label"),
      rooms_number: "100",
      accommodation_cost: I18n.t("coronavirus_form.questions.how_much_charge.options").map { |_, item| item[:label] }.sample,
      transport_type: [
        I18n.t("coronavirus_form.questions.transport_type.options.moving_people.label"),
      ],
      transport_cost: I18n.t("coronavirus_form.questions.how_much_charge.options").map { |_, item| item[:label] }.sample,
      offer_space_type: I18n.t("coronavirus_form.questions.offer_space_type.options.warehouse_space.label"),
      space_cost: I18n.t("coronavirus_form.questions.how_much_charge.options").map { |_, item| item[:label] }.sample,
      offer_care_qualifications: I18n.t("coronavirus_form.questions.offer_care_qualifications.offer_care_type.options.adult_care.label"),
      care_cost: I18n.t("coronavirus_form.questions.how_much_charge.options").map { |_, item| item[:label] }.sample,
      offer_staff_type: [
        I18n.t("coronavirus_form.questions.offer_staff_type.offer_staff_type.options.developers.label"),
      ],
      offer_staff_charge: I18n.t("coronavirus_form.questions.how_much_charge.options").map { |_, item| item[:label] }.sample,
    }
  end

  let(:products) do
    {
      product_details: [{
        medical_equipment_type: I18n.t(
          "coronavirus_form.questions.medical_equipment_type.options.number_ppe.label",
        ),
        product_name: "Product name",
      }],
    }
  end

  describe "#items" do
    it "adds a link to edit each item" do
      helper.items.each do |item|
        expect(item[:edit][:href]).to include("?change-answer")
      end
    end

    it "has an entry for each regular question" do
      session.merge!(answers_to_skippable_questions)

      questions.each do |question|
        unless question.in? %w[medical_equipment_type product_details]
          expect(helper.items.pluck(:field)).to include(I18n.t("coronavirus_form.questions.#{question}.title"))
        end
      end
    end

    it "includes an entry for product_details" do
      session.merge!(products)

      questions.each do |question|
        if question == "product_details"
          expect(helper.items.pluck(:field)).to include(a_string_matching(/#{session["product_details"].first["product_name"]}/))
        end
      end
    end

    it "doesn't include questions that the user has skipped" do
      questions.each do |question|
        if question.in? CheckAnswersHelper::SKIPPABLE_QUESTIONS
          expect(helper.items.pluck(:field)).to_not include(I18n.t("coronavirus_form.questions.#{question}.title"))
        end
      end
    end
  end

  describe "#additional_product_index" do
    it "finds the index of the additional_product question" do
      session.merge!(answers_to_skippable_questions)

      expect(helper.additional_product_index).to eq(2)
    end
  end

  describe "#product_details" do
    before do
      session.merge!(products)
    end

    it "adds a link to edit each item" do
      helper.product_details.each do |product|
        expect(product[:edit][:href]).to include(product_details_url(product_id: product["product_id"]))
      end
    end

    it "adds a link to delete each item" do
      helper.product_details.each do |product|
        expect(product[:delete][:href]).to include("/product-details/#{product[:product_id]}/delete")
      end
    end
  end

  describe "#product_info" do
    it "concatenates product information with a line break" do
      product = {
        medical_equipment_type: I18n.t(
          "coronavirus_form.questions.medical_equipment_type.options.number_ppe.label",
        ),
        product_name: "Product name",
        equipment_type: "Equipment type",
        product_quantity: 100,
        product_cost: 5,
        certification_details: "Certification",
        product_location: "UK",
        product_postcode: "E1 8QS",
        product_url: "https://www.example.com",
        lead_time: 5,
      }

      expected_answer = "Type: #{product[:medical_equipment_type]}<br>" \
                          "Product: #{product[:product_name]}<br>" \
                          "Equipment type: #{product[:equipment_type]}<br>" \
                          "Quantity: #{product[:product_quantity]}<br>" \
                          "Cost: #{product[:product_cost]}<br>" \
                          "Certification details: #{product[:certification_details]}<br>" \
                          "Location: #{product[:product_location]}<br>" \
                          "Postcode: #{product[:product_postcode]}<br>" \
                          "URL: #{product[:product_url]}<br>" \
                          "Lead time: #{product[:lead_time]}"

      expect(helper.product_info(product)).to eq(expected_answer)
    end

    it "only concatenates the fields that have a value" do
      product = {
        medical_equipment_type: I18n.t(
          "coronavirus_form.questions.medical_equipment_type.options.number_ppe.label",
        ),
        product_name: "Product name",
      }

      expected_answer = "Type: #{product[:medical_equipment_type]}<br>Product: #{product[:product_name]}"
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

  describe "#offer_care_qualifications" do
    it "adds a query string to the link for each item" do
      helper.offer_care_qualifications.each do |item|
        expect(item[:edit][:href]).to include("?change-answer")
      end
    end
  end

  describe "#concat_answer" do
    context "contact_details" do
      let(:question) { "contact_details" }

      it "concatenates contact_details with a line break" do
        answer = {
          contact_name: "Snow White",
          role: "COO",
          phone_number: "012101234567",
          email: "me@example.com",
        }

        expected_answer =
          "Name: #{answer[:contact_name]}<br>" \
            "Role: #{answer[:role]}<br>" \
            "Phone number: #{answer[:phone_number]}<br>" \
            "Email: #{answer[:email]}"

        expect(helper.concat_answer(answer, question)).to eq(expected_answer)
      end

      it "returns nothing if the contact details are empty" do
        answer = {}

        expect(helper.concat_answer(answer, question)).to be_empty
      end

      it "only concatenates the fields that have a value" do
        answer = {
          email: "me@example.com",
        }

        expected_answer = "Email: #{answer[:email]}"
        expect(helper.concat_answer(answer, question)).to eq(expected_answer)
      end
    end

    context "business_details" do
      let(:question) { "business_details" }

      it "concatenates business_details with a line break" do
        answer = {
          company_name: "Snow White Inc",
          company_number: rand(10),
          company_size: 1000,
          company_location: "UK",
          company_postcode: "E1 8QS",
        }

        expected_answer =
          "Company name: #{answer[:company_name]}<br>" \
            "Company number: #{answer[:company_number]}<br>" \
            "Company size number: #{answer[:company_size]}<br>" \
            "Company location: #{answer[:company_location]}<br>" \
            "Company postcode: #{answer[:company_postcode]}"

        expect(helper.concat_answer(answer, question)).to eq(expected_answer)
      end

      it "returns nothing if the business details are empty" do
        answer = {}

        expect(helper.concat_answer(answer, question)).to be_empty
      end

      it "only concatenates the fields that have a value" do
        answer = {
          company_name: "Snow White Inc",
        }

        expected_answer = "Company name: #{answer[:company_name]}"
        expect(helper.concat_answer(answer, question)).to eq(expected_answer)
      end
    end

    context "general multipart questions" do
      let(:question) { "question" }

      it "concates other hash questions" do
        answer = {
          one: "One",
          two: "Two",
          three: "Three",
        }

        expected_answer = "One Two Three"
        expect(helper.concat_answer(answer, question)).to eq(expected_answer)
      end
    end
  end

  describe "#how_much_charge" do
    it "links the user back to the page the question appeared on" do
      helper.how_much_charge("question", "parent_question") do |item|
        expect(item[:edit][:href]).to include("parent-question?change-answer")
      end
    end
  end
end
