# frozen_string_literal: true

require "spec_helper"

RSpec.describe CoronavirusForm::ContactDetailsController, type: :controller do
  let(:current_template) { "coronavirus_form/contact_details" }
  let(:session_key) { :contact_details }

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
    let(:params) do
      {
        "contact_name" => "John<script></script>",
        "role" => "<script></script>CEO",
        "phone_number" => "0118 999 881 999 119 7253",
        "email" => "john@example.org",
      }
    end
    let(:contact_details) do
      {
        "contact_name" => "John",
        "role" => "CEO",
        "phone_number" => "0118 999 881 999 119 7253",
        "email" => "john@example.org",
      }
    end

    it "sets session variables" do
      post :submit, params: params

      expect(session[session_key]).to eq contact_details
    end

    it "strips html characters" do
      nasty_params = {
        "contact_name" => "<h1 class='big'><p>John</p></h1><script></script>",
        "role" => "<script></script>CEO",
        "phone_number" => "<img src='x' onerror=alert(124)>0118 999 881 999 119 7253",
        "email" => "john@example.org",
      }

      post :submit, params: nasty_params
      expect(session[session_key]).to eq contact_details
    end

    it "redirects to next step when all required fields are provided" do
      post :submit, params: params

      expect(response).to redirect_to(check_your_answers_path)
    end

    it "does not require role" do
      post :submit, params: params.except("role")

      expect(session[session_key]).to eq contact_details.merge("role" => nil)
      expect(response).to redirect_to(check_your_answers_path)
    end

    described_class::REQUIRED_FIELDS.each do |field|
      it "requires that key #{field} be provided" do
        post :submit, params: params.except(field)

        expect(response).to render_template(current_template)
      end
    end

    described_class::TEXT_FIELDS.each do |field|
      it "validates that #{field} is 1000 or fewer characters" do
        params[field] = SecureRandom.hex(1001)
        post :submit, params: params

        expect(response).to render_template(current_template)
      end
    end

    it "validates email address is valid" do
      post :submit, params: params.merge("email" => "blah blah not an email")

      expect(response).to render_template(current_template)
    end
  end
end
