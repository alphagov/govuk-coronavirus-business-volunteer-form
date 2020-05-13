# frozen_string_literal: true

require "spec_helper"

RSpec.describe CoronavirusForm::RoomsNumberController, type: :controller do
  include_examples "session expiry"

  let(:current_template) { "coronavirus_form/rooms_number" }

  describe "GET show" do
    it "renders the form when first question answered" do
      session["medical_equipment"] = I18n.t("coronavirus_form.questions.medical_equipment.options.option_yes.label")
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
    let(:cost) do
      I18n.t("coronavirus_form.questions.how_much_charge.options").map { |_, item| item[:label] }.sample
    end

    it "sets session variables" do
      post :submit,
           params: {
             rooms_number: selected,
             accommodation_cost: cost,
           }
      expect(session[:rooms_number]).to eq selected
      expect(session[:accommodation_cost]).to eq cost
    end

    it "redirects to check your answers if check your answers previously seen" do
      session[:check_answers_seen] = true
      post :submit,
           params: {
             rooms_number: selected,
             accommodation_cost: cost,
           }

      expect(response).to redirect_to(check_your_answers_path)
    end

    it "validates a rooms_number value is entered" do
      post :submit,
           params: {
             rooms_number: "",
             accommodation_cost: cost,
           }

      expect(response).to have_http_status(:unprocessable_entity)
      expect(response).to render_template(current_template)
    end

    it "validates an accommodation cost option is chosen" do
      post :submit,
           params: {
             rooms_number: selected,
           }

      expect(response).to have_http_status(:unprocessable_entity)
      expect(response).to render_template(current_template)
    end
  end
end
