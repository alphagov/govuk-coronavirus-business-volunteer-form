# frozen_string_literal: true

class CoronavirusForm::CheckAnswersController < ApplicationController
  before_action :check_first_question_answered, only: :show

  def show
    session[:check_answers_seen] = true

    render "coronavirus_form/check_answers"
  end

  def submit
    submission_reference = reference_number

    session[:reference_id] = submission_reference

    FormResponse.create(
      ReferenceId: submission_reference,
      UnixTimestamp: Time.zone.now,
      FormResponse: session,
    )

    reset_session

    redirect_to controller: "coronavirus_form/thank_you", action: "show", reference_number: submission_reference
  end

private

  helper_method :items

  def reference_number
    timestamp = Time.zone.now.strftime("%Y%m%d-%H%M%S")
    random_id = SecureRandom.hex(3).upcase
    "#{timestamp}-#{random_id}"
  end

  def previous_path
    contact_details_path
  end

  def items
    @items ||= begin
      questions.map { |question|
        # We have answers as strings and hashes. The hashes need a little more
        # work to make them readable.

        next if question.eql?("medical_equipment_type")

        if question.eql?("additional_product")
          next add_extra_product(question)
        end

        if question.eql?("product_details")
          next product_details(session[question])
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
  end

  def add_extra_product(question)
    {
      field: sanitize(t("coronavirus_form.questions.#{question}.link")),
    }
  end

  def product_details(products)
    return unless products && products.any?

    joiner = "<br>"
    products.map do |product|
      prod = []
      prod << if product["medical_equipment_type_other"]
                "Type: #{product['medical_equipment_type']} (#{product['medical_equipment_type_other']})"
              else
                "Type: #{product['medical_equipment_type']}"
              end
      prod << "Product: #{product['product_name']}" if product["product_name"]
      prod << "Equipment type: #{product['equipment_type']}" if product["equipment_type"]
      prod << "Cost: #{product['product_cost']}" if product["product_cost"]
      prod << "Certification details: #{product['certification_details']}" if product["certification_details"]
      prod << "Location: #{product['product_location']}" if product["product_location"]
      prod << "Postcode: #{product['product_postcode']}" if product["product_postcode"]
      prod << "URL: #{product['product_url']}" if product["product_url"]
      prod << "Lead time: #{product['lead_time']}" if product["lead_time"]

      {
        field: "Details for product #{product['product_name']}",
        value: sanitize(prod.join(joiner)),
        edit: {
          href: "/product-details?product_id=#{product['product_id']}",
        },
      }
    end
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
      joiner = "<br>"
    elsif question.eql?("support_address")
      concatenated_answer = answer.values.compact
      joiner = ",<br>"
    elsif question.eql?("date_of_birth")
      concatenated_answer = answer.values.compact
      joiner = "/"
    else
      concatenated_answer = answer.values.compact
    end

    concatenated_answer.join(joiner)
  end

  def questions
    @questions ||= YAML.load_file(Rails.root.join("config/locales/en.yml"))
    @questions["en"]["coronavirus_form"]["questions"].keys
  end
end
