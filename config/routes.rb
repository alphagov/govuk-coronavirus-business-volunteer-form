# frozen_string_literal: true

Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  get "/healthcheck", to: proc { [200, {}, %w[OK]] }

  # Root redirects to start page
  get "/", to: redirect("https://www.gov.uk/coronavirus-support-from-business")

  scope module: "coronavirus_form" do
    first_question = "/accommodation"

    get "/start", to: redirect(path: first_question)

    # Redirects for A-AB-B deployment...
    get "/medical-equipment", to: redirect(path: "accommodation#show")
    post "/medical-equipment", to: redirect(path: "accommodation#show")
    get "/medical-equipment-type", to: redirect(path: "accommodation#show")
    post "/medical-equipment-type", to: redirect(path: "accommodation#show")
    get "/testing-equipment", to: redirect(path: "accommodation#show")

    # Question 2.0: Can you offer accommodation?
    get "/accommodation", to: "accommodation#show"
    post "/accommodation", to: "accommodation#submit"

    # Question 2.1: How many rooms can you offer?
    get "/rooms-number", to: "rooms_number#show"
    post "/rooms-number", to: "rooms_number#submit"

    # Question 3.0: Can you offer transport or logistics?
    get "/offer-transport", to: "offer_transport#show"
    post "/offer-transport", to: "offer_transport#submit"

    # Question 3.1: What kind of services can you offer?
    get "/transport-type", to: "transport_type#show"
    post "/transport-type", to: "transport_type#submit"

    # Question 4.0: Can you offer space?
    get "/offer-space", to: "offer_space#show"
    post "/offer-space", to: "offer_space#submit"

    # Question 4.1: What kind of space can you offer?
    get "/offer-space-type", to: "offer_space_type#show"
    post "/offer-space-type", to: "offer_space_type#submit"

    # Question 5.0: Can you offer staff?
    get "/offer-staff", to: "offer_staff#show"
    post "/offer-staff", to: "offer_staff#submit"

    # Question 5.1: What kind of staff can you offer?
    get "/offer-staff-type", to: "offer_staff_type#show"
    post "/offer-staff-type", to: "offer_staff_type#submit"

    # Question 6.0: What kind of expertise can you offer?
    get "/expert-advice-type", to: "expert_advice_type#show"
    post "/expert-advice-type", to: "expert_advice_type#submit"

    # Question 6.1: What kind of construction services can you offer?
    get "/construction-services", to: "construction_services#show"
    post "/construction-services", to: "construction_services#submit"

    # Question 6.2: What kind of it services can you offer?
    get "/it-services", to: "it_services#show"
    post "/it-services", to: "it_services#submit"

    # Question 7.0: Can you offer social care or childcare?
    get "/offer-care", to: "offer_care#show"
    post "/offer-care", to: "offer_care#submit"

    # Question 7.1: What kind of care can you offer?
    get "/offer-care-qualifications", to: "offer_care_qualifications#show"
    post "/offer-care-qualifications", to: "offer_care_qualifications#submit"

    # Question 8.0: Can you offer any other kind of support?
    get "/offer-other-support", to: "offer_other_support#show"
    post "/offer-other-support", to: "offer_other_support#submit"

    # Question 9.0: Where can you offer your services?
    get "/location", to: "location#show"
    post "/location", to: "location#submit"

    # Question 10.0: Your business details
    get "/business-details", to: "business_details#show"
    post "/business-details", to: "business_details#submit"

    # Question 11.0: Contact details
    get "/contact-details", to: "contact_details#show"
    post "/contact-details", to: "contact_details#submit"

    # Check answers page: Are you ready to send the form?
    get "/check-your-answers", to: "check_answers#show"
    post "/check-your-answers", to: "check_answers#submit"

    # Final page
    get "/thank-you", to: "thank_you#show"

    # Other page - Cookie preferences
    get "/cookies", to: "cookies#show"

    # Other page - Privacy notice
    get "/privacy", to: "privacy#show"

    # Other page - Accessibility statement
    get "/accessibility-statement", to: "accessibility_statement#show"

    # Other page - Session expired notice
    get "/session-expired", to: "session_expired#show"
  end
end
