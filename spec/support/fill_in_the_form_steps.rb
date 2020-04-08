# frozen_string_literal: true

module FillInTheFormSteps
  def given_a_business_during_the_covid_19_pandemic
    visit "/medical-equipment"
  end

  def that_can_offer_medical_equipment
    expect(page).to have_content("Can you offer medical equipment?")
    choose "Yes"
    click_on "Continue"
  end

  def and_is_a_manufacturer_a_distributor_and_agent
    expect(page).to have_content("What kind of business are you?")
    check "Manufacturer"
    check "Distributor"
    check "Agent"
    click_on "Continue"
  end

  def and_has_personal_protection_equipment_available
    expect(page).to have_content("Tell us about the medical equipment you can offer")
    choose "Personal protection equipment"
    click_on "Continue"

    expect(page).to have_content("Tell us about the product you’re offering")
    fill_in "product_name", with: "Testing"
    choose "Type IIR face masks"
    fill_in "product_quantity", with: "500"
    fill_in "product_cost", with: "0"
    fill_in "certification_details", with: "CE marking"
    choose "United Kingdom"
    fill_in "product_postcode", with: "E1 8QS"
    fill_in "product_url", with: "https://example.com"
    fill_in "lead_time", with: "10"
    click_on "Continue"
  end

  def and_has_other_medical_equipment_available
    expect(page).to have_content("Can you offer another product?")
    choose "Yes"
    click_on "Continue"

    expect(page).to have_content("Tell us about the medical equipment you can offer")
    choose "Other"
    fill_in "medical_equipment_type_other", with: "Some text about medical equipment"
    click_on "Continue"

    fill_in "product_name", with: "Testing"
    fill_in "product_quantity", with: "500"
    fill_in "product_cost", with: "0"
    fill_in "certification_details", with: "CE marking"
    choose "United Kingdom"
    fill_in "product_postcode", with: "E1 8QS"
    fill_in "product_url", with: "https://example.com"
    fill_in "lead_time", with: "10"
    click_on "Continue"

    expect(page).to have_content("Can you offer another product?")
    choose "No"
    click_on "Continue"
  end

  def and_can_offer_hotel_rooms
    expect(page).to have_content("Can you offer hotel rooms?")
    choose "Yes – for any use"
    click_on "Continue"

    expect(page).to have_content("How many hotel rooms can you offer?")
    fill_in "hotel_rooms_number", with: "500"
    click_on "Continue"
  end

  def and_can_offer_transport_or_logistics
    expect(page).to have_content("Can you offer transport or logistics?")
    choose "Yes"
    click_on "Continue"

    expect(page).to have_content("What kind of services can you offer?")
    check "Moving people"
    check "Moving goods"
    check "Other"
    fill_in "transport_description", with: "Testing"
    click_on "Continue"
  end

  def and_can_offer_space
    expect(page).to have_content("Can you offer space?")
    choose "Yes"
    click_on "Continue"

    expect(page).to have_content("What kind of space can you offer?")
    check "Warehouse space"
    fill_in "warehouse_space_description", with: "1000"
    check "Office space"
    fill_in "office_space_description", with: "1000"
    check "Other"
    fill_in "offer_space_type_other", with: "1000"
    fill_in "general_space_description", with: "Testing"
    click_on "Continue"
  end

  def and_can_offer_all_types_of_expertise
    expect(page).to have_content("What kind of expertise can you offer?")
    check "Medical"
    check "Engineering"
    check "Construction"
    check "Project management or procurement"
    check "IT services"
    check "Manufacturing"
    check "Other"
    fill_in "expert_advice_type_other", with: "Testing"
    click_on "Continue"
  end

  def and_can_offer_all_kinds_of_social_and_child_care
    expect(page).to have_content("Can you offer social care or childcare?")
    choose "Yes"
    click_on "Continue"

    expect(page).to have_content("What kind of care can you offer?")
    check "Care for adults"
    check "Care for children"
    check "DBS check"
    check "Nursing or other healthcare qualification"
    fill_in "offer_care_qualifications_type", with: "Testing"
    click_on "Continue"

    expect(page).to have_content("Can you offer any other kind of support?")
    fill_in "offer_other_support", with: "Testing"
    click_on "Continue"
  end

  def and_offers_these_across_the_uk
    expect(page).to have_content("Where can you offer your services?")
    check "East of England"
    check "East Midlands"
    check "West Midlands"
    check "London"
    check "North East"
    check "North West"
    check "South East"
    check "South West"
    check "Yorkshire and the Humber"
    check "Northern Ireland"
    check "Scotland"
    check "Wales"
    click_on "Continue"
  end

  def and_has_given_their_business_details
    expect(page).to have_content("Your business details")
    fill_in "company_name", with: "Government Digital Service"
    fill_in "company_number", with: "020 3451 9000"
    choose "Under 50 people"
    choose "United Kingdom"
    fill_in "company_postcode", with: "E1 8QS"
    click_on "Continue"
  end

  def and_has_supplied_a_contact
    expect(page).to have_content("Contact details")
    fill_in "contact_name", with: "John Doe"
    fill_in "role", with: "CEO"
    fill_in "phone_number", with: "020 1234 5678"
    fill_in "email", with: "john.doe@gds.org"
    click_on "Continue"
  end

  def and_has_accepted_the_terms_and_conditions
    expect(page).to have_content("Are you ready to send the form?")
    click_on "Accept and send"
  end

  def then_they_are_thanked
    expect(page).to have_content("Thank you for offering support")
  end
end
