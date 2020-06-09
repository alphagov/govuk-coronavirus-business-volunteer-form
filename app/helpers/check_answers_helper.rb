module CheckAnswersHelper
  def summary_entry(session_path_or_key, description, edit, delete)
    value = session.to_h.dig(*session_path_or_key.is_a?(Array) ? session_path_or_key : [session_path_or_key])

    entry = {
      field: description,
      value: value.is_a?(Array) ? value.map { |v| sanitize(v) } : sanitize(value),
    }
    question = session_path_or_key.is_a?(Array) ? session_path_or_key.first : session_path_or_key
    if edit == true
      entry[:edit] = {
        href: "#{question.dasherize}?change-answer",
      }
    end
    if delete == true
      entry[:delete] = {
        href: "#{question.dasherize}?change-answer",
      }
    end
    entry
  end

  def medical_equipment_section
    {
      title: t("check_your_answers.sections.medical_equipment.title"),
      title_size: "l",
      items: medical_equipment_items,
    }
  end

  def medical_equipment_items
    [
      summary_entry("medical_equipment", t("coronavirus_form.questions.medical_equipment.title"), true, false),
      summary_entry("are_you_a_manufacturer", t("coronavirus_form.questions.are_you_a_manufacturer.title"), true, false),
    ].select { |x| item_has_value(x) }
  end

  def product_details
    products = session["product_details"]
    return [] unless products && products.any?

    products.map.with_index do |product, index|
      {
        title: "Product #{index + 1}",
        title_size: "m",
        items: product_info(product),
        edit: {
          href: product_details_url(product_id: product[:product_id]),
        },
        delete: {
          href: "/product-details/#{product[:product_id]}/delete",
        },
      }
    end
  end

  def product_info(product)
    %w[
      product_name
      equipment_type
      product_quantity
      product_cost
      certification_details
      product_location
      product_url
      lead_time
    ]
      .select { |product_sym| product[product_sym.to_sym] }
      .map do |product_sym|
      summary_data = {
        field: t("coronavirus_form.questions.product_details.#{product_sym}.label"),
        value: sanitize(product[product_sym.to_sym]),
      }
      if product_sym == "product_location" && summary_data[:value] == t("coronavirus_form.questions.product_details.product_location.options.option_uk.label")
        summary_data[:value] = "#{summary_data[:value]} (#{product[:product_postcode]})"
      end
      summary_data
    end
  end

  def accommodation_section
    yes_no_section "accommodation", "accommodation"
  end

  def accommodation_details_section
    details_section "accommodation", "rooms_number", %w[rooms_number accommodation_description accommodation_cost]
  end

  def transport_section
    yes_no_section "transport", "offer_transport"
  end

  def transport_details_section
    details_section "offer_transport", "transport_type", %w[transport_type transport_description transport_cost]
  end

  def staff_section
    yes_no_section "staff", "offer_staff"
  end

  def staff_details_section
    section_data = details_section "offer_staff", "offer_staff_type", %w[offer_staff_type offer_staff_description offer_staff_charge]
    return section_data unless section_data

    label_to_cost_key = t("coronavirus_form.questions.offer_staff_type.offer_staff_type.options").map { |_key, value| [value[:label], value.dig(:description, :id).to_sym] }.to_h
    section_data[:items][0][:value] = section_data[:items][0][:value].map do |item|
      "#{item} (#{session['offer_staff_number'][label_to_cost_key[item]]} people)"
    end
    section_data
  end

  def space_section
    yes_no_section "space", "offer_space"
  end

  def space_details_section
    section_data = details_section "offer_space", "offer_space_type", %w[offer_space_type offer_space_type_other space_cost]
    return section_data unless section_data

    label_to_space_description = t(
      "coronavirus_form.questions.offer_space_type.options",
    ).map { |_key, value| [value[:label], value.dig(:description, :id)] }.to_h
    section_data[:items][0][:value] = section_data[:items][0][:value].map do |item|
      "#{item} (#{session[label_to_space_description[item]]})"
    end
    section_data
  end

  def care_section
    yes_no_section "care", "offer_care"
  end

  def care_details_section
    details_section "offer_care", "offer_care_qualifications", %w[offer_care_type offer_care_qualifications offer_care_qualifications_type care_cost]
  end

  def location_section
    {
      title: t("check_your_answers.sections.location.title"),
      title_size: "l",
      items: [summary_entry("location", t("check_your_answers.fields.location.title"), true, false)],
    }
  end

  def expertise_section
    {
      title: t("check_your_answers.sections.expertise.title"),
      title_size: "l",
      items: [summary_entry("expert_advice_type", t("check_your_answers.fields.expert_advice_type.title"), true, false)],
    }
  end

  def construction_expertise_section
    expertise_details_section "construction"
  end

  def it_expertise_section
    expertise_details_section "it"
  end

  def business_details_section
    section_data = {
      title: t("check_your_answers.sections.business_details.title"),
      title_size: "l",
      edit: {
        href: "business-details?change-answer",
      },
      items: [
        summary_entry(["business_details", :company_name], t("check_your_answers.fields.company_name.title"), false, false),
        summary_entry(["business_details", :company_number], t("check_your_answers.fields.company_number.title"), false, false),
        summary_entry(["business_details", :company_size], t("check_your_answers.fields.company_size.title"), false, false),
        # TODO: special case postcode
        summary_entry(["business_details", :company_location], t("check_your_answers.fields.company_location.title"), false, false),
      ],
    }
    country = section_data[:items].last[:value]
    if country == t("coronavirus_form.questions.business_details.company_location.options.united_kingdom.label")
      section_data[:items].last[:value] = "#{country} (#{session['business_details'][:company_postcode]})"
    end
    section_data
  end

  def contact_details_section
    {
      title: t("check_your_answers.sections.contact_details.title"),
      title_size: "l",
      edit: {
        href: "contact-details?change-answer",
      },
      items: [
        summary_entry(["contact_details", :contact_name], t("check_your_answers.fields.contact_name.title"), false, false),
        summary_entry(["contact_details", :role], t("check_your_answers.fields.role.title"), false, false),
        summary_entry(["contact_details", :phone_number], t("check_your_answers.fields.phone.title"), false, false),
        # TODO: special case postcode
        summary_entry(["contact_details", :email], t("check_your_answers.fields.email.title"), false, false),
      ],
    }
  end

  def other_support_section
    section_data = {
      title: t("check_your_answers.sections.offer_other_support.title"),
      title_size: "l",
      items: [summary_entry("offer_other_support", t("check_your_answers.fields.offer_other_support.title"), true, false)],
    }
    unless item_has_value(section_data[:items][0])
      section_data[:items][0][:value] = "I cannot offer any other kind of support"
    end
    section_data
  end

