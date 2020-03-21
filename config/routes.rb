# frozen_string_literal: true

Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  get "/healthcheck", to: proc { [200, {}, %w[OK]] }

  # Start page
  get "/", to: "business_volunteering/start#show"

  # Question pages
  get "/business-volunteering/do-you-have-medical-equipment-to-offer" => "business_volunteering/medical_equipment#show"
  post "/business-volunteering/do-you-have-medical-equipment-to-offer" => "business_volunteering/medical_equipment#submit"

  get "/business-volunteering/what-kind-of-medical-equipment" => "business_volunteering/medical_equipment_type#show"
  post "/business-volunteering/what-kind-of-medical-equipment" => "business_volunteering/medical_equipment_type#submit"

  get "/business-volunteering/do-you-have-hotel-rooms-to-offer" => "business_volunteering/hotel_rooms#show"
  post "/business-volunteering/do-you-have-hotel-rooms-to-offer" => "business_volunteering/hotel_rooms#submit"

  get "/business-volunteering/which-goods" => "business_volunteering/which_goods#show"
  post "/business-volunteering/which-goods" => "business_volunteering/which_goods#submit"

  get "/business-volunteering/which-services" => "business_volunteering/which_services#show"
  post "/business-volunteering/which-services" => "business_volunteering/which_services#submit"

  get "/business-volunteering/offer-food" => "business_volunteering/offer_food#show"
  post "/business-volunteering/offer-food" => "business_volunteering/offer_food#submit"

  # Check answers page
  get "/business-volunteering/check-your-answers" => "business_volunteering/check_answers#show"
  post "/business-volunteering/check-your-answers" => "business_volunteering/check_answers#submit"

  # Final page
  get "/business-volunteering/thank-you" => "business_volunteering/thank_you#show"
end
