# frozen_string_literal: true

Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  get "/healthcheck", to: proc { [200, {}, %w[OK]] }

  # Start page
  get "/", to: "coronavirus_form/start#show"

  # Question pages
  get "/coronavirus-form/medical-equipment" => "coronavirus_form/medical_equipment#show"
  post "/coronavirus-form/medical-equipment" => "coronavirus_form/medical_equipment#submit"

  get "/coronavirus-form/medical-equipment-type" => "coronavirus_form/medical_equipment_type#show"
  post "/coronavirus-form/medical-equipment-type" => "coronavirus_form/medical_equipment_type#submit"

  get "/coronavirus-form/hotel-rooms" => "coronavirus_form/hotel_rooms#show"
  post "/coronavirus-form/hotel-rooms" => "coronavirus_form/hotel_rooms#submit"

  get "/coronavirus-form/are-you-a-manufacturer" => "coronavirus_form/manufacturer_check#show"
  post "/coronavirus-form/are-you-a-manufacturer" => "coronavirus_form/manufacturer_check#submit"

  get "/coronavirus-form/product-details" => "coronavirus_form/product_details#show"
  post "/coronavirus-form/product-details" => "coronavirus_form/product_details#submit"

  get "/coronavirus-form/additional-product" => "coronavirus_form/additional_product_check#show"
  post "/coronavirus-form/additional-product" => "coronavirus_form/additional_product_check#submit"

  get "/coronavirus-form/which-goods" => "coronavirus_form/which_goods#show"
  post "/coronavirus-form/which-goods" => "coronavirus_form/which_goods#submit"

  get "/coronavirus-form/which-services" => "coronavirus_form/which_services#show"
  post "/coronavirus-form/which-services" => "coronavirus_form/which_services#submit"

  get "/coronavirus-form/offer-food" => "coronavirus_form/offer_food#show"
  post "/coronavirus-form/offer-food" => "coronavirus_form/offer_food#submit"

  get "/coronavirus-form/offer-transport" => "coronavirus_form/offer_transport#show"
  post "/coronavirus-form/offer-transport" => "coronavirus_form/offer_transport#submit"

  get "/coronavirus-form/offer-space" => "coronavirus_form/offer_space#show"
  post "/coronavirus-form/offer-space" => "coronavirus_form/offer_space#submit"

  get "/coronavirus-form/expert_advice" => "coronavirus_form/expert_advice#show"
  post "/coronavirus-form/expert_advice" => "coronavirus_form/expert_advice#submit"

  get "/coronavirus-form/what-kind-of-transport" => "coronavirus_form/transport_type#show"
  post "/coronavirus-form/what-kind-of-transport" => "coronavirus_form/transport_type#submit"

  get "/coronavirus-form/offer-care" => "coronavirus_form/offer_care#show"
  post "/coronavirus-form/offer-care" => "coronavirus_form/offer_care#submit"

  get "/coronavirus-form/offer-community-support" => "coronavirus_form/offer_community_support#show"
  post "/coronavirus-form/offer-community-support" => "coronavirus_form/offer_community_support#submit"

  # Check answers page
  get "/coronavirus-form/check-your-answers" => "coronavirus_form/check_answers#show"
  post "/coronavirus-form/check-your-answers" => "coronavirus_form/check_answers#submit"

  # Final page
  get "/coronavirus-form/thank-you" => "coronavirus_form/thank_you#show"
end
