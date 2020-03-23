# frozen_string_literal: true

Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  get "/healthcheck", to: proc { [200, {}, %w[OK]] }

  # Start page
  get "/", to: "coronavirus_form/start#show"

  # Question pages
  get "/medical-equipment" => "coronavirus_form/medical_equipment#show"
  post "/medical-equipment" => "coronavirus_form/medical_equipment#submit"

  get "/medical-equipment-type" => "coronavirus_form/medical_equipment_type#show"
  post "/medical-equipment-type" => "coronavirus_form/medical_equipment_type#submit"

  get "/hotel-rooms" => "coronavirus_form/hotel_rooms#show"
  post "/hotel-rooms" => "coronavirus_form/hotel_rooms#submit"

  get "/are-you-a-manufacturer" => "coronavirus_form/manufacturer_check#show"
  post "/are-you-a-manufacturer" => "coronavirus_form/manufacturer_check#submit"

  get "/product-details" => "coronavirus_form/product_details#show"
  post "/product-details" => "coronavirus_form/product_details#submit"

  get "/additional-product" => "coronavirus_form/additional_product_check#show"
  post "/additional-product" => "coronavirus_form/additional_product_check#submit"

  get "/which-goods" => "coronavirus_form/which_goods#show"
  post "/which-goods" => "coronavirus_form/which_goods#submit"

  get "/which-services" => "coronavirus_form/which_services#show"
  post "/which-services" => "coronavirus_form/which_services#submit"

  get "/offer-transport" => "coronavirus_form/offer_transport#show"
  post "/offer-transport" => "coronavirus_form/offer_transport#submit"

  get "/offer-space" => "coronavirus_form/offer_space#show"
  post "/offer-space" => "coronavirus_form/offer_space#submit"

  get "/what-kind-of-space" => "coronavirus_form/offer_space_type#show"
  post "/what-kind-of-space" => "coronavirus_form/offer_space_type#submit"

  # Question 6.0: Can you offer expert advice?
  get "/expert-advice" => "coronavirus_form/expert_advice#show"
  post "/expert-advice" => "coronavirus_form/expert_advice#submit"

  # Question 6.1: What kind of expert advice can you offer?
  get "/expert-advice-type" => "coronavirus_form/expert_advice_type#show"
  post "/expert-advice-type" => "coronavirus_form/expert_advice_type#submit"

  get "/what-kind-of-transport" => "coronavirus_form/transport_type#show"
  post "/what-kind-of-transport" => "coronavirus_form/transport_type#submit"

  get "/offer-care" => "coronavirus_form/offer_care#show"
  post "/offer-care" => "coronavirus_form/offer_care#submit"

  get "/offer-community-support" => "coronavirus_form/offer_community_support#show"
  post "/offer-community-support" => "coronavirus_form/offer_community_support#submit"

  # Question 10
  get "/offer-other-support" => "coronavirus_form/offer_other_support#show"
  post "/offer-other-support" => "coronavirus_form/offer_other_support#submit"

  # Question 11
  get "/business-details" => "coronavirus_form/business_details#show"
  post "/business-details" => "coronavirus_form/business_details#submit"

  # Question 12
  get "/contact-details" => "coronavirus_form/contact_details#show"
  post "/contact-details" => "coronavirus_form/contact_details#submit"

  # Check answers page
  get "/check-your-answers" => "coronavirus_form/check_answers#show"
  post "/check-your-answers" => "coronavirus_form/check_answers#submit"

  # Final page
  get "/thank-you" => "coronavirus_form/thank_you#show"
end
