# frozen_string_literal: true

module FillInTheFormSteps
  def given_a_business_during_the_covid_19_pandemic
    visit medical_equipment_path
  end

  def that_can_offer_medical_equipment
    expect(page.body).to have_content(I18n.t("coronavirus_form.questions.medical_equipment.title"))
    within find(".govuk-main-wrapper") do
      choose I18n.t("coronavirus_form.questions.medical_equipment.options.option_yes.label")
      click_on I18n.t("coronavirus_form.submit_and_next")
    end
  end

  def and_is_a_manufacturer_a_distributor_and_agent
    expect(page.body).to have_content(I18n.t("coronavirus_form.questions.are_you_a_manufacturer.title"))
    within find(".govuk-main-wrapper") do
      check I18n.t("coronavirus_form.questions.are_you_a_manufacturer.options.manufacturer.label")
      check I18n.t("coronavirus_form.questions.are_you_a_manufacturer.options.distributor.label")
      check I18n.t("coronavirus_form.questions.are_you_a_manufacturer.options.agent.label")
      click_on I18n.t("coronavirus_form.submit_and_next")
    end
  end

  def and_has_personal_protection_equipment_available
    expect(page.body).to have_content(I18n.t("coronavirus_form.questions.medical_equipment_type.title"))
    choose I18n.t("coronavirus_form.questions.medical_equipment_type.options.number_ppe.label")
    click_on I18n.t("coronavirus_form.submit_and_next")

    expect(page.body).to have_content(I18n.t("coronavirus_form.questions.product_details.title"))
    fill_in "product_name", with: "Testing"
    choose I18n.t("coronavirus_form.questions.product_details.equipment_type.options.iir_face_masks.label")
    fill_in "product_quantity", with: "500"
    fill_in "product_cost", with: "0"
    fill_in "certification_details", with: "CE marking"
    choose I18n.t("coronavirus_form.questions.product_details.product_location.options.option_uk.label")
    fill_in "product_postcode", with: "E1 8QS"
    fill_in "product_url", with: "https://example.com"
    fill_in "lead_time", with: "10"
    click_on I18n.t("coronavirus_form.submit_and_next")
  end

  def and_can_offer_testing_equipment
    choose I18n.t("coronavirus_form.questions.medical_equipment_type.options.number_testing_equipment.label")
    click_on I18n.t("coronavirus_form.submit_and_next")
  end

  def and_has_no_more_testing_equipment_to_offer
    expect(page.body).to have_content(I18n.t("coronavirus_form.questions.additional_product.title"))
    choose I18n.t("coronavirus_form.questions.additional_product.options.option_no.label")
    click_on I18n.t("coronavirus_form.submit_and_next")
  end

  def then_they_see_the_external_testing_equipment_link
    link = I18n.t("coronavirus_form.testing_equipment.external_link")
    expect(page.body).to have_content(I18n.t("coronavirus_form.testing_equipment.link.label"))
    expect(page.body).to have_selector(:css, "a[href='#{link}']")
  end

  def and_can_navigate_back_to_offer_another_product
    click_on I18n.t("coronavirus_form.testing_equipment.button.label")
    expect(page.body).to have_content(I18n.t("coronavirus_form.questions.additional_product.title"))
  end

  def and_can_offer_accommodation
    expect(page.body).to have_content(I18n.t("coronavirus_form.questions.accommodation.title"))
    choose I18n.t("coronavirus_form.questions.accommodation.options.yes_all_uses.label")
    click_on I18n.t("coronavirus_form.submit_and_next")

    expect(page.body).to have_content(I18n.t("coronavirus_form.questions.rooms_number.title"))
    fill_in "rooms_number", with: "500"
    choose I18n.t("coronavirus_form.questions.how_much_charge.options.nothing.label")
    click_on I18n.t("coronavirus_form.submit_and_next")
  end

  def and_can_offer_transport_or_logistics
    expect(page.body).to have_content(I18n.t("coronavirus_form.questions.offer_transport.title"))
    choose I18n.t("coronavirus_form.questions.offer_transport.options.option_yes.label")
    click_on I18n.t("coronavirus_form.submit_and_next")

    expect(page.body).to have_content(I18n.t("coronavirus_form.questions.transport_type.title"))
    check I18n.t("coronavirus_form.questions.transport_type.options.moving_people.label")
    check I18n.t("coronavirus_form.questions.transport_type.options.moving_goods.label")
    check I18n.t("coronavirus_form.questions.transport_type.options.other.label")
    fill_in "transport_description", with: "Testing"
    choose I18n.t("coronavirus_form.questions.how_much_charge.options.nothing.label")
    click_on I18n.t("coronavirus_form.submit_and_next")
  end

  def and_can_offer_space
    expect(page.body).to have_content(I18n.t("coronavirus_form.questions.offer_space.title"))
    choose I18n.t("coronavirus_form.questions.offer_space.options.option_yes.label")
    click_on I18n.t("coronavirus_form.submit_and_next")

    expect(page.body).to have_content(I18n.t("coronavirus_form.questions.offer_space_type.title"))
    check I18n.t("coronavirus_form.questions.offer_space_type.options.warehouse_space.label")
    fill_in "warehouse_space_description", with: "1000"
    check I18n.t("coronavirus_form.questions.offer_space_type.options.office_space.label")
    fill_in "office_space_description", with: "1000"
    check I18n.t("coronavirus_form.questions.offer_space_type.options.other.label")
    fill_in "offer_space_type_other", with: "1000"
    fill_in "general_space_description", with: "Testing"
    choose I18n.t("coronavirus_form.questions.how_much_charge.options.nothing.label")
    click_on I18n.t("coronavirus_form.submit_and_next")
  end

  def and_can_offer_staff
    expect(page.body).to have_content(I18n.t("coronavirus_form.questions.offer_staff.title"))
    choose I18n.t("coronavirus_form.questions.offer_staff.options.option_yes.label")
    click_on I18n.t("coronavirus_form.submit_and_next")
  end

  def and_can_offer_all_types_of_expertise
    expect(page.body).to have_content(I18n.t("coronavirus_form.questions.expert_advice_type.title"))
    check I18n.t("coronavirus_form.questions.expert_advice_type.options.medical.label")
    check I18n.t("coronavirus_form.questions.expert_advice_type.options.engineering.label")
    check I18n.t("coronavirus_form.questions.expert_advice_type.options.construction.label")
    check I18n.t("coronavirus_form.questions.expert_advice_type.options.project_management.label")
    check I18n.t("coronavirus_form.questions.expert_advice_type.options.it.label")
    check I18n.t("coronavirus_form.questions.expert_advice_type.options.manufacturing.label")
    check I18n.t("coronavirus_form.questions.expert_advice_type.options.other.label")
    fill_in "expert_advice_type_other", with: "Testing"
    click_on I18n.t("coronavirus_form.submit_and_next")
  end

  def and_can_offer_all_kinds_of_social_and_child_care
    expect(page.body).to have_content(I18n.t("coronavirus_form.questions.offer_care.title"))
    choose I18n.t("coronavirus_form.questions.offer_care.options.option_yes.label")
    click_on I18n.t("coronavirus_form.submit_and_next")

    expect(page.body).to have_content(I18n.t("coronavirus_form.questions.offer_care_qualifications.title"))
    check I18n.t("coronavirus_form.questions.offer_care_qualifications.offer_care_type.options.adult_care.label")
    check I18n.t("coronavirus_form.questions.offer_care_qualifications.offer_care_type.options.child_care.label")
    check I18n.t("coronavirus_form.questions.offer_care_qualifications.care_qualifications.options.dbs_check.label")
    check I18n.t("coronavirus_form.questions.offer_care_qualifications.care_qualifications.options.nursing_or_healthcare_qualification.label")
    fill_in "offer_care_qualifications_type", with: "Testing"
    choose I18n.t("coronavirus_form.questions.how_much_charge.options.nothing.label")
    click_on I18n.t("coronavirus_form.submit_and_next")

    expect(page.body).to have_content(I18n.t("coronavirus_form.questions.offer_other_support.title"))
    fill_in "offer_other_support", with: "Testing"
    click_on I18n.t("coronavirus_form.submit_and_next")
  end

  def and_offers_these_across_the_uk
    expect(page.body).to have_content(I18n.t("coronavirus_form.questions.location.title"))
    check I18n.t("coronavirus_form.questions.location.options.east_of_england.label")
    check I18n.t("coronavirus_form.questions.location.options.east_midlands.label")
    check I18n.t("coronavirus_form.questions.location.options.west_midland.label")
    check I18n.t("coronavirus_form.questions.location.options.london.label")
    check I18n.t("coronavirus_form.questions.location.options.north_east.label")
    check I18n.t("coronavirus_form.questions.location.options.north_west.label")
    check I18n.t("coronavirus_form.questions.location.options.south_east.label")
    check I18n.t("coronavirus_form.questions.location.options.south_west.label")
    check I18n.t("coronavirus_form.questions.location.options.yorkshire.label")
    check I18n.t("coronavirus_form.questions.location.options.northern_ireland.label")
    check I18n.t("coronavirus_form.questions.location.options.scotland.label")
    check I18n.t("coronavirus_form.questions.location.options.wales.label")
    click_on I18n.t("coronavirus_form.submit_and_next")
  end

  def and_has_given_their_business_details
    expect(page.body).to have_content(I18n.t("coronavirus_form.questions.business_details.title"))
    fill_in "company_name", with: "Government Digital Service"
    fill_in "company_number", with: "020 3451 9000"
    choose I18n.t("coronavirus_form.questions.business_details.company_size.options.under_50_people.label")
    choose I18n.t("coronavirus_form.questions.business_details.company_location.options.united_kingdom.label")
    fill_in "company_postcode", with: "E1 8QS"
    click_on I18n.t("coronavirus_form.submit_and_next")
  end

  def and_has_supplied_a_contact
    expect(page.body).to have_content(I18n.t("coronavirus_form.questions.contact_details.title"))
    fill_in "contact_name", with: "Test Please Ignore"
    fill_in "role", with: "Test Please Ignore"
    fill_in "phone_number", with: "07000000000"
    fill_in "email", with: Rails.application.config.courtesy_copy_email
    click_on I18n.t("coronavirus_form.submit_and_next")
  end

  def and_has_accepted_the_terms_and_conditions
    expect(page.body).to have_content(I18n.t("check_your_answers.title"))
    click_on I18n.t("check_your_answers.submit")
  end

  def then_they_are_thanked
    expect(page.body).to have_content(I18n.t("coronavirus_form.thank_you.title"))
  end
end
