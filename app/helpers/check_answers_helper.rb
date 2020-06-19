module CheckAnswersHelper
  EXCLUDED_QUESTIONS = %w[
    additional_product
    medical_equipment
    medical_equipment_type
    product_details
  ].freeze

  SKIPPABLE_QUESTIONS = %w[
    rooms_number
    accommodation_cost
    transport_type
    transport_cost
    offer_space_type
    space_cost
    offer_care_qualifications
    care_cost
    offer_staff_type
    offer_staff_charge
    construction_services
    construction_services_other
    construction_cost
    it_services
    it_services_other
    it_cost
  ].freeze

  def items
    items = questions.map do |question|
      # We have answers as strings and hashes. The hashes need a little more
      # work to make them readable.

      next if skip_question?(question)

      next transport_type if question.eql?("transport_type")
      next offer_care_qualifications if question.eql?("offer_care_qualifications")
      next offer_staff_type if question.eql?("offer_staff_type")
      next link_to_parent_page(question, "offer_staff_type") if question.eql?("offer_staff_charge")
      next link_to_parent_page(question, "construction_services") if question.eql?("construction_services_other")
      next link_to_parent_page(question, "construction_services") if question.eql?("construction_cost")
      next link_to_parent_page(question, "it_services") if question.eql?("it_services_other")
      next link_to_parent_page(question, "it_services") if question.eql?("it_cost")
      next link_to_parent_page(question, "transport_type") if question.eql?("transport_cost")
      next link_to_parent_page(question, "offer_care_qualifications") if question.eql?("care_cost")
      next link_to_parent_page(question, "rooms_number") if question.eql?("accommodation_cost")
      next link_to_parent_page(question, "offer_space_type") if question.eql?("space_cost")

      value = concat_answer(session[question], question)

      [{
        field: t("coronavirus_form.questions.#{question}.title"),
        value: sanitize(value),
        edit: {
          href: "#{question.dasherize}?change-answer",
        },
      }]
    end

    items.compact.flatten
  end

  def skip_question?(question)
    return true if question.in?(EXCLUDED_QUESTIONS)

    question.in?(SKIPPABLE_QUESTIONS) && session[question].blank?
  end

  def transport_type
    [{
      field: t("coronavirus_form.questions.transport_type.title"),
      value: sanitize(transport_type_info),
      edit: {
        href: "transport-type?change-answer",
      },
    }]
  end

  def transport_type_info
    answer = []
    answer << Array(session[:transport_type]).flatten.to_sentence
    answer << session[:transport_description]

    answer.join("<br>")
  end

  def offer_care_qualifications
    [{
      field: t("coronavirus_form.questions.offer_care_qualifications.offer_care_type.title"),
      value: sanitize(Array(session[:offer_care_type]).flatten.to_sentence),
      edit: {
        href: "offer-care-qualifications?change-answer",
      },
    },
     {
       field: t("coronavirus_form.questions.offer_care_qualifications.care_qualifications.title"),
       value: sanitize(Array(session[:offer_care_qualifications]).flatten.to_sentence),
       edit: {
         href: "offer-care-qualifications?change-answer",
       },
     }]
  end

  def link_to_parent_page(question, parent_question)
    [{
      field: t("coronavirus_form.questions.#{question}.title"),
      value: sanitize(concat_answer(session[question.to_sym], question)),
      edit: {
        href: "#{parent_question.dasherize}?change-answer",
      },
    }]
  end

  def offer_staff_type
    [{
      field: t("coronavirus_form.questions.offer_staff_type.title"),
      value: sanitize(Array(session[:offer_staff_type]).flatten.to_sentence),
      edit: {
        href: "offer-staff-type?change-answer",
      },
    },
     {
       field: t("coronavirus_form.questions.offer_staff_type.offer_staff_description.label"),
       value: sanitize(session[:offer_staff_description]),
       edit: {
         href: "offer-staff-type?change-answer",
       },
     }]
  end

  def concat_answer(answer, question)
    return unless answer
    return answer if answer.is_a?(String)
    return answer.flatten.to_sentence if answer.is_a?(Array)

    concatenated_answer = []
    joiner = " "

    if question.eql?("contact_details")
      concatenated_answer << "Name: #{answer[:contact_name]}" if answer[:contact_name]
      concatenated_answer << "Role: #{answer[:role]}" if answer[:role]
      concatenated_answer << "Phone number: #{answer[:phone_number]}" if answer[:phone_number]
      concatenated_answer << "Email: #{answer[:email]}" if answer[:email]
      joiner = "<br>"
    elsif question.eql?("business_details")
      concatenated_answer << "Company name: #{answer[:company_name]}" if answer[:company_name]
      concatenated_answer << "Company registered in the UK: #{answer[:company_is_uk_registered]}"
      concatenated_answer << "Company number: #{answer[:company_number]}" if answer[:company_number].present?
      concatenated_answer << "Company size number: #{answer[:company_size]}" if answer[:company_size]
      concatenated_answer << "Company location: #{answer[:company_location]}" if answer[:company_location]
      concatenated_answer << "Company postcode: #{answer[:company_postcode]}" if answer[:company_postcode]
      joiner = "<br>"
    else
      concatenated_answer = answer.values.compact
    end

    concatenated_answer.join(joiner)
  end

  def questions
    questions ||= YAML.load_file(Rails.root.join("config/locales/en.yml"))
    questions["en"]["coronavirus_form"]["questions"].keys
  end
end
