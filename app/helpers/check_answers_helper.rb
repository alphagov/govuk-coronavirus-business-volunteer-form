module CheckAnswersHelper
  SKIPPABLE_QUESTIONS = %w[
    are_you_a_manufacturer
    product_details
    rooms_number
    transport_type
    transport_cost
    offer_space_type
    space_cost
    offer_care_qualifications
    care_cost
  ].freeze

  def items
    items = questions.map do |question|
      # We have answers as strings and hashes. The hashes need a little more
      # work to make them readable.

      next if skip_question?(question)

      next product_details if question.eql?("product_details")
      next transport_type if question.eql?("transport_type")
      next offer_care_qualifications if question.eql?("offer_care_qualifications")

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
    return true if question.eql?("medical_equipment_type")

    question.in?(SKIPPABLE_QUESTIONS) && session[question].blank?
  end

  def additional_product_index
    items.index { |item| item[:field] == t("coronavirus_form.questions.additional_product.title") }
  end

  def items_part_1
    items.select.with_index { |_, index| index < additional_product_index }
  end

  def items_part_2
    items.select.with_index { |_, index| index > additional_product_index }
  end

  def product_details
    products = session["product_details"]
    return unless products && products.any?

    products.map do |product|
      {
        field: "Details for product #{product[:product_name]}",
        value: sanitize(product_info(product)),
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
    prod = []
    prod << "Type: #{product[:medical_equipment_type]}"
    prod << "Product: #{product[:product_name]}" if product[:product_name]
    prod << "Equipment type: #{product[:equipment_type]}" if product[:equipment_type]
    prod << "Quantity: #{product[:product_quantity]}" if product[:product_quantity]
    prod << "Cost: #{product[:product_cost]}" if product[:product_cost]
    prod << "Certification details: #{product[:certification_details]}" if product[:certification_details]
    prod << "Location: #{product[:product_location]}" if product[:product_location]
    prod << "Postcode: #{product[:product_postcode]}" if product[:product_postcode]
    prod << "URL: #{product[:product_url]}" if product[:product_url]
    prod << "Lead time: #{product[:lead_time]}" if product[:lead_time]

    prod.join("<br>")
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
      concatenated_answer << "Company number: #{answer[:company_number]}" if answer[:company_number]
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
