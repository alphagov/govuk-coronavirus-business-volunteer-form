require "spec_helper"

RSpec.describe CheckAnswersHelper, type: :helper do
  let(:answers_to_skippable_questions) do
    {
      rooms_number: "100",
      accommodation_cost: I18n.t("coronavirus_form.how_much_charge.options").map { |_, item| item[:label] }.sample,
      transport_type: [
        I18n.t("coronavirus_form.questions.transport_type.options.moving_people.label"),
      ],
      transport_cost: I18n.t("coronavirus_form.how_much_charge.options").map { |_, item| item[:label] }.sample,
      offer_space_type: I18n.t("coronavirus_form.questions.offer_space_type.options.warehouse_space.label"),
      space_cost: I18n.t("coronavirus_form.how_much_charge.options").map { |_, item| item[:label] }.sample,
      offer_care_qualifications: I18n.t("coronavirus_form.questions.offer_care_qualifications.offer_care_type.options.adult_care.label"),
      care_cost: I18n.t("coronavirus_form.how_much_charge.options").map { |_, item| item[:label] }.sample,
      offer_staff_type: [
        I18n.t("coronavirus_form.questions.offer_staff_type.offer_staff_type.options.developers.label"),
      ],
      offer_staff_charge: I18n.t("coronavirus_form.how_much_charge.options").map { |_, item| item[:label] }.sample,
      construction_services: I18n.t("coronavirus_form.questions.construction_services.options").map { |_, item| item[:label] },
      construction_services_other: "Build all the things",
      construction_cost: I18n.t("coronavirus_form.how_much_charge.options").map { |_, item| item[:label] }.sample,
      it_services: I18n.t("coronavirus_form.questions.it_services.options").map { |_, item| item[:label] },
      it_services_other: "Supply all the things",
      it_cost: I18n.t("coronavirus_form.how_much_charge.options").map { |_, item| item[:label] }.sample,
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
        unless question.in? CheckAnswersHelper::EXCLUDED_QUESTIONS
          expect(helper.items.pluck(:field)).to include(I18n.t("coronavirus_form.questions.#{question}.title"))
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
          company_is_uk_registered: "Yes",
          company_number: "AB123456",
          company_size: 1000,
          company_location: "UK",
          company_postcode: "E1 8QS",
        }

        expected_answer =
          "Company name: #{answer[:company_name]}<br>" \
            "Company registered in the UK: #{answer[:company_is_uk_registered]}<br>" \
            "Company number: #{answer[:company_number]}<br>" \
            "Company size number: #{answer[:company_size]}<br>" \
            "Company location: #{answer[:company_location]}<br>" \
            "Company postcode: #{answer[:company_postcode]}"

        expect(helper.concat_answer(answer, question)).to eq(expected_answer)
      end

      context "company_is_uk_registered" do
        it "returns only company_is_uk_registered if all other business detail fields have no value" do
          answer = {
            company_is_uk_registered: "No",
          }

          expected_answer = "Company registered in the UK: No"
          expect(helper.concat_answer(answer, question)).to eq(expected_answer)
        end

        it "only concatenates the other business detail fields that have a value" do
          answer = {
            company_name: "Snow White Inc",
            company_is_uk_registered: "No",
          }

          expected_answer = "Company name: #{answer[:company_name]}<br>Company registered in the UK: No"
          expect(helper.concat_answer(answer, question)).to eq(expected_answer)
        end
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

  describe "#link_to_parent_page" do
    it "links the user back to the page the question appeared on" do
      helper.link_to_parent_page("question", "parent_question") do |item|
        expect(item[:edit][:href]).to include("parent-question?change-answer")
      end
    end
  end
end