private

  def item_has_value(item)
    ["", nil].exclude?(item[:value])
  end

  def yes_no_section(section_key, session_key)
    {
      title: t("check_your_answers.sections.#{section_key}.title"),
      title_size: "l",
      edit: {
        href: "#{session_key.dasherize}?change-answer",
      },
      items: [
        summary_entry(session_key, t("coronavirus_form.questions.#{session_key}.title"), false, false),
      ],
    }
  end

  def details_section(key, edit_link_key, item_keys)
    # Annoyingly their are two possible paths in the YAML.
    if [t("coronavirus_form.questions.#{key}.options.no_option.label"), t("coronavirus_form.questions.#{key}.options.option_no.label")].include?(session.to_h[key])
      return nil
    end

    items = item_keys.map do |item_key|
      summary_entry(item_key, t("check_your_answers.fields.#{item_key}.title"), false, false)
    end
    items = items.select { |x| item_has_value(x) }
    return nil if items.empty?

    {
      title: t("check_your_answers.sections.details_subsection.title"),
      title_size: "m",
      edit: {
        href: "#{edit_link_key.dasherize}?change-answer",
      },
      items: items,
    }
  end

  def expertise_details_section(base_key)
    return unless session["expert_advice_type"].include?(t("coronavirus_form.questions.expert_advice_type.options.#{base_key}.label"))

    services_key = "#{base_key}_services"
    other_key = "#{base_key}_services_other"
    cost_key = "#{base_key}_cost"
    {
      title: t("check_your_answers.sections.#{base_key}.title"),
      title_size: "m",
      items: [
        summary_entry(services_key, t("check_your_answers.fields.#{services_key}.title"), true, false),
        summary_entry(other_key, t("check_your_answers.fields.#{other_key}.title"), true, false),
        summary_entry(cost_key, t("check_your_answers.fields.#{cost_key}.title"), true, false),
      ],
    }
  end
end
