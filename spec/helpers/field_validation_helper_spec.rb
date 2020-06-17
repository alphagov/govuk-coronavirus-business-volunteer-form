require "spec_helper"

RSpec.describe FieldValidationHelper, type: :helper do
  describe "#validate_company_number" do
    let(:field) { "company_number" }
    let(:error) { [{ field: field, text: t("coronavirus_form.errors.company_number") }] }

    it "can be 8 digits" do
      expect(validate_company_number(field, "12345678")).to eq []
    end

    it "can be 2 alpha characters plus 6 digits" do
      expect(validate_company_number(field, "AB123456")).to eq []
    end

    it "cannot be less than 8 digits long" do
      expect(validate_company_number(field, "1234567")).to eq error
    end

    it "cannot be more than 8 digits long" do
      expect(validate_company_number(field, "123456789")).to eq error
    end

    it "cannot have 1 alpha character" do
      expect(validate_company_number(field, "A1234567")).to eq error
    end

    it "cannot have 3 alpha characters" do
      expect(validate_company_number(field, "ABC12345")).to eq error
    end
  end
end
