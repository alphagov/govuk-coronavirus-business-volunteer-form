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
