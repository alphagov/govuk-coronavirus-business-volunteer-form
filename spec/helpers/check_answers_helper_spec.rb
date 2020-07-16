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
end
