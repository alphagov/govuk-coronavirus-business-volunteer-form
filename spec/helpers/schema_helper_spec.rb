require "spec_helper"

RSpec.describe SchemaHelper, type: :helper do
  include FormResponseHelper

  describe "#validate_against_form_response_schema" do
    it "returns nothing if the data is valid" do
      expect(validate_against_form_response_schema(valid_data)).to be_empty
    end

    describe "medical_equipment" do
      it "returns a list of errors when medical_equipment is missing" do
        data = valid_data.except(:medical_equipment)
        expect(validate_against_form_response_schema(data).first).to include("medical_equipment")
      end

      it "returns a list of errors when medical_equipment has an unexpected value" do
        data = valid_data.merge(medical_equipment: "Foo")
        expect(validate_against_form_response_schema(data).first).to include("medical_equipment")
      end
    end

    describe "accommodation" do
      it "returns a list of errors when accommodation is missing" do
        data = valid_data.except(:accommodation)
        expect(validate_against_form_response_schema(data).first).to include("accommodation")
      end

      it "returns a list of errors when accommodation has an unexpected value" do
        data = valid_data.merge(accommodation: "Foo")
        expect(validate_against_form_response_schema(data).first).to include("accommodation")
      end
    end

    describe "rooms_number" do
      it "allows rooms_number to be blank" do
        data = valid_data.except(:rooms_number)
        expect(validate_against_form_response_schema(data)).to be_empty
      end
    end

    describe "offer_transport" do
      it "returns a list of errors when offer_transport is missing" do
        data = valid_data.except(:offer_transport)
        expect(validate_against_form_response_schema(data).first).to include("offer_transport")
      end

      it "returns a list of errors when offer_transport has an unexpected value" do
        data = valid_data.merge(offer_transport: "Foo")
        expect(validate_against_form_response_schema(data).first).to include("offer_transport")
      end
    end

    describe "transport_type" do
      it "allows transport_type to be blank" do
        data = valid_data.except(:transport_type)
        expect(validate_against_form_response_schema(data)).to be_empty
      end

      it "returns a list of errors when transport_type has an unexpected value" do
        data = valid_data.merge(transport_type: %w[Foo])
        expect(validate_against_form_response_schema(data).first).to include("transport_type")
      end
    end

    describe "transport_description" do
      it "allows transport_description to be blank" do
        data = valid_data.except(:transport_description)
        expect(validate_against_form_response_schema(data)).to be_empty
      end
    end

    describe "transport_cost" do
      it "allows transport_cost to be blank" do
        data = valid_data.except(:transport_cost)
        expect(validate_against_form_response_schema(data)).to be_empty
      end

      it "returns a list of errors when transport_cost has an unexpected value" do
        data = valid_data.merge(transport_cost: "Foo")
        expect(validate_against_form_response_schema(data).first).to include("transport_cost")
      end
    end

    describe "offer_space" do
      it "returns a list of errors when offer_space is missing" do
        data = valid_data.except(:offer_space)
        expect(validate_against_form_response_schema(data).first).to include("offer_space")
      end

      it "returns a list of errors when offer_space has an unexpected value" do
        data = valid_data.merge(offer_space: "Foo")
        expect(validate_against_form_response_schema(data).first).to include("offer_space")
      end
    end

    describe "offer_space_type" do
      it "allows offer_space_type to be blank" do
        data = valid_data.except(:offer_space_type)
        expect(validate_against_form_response_schema(data)).to be_empty
      end

      it "returns a list of errors when offer_space_type has an unexpected value" do
        data = valid_data.merge(offer_space_type: %w[Foo])
        expect(validate_against_form_response_schema(data).first).to include("offer_space_type")
      end
    end

    describe "warehouse_space_description" do
      it "allows warehouse_space_description to be blank" do
        data = valid_data.except(:warehouse_space_description)
        expect(validate_against_form_response_schema(data)).to be_empty
      end
    end

    describe "office_space_description" do
      it "allows office_space_description to be blank" do
        data = valid_data.except(:office_space_description)
        expect(validate_against_form_response_schema(data)).to be_empty
      end
    end

    describe "general_space_description" do
      it "allows general_space_description to be blank" do
        data = valid_data.except(:general_space_description)
        expect(validate_against_form_response_schema(data)).to be_empty
      end
    end

    describe "offer_space_type_other" do
      it "allows offer_space_type_other to be blank" do
        data = valid_data.except(:offer_space_type_other)
        expect(validate_against_form_response_schema(data)).to be_empty
      end
    end

    describe "space_cost" do
      it "allows space_cost to be blank" do
        data = valid_data.except(:space_cost)
        expect(validate_against_form_response_schema(data)).to be_empty
      end

      it "returns a list of errors when space_cost has an unexpected value" do
        data = valid_data.merge(space_cost: "Foo")
        expect(validate_against_form_response_schema(data).first).to include("space_cost")
      end
    end

    describe "expert_advice_type" do
      it "returns a list of errors when offer_space is missing" do
        data = valid_data.except(:expert_advice_type)
        expect(validate_against_form_response_schema(data).first).to include("expert_advice_type")
      end

      it "returns a list of errors when expert_advice_type has an unexpected value" do
        data = valid_data.merge(expert_advice_type: %w[Foo])
        expect(validate_against_form_response_schema(data).first).to include("expert_advice_type")
      end
    end

    describe "expert_advice_type_other" do
      it "allows expert_advice_type_other to be blank" do
        data = valid_data.except(:expert_advice_type_other)
        expect(validate_against_form_response_schema(data)).to be_empty
      end
    end

    describe "offer_care" do
      it "returns a list of errors when offer_space is missing" do
        data = valid_data.except(:offer_care)
        expect(validate_against_form_response_schema(data).first).to include("offer_care")
      end

      it "returns a list of errors when offer_care has an unexpected value" do
        data = valid_data.merge(offer_care: "Foo")
        expect(validate_against_form_response_schema(data).first).to include("offer_care")
      end
    end

    describe "offer_care_type" do
      it "allows offer_care_type to be blank" do
        data = valid_data.except(:offer_care_type)
        expect(validate_against_form_response_schema(data)).to be_empty
      end

      it "returns a list of errors when offer_care_type has an unexpected value" do
        data = valid_data.merge(offer_care_type: %w[Foo])
        expect(validate_against_form_response_schema(data).first).to include("offer_care_type")
      end
    end

    describe "offer_care_qualifications" do
      it "allows offer_care_qualifications to be blank" do
        data = valid_data.except(:offer_care_qualifications)
        expect(validate_against_form_response_schema(data)).to be_empty
      end

      it "returns a list of errors when offer_care_qualifications has an unexpected value" do
        data = valid_data.merge(offer_care_qualifications: %w[Foo])
        expect(validate_against_form_response_schema(data).first).to include("offer_care_qualifications")
      end
    end

    describe "offer_care_qualifications_type" do
      it "allows offer_care_qualifications_type to be blank" do
        data = valid_data.except(:offer_care_qualifications_type)
        expect(validate_against_form_response_schema(data)).to be_empty
      end
    end

    describe "offer_other_support" do
      it "allows offer_other_support to be blank" do
        data = valid_data.except(:offer_other_support)
        expect(validate_against_form_response_schema(data)).to be_empty
      end
    end

    describe "business_details" do
      it "returns a list of errors when business_details is missing" do
        data = valid_data.except(:business_details)
        expect(validate_against_form_response_schema(data).first).to include("business_details")
      end

      it "returns a list of errors when company_name is missing" do
        data = valid_data.tap do |valid_data|
          valid_data[:business_details].delete(:company_name)
        end

        expect(validate_against_form_response_schema(data).first).to include("company_name")
      end

      it "allows company_number to be blank" do
        data = valid_data.tap do |valid_data|
          valid_data[:business_details].delete(:company_number)
        end

        expect(validate_against_form_response_schema(data)).to be_empty
      end

      it "returns a list of errors when company_size is missing" do
        data = valid_data.tap do |valid_data|
          valid_data[:business_details].delete(:company_size)
        end

        expect(validate_against_form_response_schema(data).first).to include("company_size")
      end

      it "returns a list of errors when company_size has an unexpected value" do
        data = valid_data.tap do |valid_data|
          valid_data[:business_details][:company_size] = "Foo"
        end

        expect(validate_against_form_response_schema(data).first).to include("company_size")
      end

      it "returns a list of errors when company_location is missing" do
        data = valid_data.tap do |valid_data|
          valid_data[:business_details].delete(:company_location)
        end

        expect(validate_against_form_response_schema(data).first).to include("company_location")
      end

      it "returns a list of errors when company_location has an unexpected value" do
        data = valid_data.tap do |valid_data|
          valid_data[:business_details][:company_location] = "Foo"
        end

        expect(validate_against_form_response_schema(data).first).to include("company_location")
      end

      it "allows company_postcode to be blank" do
        data = valid_data.tap do |valid_data|
          valid_data[:business_details].delete(:company_postcode)
        end

        expect(validate_against_form_response_schema(data)).to be_empty
      end

      it "returns a list of errors when company_postcode has an invalid value" do
        data = valid_data.tap do |valid_data|
          valid_data[:business_details][:company_postcode] = "Foo"
        end

        expect(validate_against_form_response_schema(data).first).to include("company_postcode")
      end
    end

    describe "contact_details" do
      it "returns a list of errors when contact_details is missing" do
        data = valid_data.except(:contact_details)
        expect(validate_against_form_response_schema(data).first).to include("contact_details")
      end

      it "returns a list of errors when contact_name is missing" do
        data = valid_data.tap do |valid_data|
          valid_data[:contact_details].delete(:contact_name)
        end

        expect(validate_against_form_response_schema(data).first).to include("contact_name")
      end

      it "allows role to be blank" do
        data = valid_data.tap do |valid_data|
          valid_data[:contact_details].delete(:role)
        end

        expect(validate_against_form_response_schema(data)).to be_empty
      end

      it "returns a list of errors when phone_number is missing" do
        data = valid_data.tap do |valid_data|
          valid_data[:contact_details].delete(:phone_number)
        end

        expect(validate_against_form_response_schema(data).first).to include("phone_number")
      end

      it "returns a list of errors when email is missing" do
        data = valid_data.tap do |valid_data|
          valid_data[:contact_details].delete(:email)
        end

        expect(validate_against_form_response_schema(data).first).to include("email")
      end

      it "returns a list of errors when email has an invalid value" do
        data = valid_data.tap do |valid_data|
          valid_data[:contact_details][:email] = "Foo"
        end

        expect(validate_against_form_response_schema(data).first).to include("email")
      end
    end

    describe "product_details" do
      it "allows product_details to be blank" do
        data = valid_data.except(:product_details)
        expect(validate_against_form_response_schema(data)).to be_empty
      end

      it "returns a list of errors when medical_equipment_type is missing" do
        data = valid_data.tap do |valid_data|
          valid_data[:product_details].last.delete(:medical_equipment_type)
        end

        expect(validate_against_form_response_schema(data).first).to include("medical_equipment_type")
      end

      it "returns a list of errors when medical_equipment_type has an unexpected value" do
        data = valid_data.tap do |valid_data|
          valid_data[:product_details].last[:medical_equipment_type] = "Foo"
        end

        expect(validate_against_form_response_schema(data).first).to include("medical_equipment_type")
      end

      it "returns a list of errors when product_id is missing" do
        data = valid_data.tap do |valid_data|
          valid_data[:product_details].last.delete(:product_id)
        end

        expect(validate_against_form_response_schema(data).first).to include("product_id")
      end

      it "returns a list of errors when product_quantity is not a number" do
        data = valid_data.tap do |valid_data|
          valid_data[:product_details].last[:product_quantity] = "Foo"
        end

        expect(validate_against_form_response_schema(data).first).to include("product_quantity")
      end

      it "returns a list of errors when product_quantity is not an integer" do
        data = valid_data.tap do |valid_data|
          valid_data[:product_details].last[:product_quantity] = "10.5"
        end

        expect(validate_against_form_response_schema(data).first).to include("product_quantity")
      end

      it "returns a list of errors when product_cost is not a number" do
        data = valid_data.tap do |valid_data|
          valid_data[:product_details].last[:product_cost] = "Foo"
        end

        expect(validate_against_form_response_schema(data).first).to include("product_cost")
      end

      it "returns a list of errors when product_cost has more than two decimal places" do
        data = valid_data.tap do |valid_data|
          valid_data[:product_details].last[:product_cost] = "10.123"
        end

        expect(validate_against_form_response_schema(data).first).to include("product_cost")
      end

      it "returns a list of errors when product_location has an unexpected value" do
        data = valid_data.tap do |valid_data|
          valid_data[:product_details].last[:product_location] = "Foo"
        end

        expect(validate_against_form_response_schema(data).first).to include("product_location")
      end

      it "returns a list of errors when product_postcode has an invalid value" do
        data = valid_data.tap do |valid_data|
          valid_data[:product_details].last[:product_postcode] = "Foo"
        end

        expect(validate_against_form_response_schema(data).first).to include("product_postcode")
      end

      it "returns a list of errors when lead_time is not a number" do
        data = valid_data.tap do |valid_data|
          valid_data[:product_details].last[:lead_time] = "Foo"
        end

        expect(validate_against_form_response_schema(data).first).to include("lead_time")
      end

      it "returns a list of errors when lead_time is not an integer" do
        data = valid_data.tap do |valid_data|
          valid_data[:product_details].last[:lead_time] = "10.5"
        end

        expect(validate_against_form_response_schema(data).first).to include("lead_time")
      end

      it "returns a list of errors when equipment_type has an invalid value" do
        data = valid_data.tap do |valid_data|
          valid_data[:product_details].last[:equipment_type] = "Foo"
        end

        expect(validate_against_form_response_schema(data).first).to include("equipment_type")
      end
    end

    describe "are_you_a_manufacturer" do
      it "returns a list of errors when are_you_a_manufacturer has an unexpected value" do
        data = valid_data.merge(are_you_a_manufacturer: %w[Foo])
        expect(validate_against_form_response_schema(data).first).to include("are_you_a_manufacturer")
      end
    end

    describe "additional_product" do
      it "returns a list of errors when additional_product has an unexpected value" do
        data = valid_data.merge(additional_product: "Foo")
        expect(validate_against_form_response_schema(data).first).to include("additional_product")
      end
    end

    describe "other information" do
      it "allows a reference_number to be stored" do
        data = valid_data.merge(reference_number: "abc")
        expect(validate_against_form_response_schema(data)).to be_empty
      end

      it "allows check_answers_seen to be stored" do
        data = valid_data.merge(check_answers_seen: true)
        expect(validate_against_form_response_schema(data)).to be_empty
      end

      it "returns a list of errors when check_answers_seen has an invalid value" do
        data = valid_data.merge(check_answers_seen: "Foo")
        expect(validate_against_form_response_schema(data).first).to include("check_answers_seen")
      end

      it "allows a _csrf_token to be stored" do
        data = valid_data.merge(_csrf_token: "abc")
        expect(validate_against_form_response_schema(data)).to be_empty
      end

      it "allows the current_path to be stored" do
        data = valid_data.merge(current_path: "/foo")
        expect(validate_against_form_response_schema(data)).to be_empty
      end

      it "allows the previous_path to be stored" do
        data = valid_data.merge(previous_path: "/foo")
        expect(validate_against_form_response_schema(data)).to be_empty
      end
    end
  end
end
