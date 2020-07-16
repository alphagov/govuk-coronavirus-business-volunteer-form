module CheckAnswersHelper
  def sections_scope
    "coronavirus_form.check_your_answers.sections"
  end

  def charge_text
    I18n.t("coronavirus_form.check_your_answers.charge")
  end

  def question_items(question)
    if session[question].is_a?(Array)
      [{
        field: I18n.t("coronavirus_form.questions.#{question}.title"),
        value: render("govuk_publishing_components/components/list", {
          visible_counters: true,
          items: session[question],
        }),
      }]
    else
      [{
        field: I18n.t("coronavirus_form.questions.#{question}.title"),
        value: session[question],
      }]
    end
  end

  def sections
    %w[
      accommodation
      transport
      space
      staff
      care
      services
      other_support
      location
      business_details
      contact_details
    ]
  end

  def accommodation_items
    [
      {
        field: I18n.t("accommodation.type", scope: sections_scope),
        value: session[:rooms_number],
      },
      {
        field: I18n.t("accommodation.description", scope: sections_scope),
        value: session[:accommodation_description],
      },
      {
        field: charge_text,
        value: session[:accommodation_cost],
      },
    ]
  end

  def transport_items
    [
      {
        field: I18n.t("transport.type", scope: sections_scope),
        value: render("govuk_publishing_components/components/list", {
          visible_counters: true,
          items: session[:transport_type],
        }),
      },
      {
        field: I18n.t("transport.description", scope: sections_scope),
        value: session[:transport_description],
      },
      {
        field: charge_text,
        value: session[:transport_cost],
      },
    ]
  end

  def space_items
    [
      {
        field: I18n.t("space.type", scope: sections_scope),
        value: render("govuk_publishing_components/components/list", {
          visible_counters: true,
          items: space_item_value_list,
        }),
      },
      {
        field: I18n.t("space.description", scope: sections_scope),
        value: session[:general_space_description],
      },
      {
        field: charge_text,
        value: session[:space_cost],
      },
    ]
  end

  def space_item_value_list
    session[:offer_space_type].map do |item|
      case item
      when "Warehouse space"
        value = session[:warehouse_space_description]
      when "Office space"
        value = session[:office_space_description]
      when "Other"
        value = session[:offer_space_type_other]
      end

      delimited_number = number_with_delimiter(value.to_i, delimiter: ",")
      "#{item} (#{pluralize(delimited_number, 'square foot')})"
    end
  end

  def staff_items
    [
      {
        field: I18n.t("staff.type", scope: sections_scope),
        value: render("govuk_publishing_components/components/list", {
          visible_counters: true,
          items: staff_item_value_list,
        }),
      },
      {
        field: I18n.t("staff.description", scope: sections_scope),
        value: session[:offer_staff_description],
      },
      {
        field: charge_text,
        value: session[:offer_staff_charge],
      },
    ]
  end

  def staff_item_value_list
    session[:offer_staff_type].map do |item|
      case item
      when "Cleaners"
        value = session.dig(:offer_staff_number, :cleaners_number)
      when "Developers"
        value = session.dig(:offer_staff_number, :developers_number)
      when "Medical staff"
        value = session.dig(:offer_staff_number, :medical_staff_number)
      when "Office staff"
        value = session.dig(:offer_staff_number, :office_staff_number)
      when "Security staff"
        value = session.dig(:offer_staff_number, :security_staff_number)
      when "Trainers or coaches"
        value = session.dig(:offer_staff_number, :trainers_number)
      when "Translators"
        value = session.dig(:offer_staff_number, :translators_number)
      when "Other staff"
        value = session.dig(:offer_staff_number, :other_staff_number)
      end

      delimited_number = number_with_delimiter(value.to_i, delimiter: ",")
      "#{item} (#{pluralize(delimited_number, 'person')})"
    end
  end
end
