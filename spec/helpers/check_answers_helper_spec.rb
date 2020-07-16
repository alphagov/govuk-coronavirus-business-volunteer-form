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
end
