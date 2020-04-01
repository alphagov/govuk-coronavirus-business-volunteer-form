# frozen_string_literal: true

Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  get "/healthcheck", to: proc { [200, {}, %w[OK]] }

  # Start page
  get "/", to: redirect("https://www.gov.uk/coronavirus-support-from-business")

  scope module: "coronavirus_form" do
    # Privacy notice
    get "/privacy", to: "privacy#show"

    # Accessibility statement
    get "/accessibility-statement", to: "accessibility_statement#show"

    # Question pages
    get "/medical-equipment", to: "medical_equipment#show"
    post "/medical-equipment", to: "medical_equipment#submit"

    get "/medical-equipment-type", to: "medical_equipment_type#show"
    post "/medical-equipment-type", to: "medical_equipment_type#submit"

    get "/hotel-rooms", to: "hotel_rooms#show"
    post "/hotel-rooms", to: "hotel_rooms#submit"

    get "/hotel-rooms-number", to: "hotel_rooms_number#show"
    post "/hotel-rooms-number", to: "hotel_rooms_number#submit"

    get "/are-you-a-manufacturer", to: "are_you_a_manufacturer#show"
    post "/are-you-a-manufacturer", to: "are_you_a_manufacturer#submit"

    get "/product-details", to: "product_details#show"
    get "/product-details/:id/delete", to: "product_details#destroy"
    post "/product-details", to: "product_details#submit"

    get "/additional-product", to: "additional_product#show"
    post "/additional-product", to: "additional_product#submit"

    get "/offer-transport", to: "offer_transport#show"
    post "/offer-transport", to: "offer_transport#submit"

    get "/offer-space", to: "offer_space#show"
    post "/offer-space", to: "offer_space#submit"

    get "/offer-space-type", to: "offer_space_type#show"
    post "/offer-space-type", to: "offer_space_type#submit"

    get "/expert-advice", to: "expert_advice#show"
    post "/expert-advice", to: "expert_advice#submit"

    get "/expert-advice-type", to: "expert_advice_type#show"
    post "/expert-advice-type", to: "expert_advice_type#submit"

    get "/transport-type", to: "transport_type#show"
    post "/transport-type", to: "transport_type#submit"

    get "/offer-care", to: "offer_care#show"
    post "/offer-care", to: "offer_care#submit"

    get "/offer-care-qualifications", to: "offer_care_qualifications#show"
    post "/offer-care-qualifications", to: "offer_care_qualifications#submit"

    # Question 10
    get "/offer-other-support", to: "offer_other_support#show"
    post "/offer-other-support", to: "offer_other_support#submit"

    get "/location", to: "location#show"
    post "/location", to: "location#submit"

    # Question 11
    get "/business-details", to: "business_details#show"
    post "/business-details", to: "business_details#submit"

    # Question 12
    get "/contact-details", to: "contact_details#show"
    post "/contact-details", to: "contact_details#submit"

    # Check answers page
    get "/check-your-answers", to: "check_answers#show"
    post "/check-your-answers", to: "check_answers#submit"

    # Final page
    get "/thank-you", to: "thank_you#show"
  end
end
