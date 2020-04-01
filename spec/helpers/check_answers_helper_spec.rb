require "spec_helper"

RSpec.describe CheckAnswersHelper, type: :helper do
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
  end
end
