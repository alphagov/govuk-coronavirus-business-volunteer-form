# frozen_string_literal: true

require "spec_helper"

RSpec.describe CoronavirusForm::HotelRoomsNumberController, type: :controller do
  include_examples "session expiry"

  let(:current_template) { "coronavirus_form/hotel_rooms_number" }
  let(:session_key) { :hotel_rooms_number }

  describe "GET show" do
    it "renders the form when first question answered" do
      session["medical_equipment"] = "Yes"
      get :show
      expect(response).to render_template(current_template)
    end

    it "redirects to first question when first question not answered" do
      get :show
      expect(response).to redirect_to(medical_equipment_path)
    end
  end

  describe "POST submit" do
    let(:selected) { "100" }

    it "sets session variables" do
      post :submit, params: { hotel_rooms_number: selected }
      expect(session[session_key]).to eq selected
    end

    it "redirects to check your answers if check your answers previously seen" do
      session[:check_answers_seen] = true
      post :submit, params: { hotel_rooms_number: selected }

      expect(response).to redirect_to(check_your_answers_path)
    end

    it "validates a value is entered" do
      post :submit, params: { hotel_rooms_number: "" }

      expect(response).to render_template(current_template)
    end
  end
end
