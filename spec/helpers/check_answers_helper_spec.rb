require "spec_helper"

RSpec.describe CheckAnswersHelper, type: :helper do
  let(:answers_to_skippable_questions) do
    {
      are_you_a_manufacturer: [
        I18n.t("coronavirus_form.questions.are_you_a_manufacturer.options.manufacturer.label"),
      ],
      additional_product: I18n.t("coronavirus_form.questions.additional_product.options.option_no.label"),
      rooms_number: "100",
      accommodation_cost: I18n.t("coronavirus_form.how_much_charge.options").map { |_, item| item[:label] }.sample,
      transport_type: [
        I18n.t("coronavirus_form.questions.transport_type.options.moving_people.label"),
      ],
      transport_cost: I18n.t("coronavirus_form.how_much_charge.options").map { |_, item| item[:label] }.sample,
      offer_space_type: I18n.t("coronavirus_form.questions.offer_space_type.options.warehouse_space.label"),
      space_cost: I18n.t("coronavirus_form.how_much_charge.options").map { |_, item| item[:label] }.sample,
      offer_care_qualifications: I18n.t("coronavirus_form.questions.offer_care_qualifications.offer_care_type.options.adult_care.label"),
      care_cost: I18n.t("coronavirus_form.how_much_charge.options").map { |_, item| item[:label] }.sample,
      offer_staff_type: [
        I18n.t("coronavirus_form.questions.offer_staff_type.offer_staff_type.options.developers.label"),
      ],
      offer_staff_charge: I18n.t("coronavirus_form.how_much_charge.options").map { |_, item| item[:label] }.sample,
      construction_services: I18n.t("coronavirus_form.questions.construction_services.options").map { |_, item| item[:label] },
      construction_services_other: "Build all the things",
      construction_cost: I18n.t("coronavirus_form.how_much_charge.options").map { |_, item| item[:label] }.sample,
      it_services: I18n.t("coronavirus_form.questions.it_services.options").map { |_, item| item[:label] },
      it_services_other: "Supply all the things",
      it_cost: I18n.t("coronavirus_form.how_much_charge.options").map { |_, item| item[:label] }.sample,
    }
  end

  let(:products) do
    {
      product_details: [
        {
          equipment_type: I18n.t(
            "coronavirus_form.questions.medical_equipment_type.options.number_ppe.label",
          ),
          product_name: "Product name 1",
        },
        {
          equipment_type: I18n.t(
            "coronavirus_form.questions.medical_equipment_type.options.number_ppe.label",
          ),
          product_name: "Product name 2",
        },
        {
          product_location: I18n.t(
            "coronavirus_form.questions.product_details.product_location.options.option_uk.label",
          ),
          equipment_type: I18n.t(
            "coronavirus_form.questions.medical_equipment_type.options.number_ppe.label",
          ),
          product_postcode: "RG1 2NU",
          product_name: "Product name 3",
        },
      ],
    }
  end

  describe "#summary_entry" do
    context "edit permutations"
    it "returns non-editable field data if session_key is valid" do
      session.merge!({ "non_empty_string": "woah here's a string" })
      expect(
        helper.summary_entry("non_empty_string", "example description", false, false),
      ).to eq(
        { field: "example description", value: "woah here's a string" },
      )
    end

    it "returns change link values if asked for them" do
      session.merge!({ "non_empty_string": "woah here's a string" })
      expect(
        helper.summary_entry("non_empty_string", "example description", true, false),
      ).to eq({
        edit: { href: "non-empty-string?change-answer" },
        field: "example description",
        value: "woah here's a string",
      })
    end

    it "returns delete link values if asked" do
      session.merge!({ "non_empty_string": "woah here's a string" })
      expect(
        helper.summary_entry("non_empty_string", "example description", false, true),
      ).to eq({
        delete: { href: "non-empty-string?change-answer" },
        field: "example description",
        value: "woah here's a string",
      })
    end

    it "returns change & delete link values if asked" do
      session.merge!({ "non_empty_string": "woah here's a string" })
      expect(
        helper.summary_entry("non_empty_string", "example description", true, true),
      ).to eq({
        delete: { href: "non-empty-string?change-answer" },
        edit: { href: "non-empty-string?change-answer" },
        field: "example description",
        value: "woah here's a string",
      })
    end
    it "returns an array if passed an array" do
      session.merge!({ "non_empty_string": ["woah here's a string", "and a second", "and a third"] })
      expect(
        helper.summary_entry("non_empty_string", "example description", false, false),
      ).to eq({
        field: "example description",
        value: ["woah here's a string", "and a second", "and a third"],
      })
    end
    it "digs into nested structure if passed an array for a session key" do
      session.merge!({ "non_empty_string": { key_1: { key_2: "woah here's a string" } } })
      expect(
        helper.summary_entry(
          ["non_empty_string", :key_1, :key_2],
          "example description", true, true
        ),
      ).to eq({
        delete: { href: "non-empty-string?change-answer" },
        edit: { href: "non-empty-string?change-answer" },
        field: "example description",
        value: "woah here's a string",
      })
    end
  end

  describe "#product_details" do
    before do
      session.merge!(products)
    end

    subject { helper.product_details }

    it "adds a link to edit each item" do
      subject.each do |product|
        expect(product[:edit][:href]).to include(product_details_url(product_id: product["product_id"]))
      end
    end

    it "adds a link to delete each item" do
      subject.each do |product|
        expect(product[:delete][:href]).to include("/product-details/#{product[:product_id]}/delete")
      end
    end

    it "adds a numbered title to each item" do
      subject.each.with_index do |product, index|
        expect(product[:title]).to eq("Product #{index + 1}")
      end
    end

    it "sets title size to m" do
      subject.each.with_index do |product, _index|
        expect(product[:title_size]).to eq("m")
      end
    end

    it "retrieves value from products hash and maps it to data structure" do
      subject.each.with_index do |product, index|
        expect(product.dig(:items, 0, :value)).to eq(products[:product_details][index][:product_name])
        expect(product.dig(:items, 1, :value)).to eq(products[:product_details][index][:equipment_type])
      end
    end

    it "adds in the translation for the product_key value" do
      subject.each.with_index do |product, _index|
        expect(product.dig(:items, 0, :field)).to eq(t("coronavirus_form.questions.product_details.product_name.label"))
        expect(product.dig(:items, 1, :field)).to eq(t("coronavirus_form.questions.product_details.equipment_type.label"))
      end
    end
    it "handles the postcode special case correctly" do
      product3 = subject[2]
      expect(product3.dig(:items, 2, :field)).to eq(t("coronavirus_form.questions.product_details.product_location.label"))
      expect(product3.dig(:items, 2, :value)).to eq("United Kingdom (RG1 2NU)")
    end
  end

  describe "methods presenting offer sections (those preceding details sections that have yes no answers)" do
    context "offer is yes" do
      before do
        session.merge!({
          "accommodation": "Yes",
          "rooms_number": "500",
          "accommodation_description": "Very nice",
          "accommodation_cost": t("coronavirus_form.how_much_charge.options.nothing.label"),

          "offer_transport": "Yes",
          "transport_type": "Yes",
          "transport_description": "Yes",
          "transport_cost": t("coronavirus_form.how_much_charge.options.nothing.label"),

          "offer_staff": "Yes",
          "offer_staff_type": [
            t("coronavirus_form.questions.offer_staff_type.offer_staff_type.options.cleaners.label"),
            t("coronavirus_form.questions.offer_staff_type.offer_staff_type.options.developers.label"),
            t("coronavirus_form.questions.offer_staff_type.offer_staff_type.options.medical_staff.label"),
          ],
          "offer_staff_number": {
            cleaners_number: 12,
            developers_number: 39,
            medical_staff_number: 9,
          },
          "offer_staff_description": "They're well qualified.",
          "offer_staff_charge": t("coronavirus_form.how_much_charge.options.reduced.label"),

          "offer_space": "Yes",
          "offer_space_type": [t("coronavirus_form.questions.offer_space_type.options.warehouse_space.label").to_s],
          "offer_space_type_other": "Description of space",
          "space_cost": t("coronavirus_form.how_much_charge.options.nothing.label"),
          "warehouse_space_description": "123 feet",

          "offer_care": "Yes",
          "offer_care_type": [t("coronavirus_form.questions.offer_care_qualifications.offer_care_type.options.adult_care.label")],
          "offer_care_qualifications": [t("coronavirus_form.questions.offer_care_qualifications.care_qualifications.options.dbs_check.label")],
          "offer_care_qualifications_type": "Very good qualifications. This is a description field, really.",
          "care_cost": t("coronavirus_form.how_much_charge.options.nothing.label"),
        })
      end

      [
        # Sections which report the result of offer questions
        [
          "accommodation_section",
          { title: "Accommodation",
            title_size: "l",
            edit: { href: "accommodation?change-answer" },
            items: [{ field: "Can you offer accommodation?", value: "Yes" }] },
        ],
        [
          "transport_section",
          { title: "Transport",
            title_size: "l",
            edit: { href: "offer-transport?change-answer" },
            items: [{ field: "Can you offer transport or logistics?", value: "Yes" }] },
        ],
        [
          "staff_section",
          { title: "Staff",
            title_size: "l",
            edit: { href: "offer-staff?change-answer" },
            items: [{ field: "Can you offer staff?", value: "Yes" }] },
        ],
        [
          "space_section",
          { title: "Space",
            title_size: "l",
            edit: { href: "offer-space?change-answer" },
            items: [{ field: "Can you offer space?", value: "Yes" }] },
        ],
        [
          "care_section",
          { title: "Social care or childcare",
            title_size: "l",
            edit: { href: "offer-care?change-answer" },
            items: [{ field: "Can you offer social care or childcare?", value: "Yes" }] },
        ],
        [
          "accommodation_details_section",
          { title: "Details of your offer",
            title_size: "m",
            edit: { href: "rooms-number?change-answer" },
            items: [{ field: "Number of rooms you can offer", value: "500" },
                    { field: "Description of the type of rooms", value: "Very nice" },
                    { field: "How much will you charge",
                      value: "Nothing, it would be a donation" }] },
        ],
        [
          "transport_details_section",
          { title: "Details of your offer",
            title_size: "m",
            edit: { href: "transport-type?change-answer" },
            items: [{ field: "Kind of transport or logistics services you can offer",
                      value: "Yes" },
                    { field: "Description of your transport or logistics services",
                      value: "Yes" },
                    { field: "How much will you charge",
                      value: "Nothing, it would be a donation" }] },
        ],
        [
          "staff_details_section",
          { title: "Details of your offer",
            title_size: "m",
            edit: { href: "offer-staff-type?change-answer" },
            items: [{ field: "What kind of staff can you can offer",
                      value: ["Cleaners (12 people)",
                              "Developers (39 people)",
                              "Medical staff (9 people)"] },
                    { field: "Description of the type of staff",
                      value: "They're well qualified." },
                    { field: "How much will you charge", value: "A reduced price" }] },
        ],
        [
          "space_details_section",
          { title: "Details of your offer",
            title_size: "m",
            edit: { href: "offer-space-type?change-answer" },
            items: [{ field: "Kind of space you can offer", value: ["Warehouse space (123 feet)"] },
                    { field: "Description of your space", value: "Description of space" },
                    { field: "How much will you charge",
                      value: "Nothing, it would be a donation" }] },
        ],
        [
          "care_details_section",
          {
            title: "Details of your offer",
            title_size: "m",
            edit: { href: "offer-care-qualifications?change-answer" },
            items: [{ field: "Kind of care you can offer", value: ["Care for adults"] },
                    { field: "Qualifications or certificates you have", value: ["DBS check"] },
                    { field: "Type of nursing or healthcare qualification",
                      value: "Very good qualifications. This is a description field, really." },
                    { field: "How much will you charge",
                      value: "Nothing, it would be a donation" }],
          },
        ],
      ].each.with_index do |test, _index|
        section_method_name, expected = test
        it "correct data returned for sections #{section_method_name}" do
          expect(helper.send(section_method_name)).to eq(expected)
        end
      end
    end

    context "no to offer" do
      before do
        session.merge!({
          "accommodation": "No",
          "rooms_number": "500",
          "accommodation_description": "Very nice",
          "accommodation_cost": t("coronavirus_form.how_much_charge.options.nothing.label"),

          "offer_transport": "No",
          "transport_type": "No",
          "transport_description": "No",
          "transport_cost": t("coronavirus_form.how_much_charge.options.nothing.label"),

          "offer_staff": "No",
          "offer_staff_type": [
            t("coronavirus_form.questions.offer_staff_type.offer_staff_type.options.cleaners.label"),
            t("coronavirus_form.questions.offer_staff_type.offer_staff_type.options.developers.label"),
            t("coronavirus_form.questions.offer_staff_type.offer_staff_type.options.medical_staff.label"),
          ],
          "offer_staff_number": {
            cleaners_number: 12,
            developers_number: 39,
            medical_staff_number: 9,
          },
          "offer_staff_description": "They're well qualified.",
          "offer_staff_charge": t("coronavirus_form.how_much_charge.options.reduced.label"),

          "offer_space": "No",
          "offer_space_type": t("coronavirus_form.questions.offer_space_type.options.warehouse_space.label").to_s,
          "offer_space_type_other": "Description of space",
          "space_cost": t("coronavirus_form.how_much_charge.options.nothing.label"),

          "offer_care": "No",
          "offer_care_type": [t("coronavirus_form.questions.offer_care_qualifications.offer_care_type.options.adult_care.label")],
          "offer_care_qualifications": [t("coronavirus_form.questions.offer_care_qualifications.care_qualifications.options.dbs_check.label")],
          "offer_care_qualifications_type": "Very good qualifications. This is a description field, really.",
          "care_cost": t("coronavirus_form.how_much_charge.options.nothing.label"),
        })
      end

      [
        # Sections which report the result of offer questions
        [
          "accommodation_section",
          { title: "Accommodation",
            title_size: "l",
            edit: { href: "accommodation?change-answer" },
            items: [{ field: "Can you offer accommodation?", value: "No" }] },
        ],
        [
          "transport_section",
          { title: "Transport",
            title_size: "l",
            edit: { href: "offer-transport?change-answer" },
            items: [{ field: "Can you offer transport or logistics?", value: "No" }] },
        ],
        [
          "staff_section",
          { title: "Staff",
            title_size: "l",
            edit: { href: "offer-staff?change-answer" },
            items: [{ field: "Can you offer staff?", value: "No" }] },
        ],
        [
          "space_section",
          { title: "Space",
            title_size: "l",
            edit: { href: "offer-space?change-answer" },
            items: [{ field: "Can you offer space?", value: "No" }] },
        ],
        [
          "care_section",
          { title: "Social care or childcare",
            title_size: "l",
            edit: { href: "offer-care?change-answer" },
            items: [{ field: "Can you offer social care or childcare?", value: "No" }] },
        ],
        ["accommodation_details_section", nil],
        ["transport_details_section", nil],
        ["care_details_section", nil],
        ["space_details_section", nil],
      ].each.with_index do |test, _index|
        section_method_name, expected = test
        it "correct data returned for sections #section_method_name" do
          expect(helper.send(section_method_name)).to eq(expected)
        end
      end
    end
  end

  describe "#other_support_section" do
    it "shows other support text if it's in the session" do
      session.merge!({ "offer_other_support": "I can offer support in textiles" })
      expect(helper.other_support_section).to eq(
        {
          items: [
            { edit: { href: "offer-other-support?change-answer" },
              field: "Details of other support you can offer",
              value: "I can offer support in textiles" },
          ],
          title: "Other support",
          title_size: "l",
        },
      )
    end

    it "shows a special string if it's not in the session" do
      expect(helper.other_support_section).to eq(
        {
          items: [
            { edit: { href: "offer-other-support?change-answer" },
              field: "Details of other support you can offer",
              value: "I cannot offer any other kind of support" },
          ],
          title: "Other support",
          title_size: "l",
        },
      )
    end

    it "shows a special string if an empty string is stored" do
      session.merge!({ "offer_other_support": "" })
      expect(helper.other_support_section).to eq(
        {
          items: [
            { edit: { href: "offer-other-support?change-answer" },
              field: "Details of other support you can offer",
              value: "I cannot offer any other kind of support" },
          ],
          title: "Other support",
          title_size: "l",
        },
      )
    end
  end

  describe "#expertise_section" do
    it "returns correct data" do
      session.merge!({ "expert_advice_type" => [
        t("coronavirus_form.questions.expert_advice_type.options.construction.label"),
        t("coronavirus_form.questions.expert_advice_type.options.it.label"),
      ] })

      expect(helper.expertise_section).to eq(
        { title: "Services or expertise",
          title_size: "l",
          items: [{ field: "Kind of expertise you offer",
                    value: ["Construction", "IT services"],
                    edit: { href: "expert-advice-type?change-answer" } }] },
      )
    end
  end

  describe "#construction_expertise_section" do
    it "returns correct data when it expertise selected" do
      session.merge!({
        "expert_advice_type" => [
          t("coronavirus_form.questions.expert_advice_type.options.construction.label"),
        ],
        "construction_services" => [
          t("coronavirus_form.questions.construction_services.options.temporary_buildings.label"),
          t("coronavirus_form.questions.construction_services.options.construction_work.label"),
        ],
        "construction_services_other" => "Bricks and that",
        "construction_cost" => t("coronavirus_form.how_much_charge.options.standard.label"),
      })
      expect(helper.construction_expertise_section).to eq({
        title: t("check_your_answers.sections.construction.title"),
        title_size: "m",
        items: [
          { field: t("check_your_answers.fields.construction_services.title"),
            value: [
              t("coronavirus_form.questions.construction_services.options.temporary_buildings.label"),
              t("coronavirus_form.questions.construction_services.options.construction_work.label"),
            ],
            edit: { href: "construction-services?change-answer" } },
          { field: t("check_your_answers.fields.construction_services_other.title"),
            value: "Bricks and that",
            edit: { href: "construction-services-other?change-answer" } },
          { field: t("check_your_answers.fields.construction_cost.title"),
            value: t("coronavirus_form.how_much_charge.options.standard.label"),
            edit: { href: "construction-cost?change-answer" } },
        ],
      })
    end

    it "returns nil when it expertise is not selected but it data present" do
      session.merge!({
        "expert_advice_type" => [],
        "construction_services" => [
          t("coronavirus_form.questions.construction_services.options.temporary_buildings.label"),
          t("coronavirus_form.questions.construction_services.options.construction_work.label"),
        ],
        "construction_services_other" => "Bricks and that",
        "it_cost" => t("coronavirus_form.how_much_charge.options.standard.label"),
      })
      expect(helper.it_expertise_section).to eq(
        nil,
      )
    end
  end

  describe "#it_expertise_section" do
    it "returns correct data when it expertise selected" do
      session.merge!({
        "expert_advice_type" => [
          t("coronavirus_form.questions.expert_advice_type.options.it.label"),
        ],
        "it_services" => [
          t("coronavirus_form.questions.it_services.options.broadband.label"),
          t("coronavirus_form.questions.it_services.options.mobile_phones.label"),
          t("coronavirus_form.questions.it_services.options.video_conferencing.label"),
        ],
        "it_services_other" => "Computers and that",
        "it_cost" => t("coronavirus_form.how_much_charge.options.reduced.label"),
      })
      expect(helper.it_expertise_section).to eq(
        { title: "IT Services",
          title_size: "m",
          items: [
            { field: t("check_your_answers.fields.it_services.title"),
              value: [
                t("coronavirus_form.questions.it_services.options.broadband.label"),
                t("coronavirus_form.questions.it_services.options.mobile_phones.label"),
                t("coronavirus_form.questions.it_services.options.video_conferencing.label"),
              ],
              edit: { href: "it-services?change-answer" } },
            { field: t("check_your_answers.fields.it_services_other.title"),
              value: "Computers and that",
              edit: { href: "it-services-other?change-answer" } },
            { field: t("check_your_answers.fields.it_cost.title"),
              value: t("coronavirus_form.how_much_charge.options.reduced.label"),
              edit: { href: "it-cost?change-answer" } },
          ] },
      )
    end

    it "returns nil when it expertise is not selected but it data present" do
      session.merge!({
        "expert_advice_type" => [],
        "it_services" => [
          t("coronavirus_form.questions.it_services.options.broadband.label"),
          t("coronavirus_form.questions.it_services.options.mobile_phones.label"),
          t("coronavirus_form.questions.it_services.options.video_conferencing.label"),
        ],
        "it_services_other" => "Really good ones",
        "it_cost" => t("coronavirus_form.how_much_charge.options.reduced.label"),
      })
      expect(helper.it_expertise_section).to eq(
        nil,
      )
    end
  end

  describe "#business_details_section" do
    it "generates correct data structure" do
      session.merge!({
        "business_details" =>
          { company_name: "ACME",
            company_number: "12345",
            company_size: t("coronavirus_form.questions.business_details.company_size.options.under_50_people.label"),
            company_location: t("coronavirus_form.questions.business_details.company_location.options.european_union.label"),
            company_postcode: nil },
      })
      expect(helper.business_details_section).to eq(
        { title: "Business Details",
          title_size: "l",
          edit: { href: "business-details?change-answer" },
          items: [{ field: "Company name", value: "ACME" },
                  { field: "Company number", value: "12345" },
                  { field: "Company size", value: t("coronavirus_form.questions.business_details.company_size.options.under_50_people.label") },
                  { field: "Company location", value: t("coronavirus_form.questions.business_details.company_location.options.european_union.label") }] },
      )
    end

    it "does not include postcode data for non UK company" do
      session.merge!({
        "business_details" =>
          { company_name: "ACME",
            company_number: "12345",
            company_size: t("coronavirus_form.questions.business_details.company_size.options.under_50_people.label"),
            company_location: t("coronavirus_form.questions.business_details.company_location.options.european_union.label"),
            company_postcode: "RG1 2NU" },
      })
      expect(helper.business_details_section[:items]).to include(
        { field: "Company location", value: t("coronavirus_form.questions.business_details.company_location.options.european_union.label") },
      )
    end

    it "includes postcode data for UK company" do
      session.merge!({
        "business_details" =>
          { company_name: "ACME",
            company_number: "12345",
            company_size: t("coronavirus_form.questions.business_details.company_size.options.under_50_people.label"),
            company_location: t("coronavirus_form.questions.business_details.company_location.options.united_kingdom.label"),
            company_postcode: "RG1 2NU" },
      })
      expect(helper.business_details_section[:items]).to include(
        { field: "Company location", value: "United Kingdom (RG1 2NU)" },
      )
    end
  end

  describe "#contact_details_section" do
    it "generates correct data structure" do
      session.merge!({
        "contact_details" =>
          { contact_name: "Bob Business",
            role: nil,
            phone_number: "123456",
            email: "bob@business.com" },
      })
      expect(helper.contact_details_section).to eq(
        { title: "Contact Details",
          title_size: "l",
          edit: { href: "contact-details?change-answer" },
          items: [{ field: "Company location", value: "Bob Business" },
                  { field: "Role of main contact", value: nil },
                  { field: "Phone number of main contact", value: "123456" },
                  { field: "Email address of main contact", value: "bob@business.com" }] },
      )
    end
  end
end
