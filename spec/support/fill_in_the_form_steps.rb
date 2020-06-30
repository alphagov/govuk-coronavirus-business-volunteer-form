# frozen_string_literal: true

module FillInTheFormSteps
  def given_a_business_during_the_covid_19_pandemic
    visit accommodation_path
  end

  def and_can_offer_accommodation
    expect(page).to have_content(I18n.t("coronavirus_form.questions.accommodation.title"))
    choose I18n.t("coronavirus_form.questions.accommodation.options.yes_all_uses.label")
    click_on I18n.t("coronavirus_form.submit_and_next")

    expect(page).to have_content(I18n.t("coronavirus_form.questions.rooms_number.title"))
    fill_in "rooms_number", with: "500"
    choose I18n.t("coronavirus_form.how_much_charge.options.nothing.label")
    click_on I18n.t("coronavirus_form.submit_and_next")
  end

  def and_can_offer_transport_or_logistics
    expect(page).to have_content(I18n.t("coronavirus_form.questions.offer_transport.title"))
    choose I18n.t("coronavirus_form.questions.offer_transport.options.option_yes.label")
    click_on I18n.t("coronavirus_form.submit_and_next")

    expect(page).to have_content(I18n.t("coronavirus_form.questions.transport_type.title"))
    check I18n.t("coronavirus_form.questions.transport_type.options.moving_people.label")
    check I18n.t("coronavirus_form.questions.transport_type.options.moving_goods.label")
    check I18n.t("coronavirus_form.questions.transport_type.options.other.label")
    fill_in "transport_description", with: "Testing"
    choose I18n.t("coronavirus_form.how_much_charge.options.nothing.label")
    click_on I18n.t("coronavirus_form.submit_and_next")
  end

  def and_can_offer_space
    expect(page).to have_content(I18n.t("coronavirus_form.questions.offer_space.title"))
    choose I18n.t("coronavirus_form.questions.offer_space.options.option_yes.label")
    click_button I18n.t("coronavirus_form.submit_and_next")

    sleep 0.5

    expect(page).to have_content(I18n.t("coronavirus_form.questions.offer_space_type.title"))
    check I18n.t("coronavirus_form.questions.offer_space_type.options.warehouse_space.label")
    fill_in "warehouse_space_description", with: "1000"
    check I18n.t("coronavirus_form.questions.offer_space_type.options.office_space.label")
    fill_in "office_space_description", with: "1000"
    check I18n.t("coronavirus_form.questions.offer_space_type.options.other.label")
    fill_in "offer_space_type_other", with: "1000"
    fill_in "general_space_description", with: "Testing"
    choose I18n.t("coronavirus_form.how_much_charge.options.nothing.label")
    click_on I18n.t("coronavirus_form.submit_and_next")
  end

  def and_can_offer_staff
    expect(page).to have_content(I18n.t("coronavirus_form.questions.offer_staff.title"))
    choose I18n.t("coronavirus_form.questions.offer_staff.options.option_yes.label")
    click_on I18n.t("coronavirus_form.submit_and_next")

    expect(page).to have_content(I18n.t("coronavirus_form.questions.offer_staff_type.title"))
    check I18n.t("coronavirus_form.questions.offer_staff_type.offer_staff_type.options.cleaners.label")
    fill_in "cleaners_number", with: "1000"
    fill_in "offer_staff_description", with: "Testing"
    choose I18n.t("coronavirus_form.questions.offer_staff_type.offer_staff_charge.options.nothing.label")
    click_on I18n.t("coronavirus_form.submit_and_next")
  end

  def and_can_offer_all_types_of_expertise
    expect(page).to have_content(I18n.t("coronavirus_form.questions.expert_advice_type.title"))
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

  def and_can_offer_construction_services
    expect(page).to have_content(I18n.t("coronavirus_form.questions.construction_services.title"))
    check I18n.t("coronavirus_form.questions.construction_services.options.building_materials.label")
    check I18n.t("coronavirus_form.questions.construction_services.options.building_maintenance.label")
    check I18n.t("coronavirus_form.questions.construction_services.options.temporary_buildings.label")
    check I18n.t("coronavirus_form.questions.construction_services.options.construction_work.label")
    check I18n.t("coronavirus_form.questions.construction_services.options.other.label")
    fill_in "construction_services_other", with: "Testing"
    choose I18n.t("coronavirus_form.how_much_charge.options.nothing.label")
    click_on I18n.t("coronavirus_form.submit_and_next")
  end

  def and_can_offer_it_services
    expect(page).to have_content(I18n.t("coronavirus_form.questions.it_services.title"))
    check I18n.t("coronavirus_form.questions.it_services.options.broadband.label")
    check I18n.t("coronavirus_form.questions.it_services.options.equipment.label")
    check I18n.t("coronavirus_form.questions.it_services.options.mobile_phones.label")
    check I18n.t("coronavirus_form.questions.it_services.options.video_conferencing.label")
    check I18n.t("coronavirus_form.questions.it_services.options.virtual_tools.label")
    check I18n.t("coronavirus_form.questions.it_services.options.other.label")
    fill_in "it_services_other", with: "Testing"
    choose I18n.t("coronavirus_form.how_much_charge.options.nothing.label")
    click_on I18n.t("coronavirus_form.submit_and_next")
  end

  def and_can_offer_all_kinds_of_social_and_child_care
    expect(page).to have_content(I18n.t("coronavirus_form.questions.offer_care.title"))
    choose I18n.t("coronavirus_form.questions.offer_care.options.option_yes.label")
    click_on I18n.t("coronavirus_form.submit_and_next")

    expect(page).to have_content(I18n.t("coronavirus_form.questions.offer_care_qualifications.title"))
    check I18n.t("coronavirus_form.questions.offer_care_qualifications.offer_care_type.options.adult_care.label")
    check I18n.t("coronavirus_form.questions.offer_care_qualifications.offer_care_type.options.child_care.label")
    check I18n.t("coronavirus_form.questions.offer_care_qualifications.care_qualifications.options.dbs_check.label")
    check I18n.t("coronavirus_form.questions.offer_care_qualifications.care_qualifications.options.nursing_or_healthcare_qualification.label")
    fill_in "offer_care_qualifications_type", with: "Testing"
    choose I18n.t("coronavirus_form.how_much_charge.options.nothing.label")
    click_on I18n.t("coronavirus_form.submit_and_next")

    expect(page).to have_content(I18n.t("coronavirus_form.questions.offer_other_support.title"))
    fill_in "offer_other_support", with: "Testing"
    click_on I18n.t("coronavirus_form.submit_and_next")
  end

  def and_offers_these_across_the_uk
    expect(page).to have_content(I18n.t("coronavirus_form.questions.location.title"))
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
    expect(page).to have_content(I18n.t("coronavirus_form.questions.business_details.title"))
    fill_in "company_name", with: "Government Digital Service"
    choose I18n.t("coronavirus_form.questions.business_details.company_is_uk_registered.options.united_kingdom.label")
    fill_in "company_number", with: "AB123456"
    choose I18n.t("coronavirus_form.questions.business_details.company_size.options.under_50_people.label")
    choose I18n.t("coronavirus_form.questions.business_details.company_location.options.united_kingdom.label")
    fill_in "company_postcode", with: "E1 8QS"
    click_on I18n.t("coronavirus_form.submit_and_next")
  end

  def and_has_supplied_a_contact
    expect(page).to have_content(I18n.t("coronavirus_form.questions.contact_details.title"))
    fill_in "contact_name", with: "Test Please Ignore"
    fill_in "role", with: "Test Please Ignore"
    fill_in "phone_number", with: "07000000000"
    fill_in "email", with: Rails.application.config.courtesy_copy_email
    click_on I18n.t("coronavirus_form.submit_and_next")
  end

  def and_has_accepted_the_terms_and_conditions
    expect(page).to have_content(I18n.t("check_your_answers.title"))
    click_on I18n.t("check_your_answers.submit")
  end

  def then_they_are_thanked
    expect(page).to have_content(I18n.t("coronavirus_form.thank_you.title"))
  end
end
