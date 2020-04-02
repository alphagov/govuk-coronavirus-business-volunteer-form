# frozen_string_literal: true

require "spec_helper"

RSpec.describe CoronavirusForm::HotelRoomsController, type: :controller do
  include_examples "session expiry"

  let(:current_template) { "coronavirus_form/hotel_rooms" }
  let(:session_key) { :hotel_rooms }

  describe "GET show" do
    it "renders the form when first question answered" do
      session["medical_equipment"] = "Yes"
      get :show
      expect(response).to render_template(current_template)
    end

    it "redirects to first question when first question not answered" do
      get :show
      expect(response).to redirect_to({
        controller: "medical_equipment",
        action: "show",
      })
    end
  end

  describe "POST submit" do
    let(:selected) { permitted_values.sample }
    let(:permitted_values) do
      I18n.t("coronavirus_form.questions.hotel_rooms.options").map { |_, item| item[:label] }
    end

    it "sets session variables" do
      post :submit, params: { hotel_rooms: selected }
      expect(session[session_key]).to eq selected
    end

    it "redirects to hotel room numbers for a yes stay in response" do
      post :submit, params: { hotel_rooms: I18n.t("coronavirus_form.questions.hotel_rooms.options.yes_staying_in.label") }
      expect(response).to redirect_to(hotel_rooms_number_path)
    end

    it "redirects to hotel room numbers for a yes all uses response" do
      post :submit, params: { hotel_rooms: I18n.t("coronavirus_form.questions.hotel_rooms.options.yes_all_uses.label") }
      expect(response).to redirect_to(hotel_rooms_number_path)
    end

    it "redirects to transport for a no response" do
      post :submit, params: { hotel_rooms: I18n.t("coronavirus_form.questions.hotel_rooms.options.no_option.label") }
      expect(response).to redirect_to(offer_transport_path)
    end

    it "redirects to check your answers if check your answers previously seen and answer is no" do
      session[:check_answers_seen] = true
      post :submit, params: { hotel_rooms: I18n.t("coronavirus_form.questions.hotel_rooms.options.no_option.label") }

      expect(response).to redirect_to(check_your_answers_path)
    end

    it "validates any option is chosen" do
      post :submit, params: { hotel_rooms: "" }

      expect(response).to render_template(current_template)
    end

    it "validates a valid option is chosen" do
      post :submit, params: { hotel_rooms: "<script></script>" }

      expect(response).to render_template(current_template)
    end
  end
end
