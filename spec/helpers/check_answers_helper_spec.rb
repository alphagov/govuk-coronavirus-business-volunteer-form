require "spec_helper"

RSpec.describe CheckAnswersHelper, type: :helper do
  include FormResponseHelper

  let(:form_data) { valid_data }

  describe "#question_items(question)" do
    it "contains a string" do
      session.merge!(form_data)

      expect(helper.question_items("accommodation")).to eq(
        [
          {
            field: I18n.t("coronavirus_form.questions.accommodation.title"),
            value: form_data[:accommodation],
          },
        ],
      )
    end

    it "contains an array" do
      session.merge!(form_data)

      expect(helper.question_items("location")).to eq(
        [
          {
            field: I18n.t("coronavirus_form.questions.location.title"),
            value: render("govuk_publishing_components/components/list", {
              visible_counters: true,
              items: form_data[:location],
            }),
          },
        ],
      )
    end
  end

  describe "#accommodation_items" do
    it "contains a type field" do
      session.merge!(form_data)

      expect(helper.accommodation_items.pluck(:field))
        .to include(I18n.t("coronavirus_form.check_your_answers.sections.accommodation.type"))
      expect(helper.accommodation_items.pluck(:value))
        .to include(form_data[:rooms_number])
    end

    it "contains a charge field" do
      session.merge!(form_data)

      expect(helper.accommodation_items.pluck(:field))
        .to include(I18n.t("coronavirus_form.check_your_answers.charge"))
      expect(helper.accommodation_items.pluck(:value))
        .to include(form_data[:accommodation_cost])
    end
  end

  describe "#transport_items" do
    it "contains a type field" do
      session.merge!(form_data)

      expected = render("govuk_publishing_components/components/list", {
        visible_counters: true,
        items: form_data[:transport_type],
      })

      expect(helper.transport_items.pluck(:field))
        .to include(I18n.t("coronavirus_form.check_your_answers.sections.transport.type"))
      expect(helper.transport_items.pluck(:value))
        .to include(expected)
    end

    it "contains a description field" do
      session.merge!(form_data)

      expect(helper.transport_items.pluck(:field))
        .to include(I18n.t("coronavirus_form.check_your_answers.sections.transport.description"))
      expect(helper.transport_items.pluck(:value))
        .to include(form_data[:transport_description])
    end

    it "contains a charge field" do
      session.merge!(form_data)

      expect(helper.transport_items.pluck(:field))
        .to include(I18n.t("coronavirus_form.check_your_answers.charge"))
      expect(helper.transport_items.pluck(:value))
        .to include(form_data[:transport_cost])
    end
  end

  describe "#space_items" do
    it "contains a type field" do
      session.merge!(form_data)

      expected = render("govuk_publishing_components/components/list", {
        visible_counters: true,
        items: space_item_value_list,
      })

      expect(helper.space_items.pluck(:field))
        .to include(I18n.t("coronavirus_form.check_your_answers.sections.space.type"))
      expect(helper.space_items.pluck(:value))
        .to include(expected)
    end

    it "contains a description field" do
      session.merge!(form_data)

      expect(helper.space_items.pluck(:field))
        .to include(I18n.t("coronavirus_form.check_your_answers.sections.space.description"))
      expect(helper.space_items.pluck(:value))
        .to include(form_data[:general_space_description])
    end

    it "contains a charge field" do
      session.merge!(form_data)

      expect(helper.space_items.pluck(:field))
        .to include(I18n.t("coronavirus_form.check_your_answers.charge"))
      expect(helper.space_items.pluck(:value))
        .to include(form_data[:space_cost])
    end
  end

  describe "#space_item_value_list" do
    it "returns a list containing all items and values when all items and values are selected by the user" do
      data_copy = form_data.tap do |form_data|
        form_data[:offer_space_type] = ["Warehouse space", "Office space", "Other"]
        form_data[:warehouse_space_description] = 0
        form_data[:office_space_description] = 1
        form_data[:offer_space_type_other] = 1_000_000
      end

      session.merge!(data_copy)

      expect(helper.space_item_value_list).to include("Other (1,000,000 square feet)")
      expect(helper.space_item_value_list).to include("Warehouse space (0 square feet)")
      expect(helper.space_item_value_list).to include("Office space (1 square foot)")
    end

    it "returns a list containing only the items and values selected by the user" do
      data_copy = form_data.tap do |form_data|
        form_data[:offer_space_type] = ["Warehouse space", "Other"]
        form_data[:warehouse_space_description] = 0
        form_data[:office_space_description] = 1
        form_data[:offer_space_type_other] = 1_000_000
      end

      session.merge!(data_copy)

      expect(helper.space_item_value_list).to include("Other (1,000,000 square feet)")
      expect(helper.space_item_value_list).to include("Warehouse space (0 square feet)")
      expect(helper.space_item_value_list.count).to be 2
    end

    it "returns an empty list if no space types have been selected by the user" do
      data_copy = form_data.tap do |form_data|
        form_data[:offer_space_type] = []
      end

      session.merge!(data_copy)

      expect(helper.space_item_value_list.count).to be 0
    end

    it "returns a list where item values default to zero if an item is selected but the value is is not supplied by the user" do
      data_copy = form_data.tap do |form_data|
        form_data[:offer_space_type] = ["Warehouse space", "Office space", "Other"]
        form_data.delete(:warehouse_space_description)
        form_data[:office_space_description] = 1
        form_data[:offer_space_type_other] = 1_000_000
      end

      session.merge!(data_copy)

      expect(helper.space_item_value_list).to include("Other (1,000,000 square feet)")
      expect(helper.space_item_value_list).to include("Warehouse space (0 square feet)")
      expect(helper.space_item_value_list).to include("Office space (1 square foot)")
    end
  end

  describe "#staff_items" do
    it "contains a type field" do
      session.merge!(form_data)

      expected = render("govuk_publishing_components/components/list", {
        visible_counters: true,
        items: staff_item_value_list,
      })

      expect(helper.staff_items.pluck(:field))
        .to include(I18n.t("coronavirus_form.check_your_answers.sections.staff.type"))
      expect(helper.staff_items.pluck(:value))
        .to include(expected)
    end

    it "contains a description field" do
      session.merge!(form_data)

      expect(helper.staff_items.pluck(:field))
        .to include(I18n.t("coronavirus_form.check_your_answers.sections.staff.description"))
      expect(helper.staff_items.pluck(:value))
        .to include(form_data[:offer_staff_description])
    end

    it "contains a charge field" do
      session.merge!(form_data)

      expect(helper.staff_items.pluck(:field))
        .to include(I18n.t("coronavirus_form.check_your_answers.charge"))
      expect(helper.staff_items.pluck(:value))
        .to include(form_data[:offer_staff_charge])
    end
  end

  describe "#staff_item_value_list" do
    it "returns a list containing all items and values when all items and values are selected by the user" do
      data_copy = form_data.tap do |form_data|
        form_data[:offer_staff_type] = [
          "Cleaners",
          "Developers",
          "Medical staff",
          "Office staff",
          "Security staff",
          "Trainers or coaches",
          "Translators",
          "Other staff",
        ]
        form_data[:offer_staff_number][:cleaners_number] = 0
        form_data[:offer_staff_number][:developers_number] = 1
        form_data[:offer_staff_number][:medical_staff_number] = 10
        form_data[:offer_staff_number][:office_staff_number] = 100
        form_data[:offer_staff_number][:security_staff_number] = 1_000
        form_data[:offer_staff_number][:trainers_number] = 10_000
        form_data[:offer_staff_number][:translators_number] = 100_000
        form_data[:offer_staff_number][:other_staff_number] = 1_000_000
      end

      session.merge!(data_copy)

      expect(helper.staff_item_value_list).to include("Cleaners (0 people)")
      expect(helper.staff_item_value_list).to include("Developers (1 person)")
      expect(helper.staff_item_value_list).to include("Medical staff (10 people)")
      expect(helper.staff_item_value_list).to include("Office staff (100 people)")
      expect(helper.staff_item_value_list).to include("Security staff (1,000 people)")
      expect(helper.staff_item_value_list).to include("Trainers or coaches (10,000 people)")
      expect(helper.staff_item_value_list).to include("Translators (100,000 people)")
      expect(helper.staff_item_value_list).to include("Other staff (1,000,000 people)")
    end

    it "returns a list containing only the items and values selected by the user" do
      data_copy = form_data.tap do |form_data|
        form_data[:offer_staff_type] = [
          "Cleaners",
          "Developers",
          "Trainers or coaches",
          "Translators",
          "Other staff",
        ]
        form_data[:offer_staff_number][:cleaners_number] = 0
        form_data[:offer_staff_number][:developers_number] = 1
        form_data[:offer_staff_number][:trainers_number] = 10_000
        form_data[:offer_staff_number][:translators_number] = 100_000
        form_data[:offer_staff_number][:other_staff_number] = 1_000_000
      end

      session.merge!(data_copy)

      expect(helper.staff_item_value_list).to include("Cleaners (0 people)")
      expect(helper.staff_item_value_list).to include("Developers (1 person)")
      expect(helper.staff_item_value_list).to include("Trainers or coaches (10,000 people)")
      expect(helper.staff_item_value_list).to include("Translators (100,000 people)")
      expect(helper.staff_item_value_list).to include("Other staff (1,000,000 people)")
      expect(helper.staff_item_value_list.count).to be 5
    end

    it "returns an empty list if no space types have been selected by the user" do
      data_copy = form_data.tap do |form_data|
        form_data[:offer_staff_type] = []
      end

      session.merge!(data_copy)

      expect(helper.staff_item_value_list.count).to be 0
    end

    it "returns a list where item values default to zero if an item is selected but the value is is not supplied by the user" do
      data_copy = form_data.tap do |form_data|
        form_data[:offer_staff_type] = [
          "Cleaners",
          "Developers",
          "Medical staff",
          "Office staff",
          "Security staff",
          "Trainers or coaches",
          "Translators",
          "Other staff",
        ]
        form_data[:offer_staff_number].delete(:developers_number)
        form_data[:offer_staff_number].delete(:office_staff_number)
        form_data[:offer_staff_number].delete(:trainers_number)
        form_data[:offer_staff_number].delete(:other_staff_number)
        form_data[:offer_staff_number][:cleaners_number] = 0
        form_data[:offer_staff_number][:medical_staff_number] = 1
        form_data[:offer_staff_number][:security_staff_number] = 1_000
        form_data[:offer_staff_number][:translators_number] = 100_000
      end

      session.merge!(data_copy)

      expect(helper.staff_item_value_list).to include("Developers (0 people)")
      expect(helper.staff_item_value_list).to include("Office staff (0 people)")
      expect(helper.staff_item_value_list).to include("Trainers or coaches (0 people)")
      expect(helper.staff_item_value_list).to include("Other staff (0 people)")
      expect(helper.staff_item_value_list).to include("Cleaners (0 people)")
      expect(helper.staff_item_value_list).to include("Medical staff (1 person)")
      expect(helper.staff_item_value_list).to include("Security staff (1,000 people)")
      expect(helper.staff_item_value_list).to include("Translators (100,000 people)")
    end
  end

  describe "#care_items" do
    it "contains a type field" do
      session.merge!(form_data)

      expected = render("govuk_publishing_components/components/list", {
        visible_counters: true,
        items: form_data[:offer_care_type],
      })

      expect(helper.care_items.pluck(:field))
        .to include(I18n.t("coronavirus_form.check_your_answers.sections.care.type"))
      expect(helper.care_items.pluck(:value))
        .to include(expected)
    end

    it "contains a qualifications field" do
      session.merge!(form_data)

      expected = render("govuk_publishing_components/components/list", {
        visible_counters: true,
        items: form_data[:offer_care_qualifications],
      })

      expect(helper.care_items.pluck(:field))
        .to include(I18n.t("coronavirus_form.check_your_answers.sections.care.qualifications"))
      expect(helper.care_items.pluck(:value))
        .to include(expected)
    end

    it "contains a charge field" do
      session.merge!(form_data)

      expect(helper.care_items.pluck(:field))
        .to include(I18n.t("coronavirus_form.check_your_answers.charge"))
      expect(helper.care_items.pluck(:value))
        .to include(form_data[:care_cost])
    end
  end

  describe "#construction_service_items" do
    it "contains a type field" do
      session.merge!(form_data)

      expected = render("govuk_publishing_components/components/list", {
        visible_counters: true,
        items: form_data[:construction_services],
      })

      expect(helper.construction_service_items.pluck(:field))
        .to include(I18n.t("coronavirus_form.check_your_answers.sections.services.construction.type"))
      expect(helper.construction_service_items.pluck(:value))
        .to include(expected)
    end

    it "contains a description field" do
      session.merge!(form_data)

      expect(helper.construction_service_items.pluck(:field))
        .to include(I18n.t("coronavirus_form.check_your_answers.sections.services.construction.description"))
      expect(helper.construction_service_items.pluck(:value))
        .to include(form_data[:construction_services_other])
    end

    it "contains a charge field" do
      session.merge!(form_data)

      expect(helper.construction_service_items.pluck(:field))
        .to include(I18n.t("coronavirus_form.check_your_answers.charge"))
      expect(helper.construction_service_items.pluck(:value))
        .to include(form_data[:construction_cost])
    end
  end

  describe "#it_service_items" do
    it "contains a type field" do
      session.merge!(form_data)

      expected = render("govuk_publishing_components/components/list", {
        visible_counters: true,
        items: form_data[:it_services],
      })

      expect(helper.it_service_items.pluck(:field))
        .to include(I18n.t("coronavirus_form.check_your_answers.sections.services.it.type"))
      expect(helper.it_service_items.pluck(:value))
        .to include(expected)
    end

    it "contains a description field" do
      session.merge!(form_data)

      expect(helper.it_service_items.pluck(:field))
        .to include(I18n.t("coronavirus_form.check_your_answers.sections.services.it.description"))
      expect(helper.it_service_items.pluck(:value))
        .to include(form_data[:it_services_other])
    end

    it "contains a charge field" do
      session.merge!(form_data)

      expect(helper.it_service_items.pluck(:field))
        .to include(I18n.t("coronavirus_form.check_your_answers.charge"))
      expect(helper.it_service_items.pluck(:value))
        .to include(form_data[:it_cost])
    end
  end
end
