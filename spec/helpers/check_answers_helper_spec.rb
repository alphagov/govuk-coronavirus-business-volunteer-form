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
end
