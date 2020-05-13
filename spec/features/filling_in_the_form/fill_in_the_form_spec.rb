# frozen_string_literal: true

require "spec_helper"

RSpec.feature "fill in the business volunteer form" do
  include FillInTheFormSteps

  shared_examples "completing the form" do
    scenario "fill in the form" do
      given_a_business_during_the_covid_19_pandemic
      that_can_offer_medical_equipment
      and_is_a_manufacturer_a_distributor_and_agent
      and_has_personal_protection_equipment_available
      and_has_no_more_testing_equipment_to_offer
      and_can_offer_accommodation
      and_can_offer_transport_or_logistics
      and_can_offer_space
      and_can_offer_staff
      and_can_offer_all_types_of_expertise
      and_can_offer_all_kinds_of_social_and_child_care
      and_offers_these_across_the_uk
      and_has_given_their_business_details
      and_has_supplied_a_contact
      and_has_accepted_the_terms_and_conditions
      then_they_are_thanked
    end
  end

  describe "fill in the form" do
    context "without javascript" do
      it_behaves_like "completing the form"
    end

    context "with javascript", js: true do
      it_behaves_like "completing the form"
    end
  end

  scenario "Fill in the form with Testing Equipment" do
    given_a_business_during_the_covid_19_pandemic
    that_can_offer_medical_equipment
    and_is_a_manufacturer_a_distributor_and_agent
    and_can_offer_testing_equipment
    then_they_see_the_external_testing_equipment_link
    and_can_navigate_back_to_offer_another_product
  end

  scenario "ensure we can perform a healthcheck" do
    visit healthcheck_path

    expect(page.body).to have_content("OK")
  end

  scenario "ensure the privacy notice page is visible" do
    visit privacy_path

    expect(page.body).to have_content(I18n.t("privacy_page.title"))
  end

  scenario "ensure the accessibility statement page is visible" do
    visit accessibility_statement_path

    expect(page.body).to have_content(I18n.t("accessibility_statement.title"))
  end

  scenario "ensure the session expired page is visible" do
    visit session_expired_path

    expect(page.body).to have_content(I18n.t("session_expired.title"))
  end
end
