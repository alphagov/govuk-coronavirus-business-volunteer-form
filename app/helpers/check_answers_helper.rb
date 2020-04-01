module CheckAnswersHelper
  def items
    questions.map { |question|
      # We have answers as strings and hashes. The hashes need a little more
      # work to make them readable.

      next if question.eql?("medical_equipment_type")

      if question.eql?("product_details")
        next product_details(session[question])
      end

      if question.eql?("transport_type")
        next transport_type
      end

      if question.eql?("offer_care_qualifications")
        next offer_care_qualifications
      end

      value = case session[question]
              when Hash
                concat_answer(session[question], question)
              when Array
                session[question].flatten.to_sentence
              else
                session[question]
              end

      [{
        field: t("coronavirus_form.questions.#{question}.title"),
        value: sanitize(value),
        edit: {
          href: "#{question.dasherize}?change-answer",
        },
      }]
    }.compact.flatten
  end

  def additional_product_index
    items.index { |item| item[:field] === t("coronavirus_form.questions.additional_product.title") }
  end

  def items_part_1
    items.select.with_index { |_, index| index < additional_product_index }
  end

  def items_part_2
    items.select.with_index { |_, index| index > additional_product_index }
  end

  def product_details(products)
    return unless products && products.any?

    products.map do |product|
      {
        field: "Details for product #{product['product_name']}",
        value: sanitize(product_info(product)),
        edit: {
          href: product_details_url(product_id: product["product_id"]),
        },
        delete: {
          href: "/product-details/#{product['product_id']}/delete",
        },
      }
    end
  end

  def product_info(product)
    prod = []
    prod << if product["medical_equipment_type_other"]
              "Type: #{product['medical_equipment_type']} (#{product['medical_equipment_type_other']})"
            else
              "Type: #{product['medical_equipment_type']}"
            end
    prod << "Product: #{product['product_name']}" if product["product_name"]
    prod << "Equipment type: #{product['equipment_type']}" if product["equipment_type"]
    prod << "Quantity: #{product['product_quantity']}" if product["product_quantity"]
    prod << "Cost: #{product['product_cost']}" if product["product_cost"]
    prod << "Certification details: #{product['certification_details']}" if product["certification_details"]
    prod << "Location: #{product['product_location']}" if product["product_location"]
    prod << "Postcode: #{product['product_postcode']}" if product["product_postcode"]
    prod << "URL: #{product['product_url']}" if product["product_url"]
    prod << "Lead time: #{product['lead_time']}" if product["lead_time"]

    prod.join("<br>")
  end

  def transport_type
    answer = []
    answer << Array(session["transport_type"]).flatten.to_sentence
    answer << session["transport_description"]

    [{
      field: t("coronavirus_form.questions.transport_type.title"),
      value: sanitize(answer.join("<br>")),
      edit: {
        href: "transport-type?change-answer",
      },
    }]
  end

  def offer_care_qualifications
    [{
      field: t("coronavirus_form.questions.offer_care_qualifications.offer_care_type.title"),
      value: sanitize(Array(session["offer_care_type"]).flatten.to_sentence),
      edit: {
        href: "offer-care-qualifications?change-answer",
      },
    }, {
      field: t("coronavirus_form.questions.offer_care_qualifications.care_qualifications.title"),
      value: sanitize(Array(session["offer_care_qualifications"]).flatten.to_sentence),
      edit: {
        href: "offer-care-qualifications?change-answer",
      },
    }]
  end

  def concat_answer(answer, question)
    concatenated_answer = []
    joiner = " "

    if question.eql?("contact_details")
      concatenated_answer << "Name: #{answer['contact_name']}" if answer["contact_name"]
      concatenated_answer << "Role: #{answer['role']}" if answer["role"]
      concatenated_answer << "Phone number: #{answer['phone_number']}" if answer["phone_number"]
      concatenated_answer << "Email: #{answer['email']}" if answer["email"]
      joiner = "<br>"
    elsif question.eql?("business_details")
      concatenated_answer << "Company name: #{answer['company_name']}" if answer["company_name"]
      concatenated_answer << "Company number: #{answer['company_number']}" if answer["company_number"]
      concatenated_answer << "Company size number: #{answer['company_size']}" if answer["company_size"]
      concatenated_answer << "Company location: #{answer['company_location']}" if answer["company_location"]
      concatenated_answer << "Company postcode: #{answer['company_postcode']}" if answer["company_postcode"]
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
