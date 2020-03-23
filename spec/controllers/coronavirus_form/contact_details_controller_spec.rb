# frozen_string_literal: true

require "spec_helper"

RSpec.describe CoronavirusForm::ContactDetailsController, type: :controller do
  let(:current_template) { "coronavirus_form/contact_details" }
  let(:session_key) { :contact_details }

  describe "GET show" do
    it "renders the form" do
      get :show
      expect(response).to render_template(current_template)
    end
  end

  describe "POST submit" do
    let(:params) do
      {
        "name" => "John<script></script>",
        "role" => "<script></script>CEO",
        "phone_number" => "0118 999 881 999 119 7253",
        "email" => "john@example.org",
      }
    end
    let(:contact_details) do
      {
        "name" => "John",
        "role" => "CEO",
        "phone_number" => "0118 999 881 999 119 7253",
        "email" => "john@example.org",
      }
    end

    it "sets session variables" do
      post :submit, params: params

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

    it "validates email address is valid" do
      post :submit, params: params.merge("email" => "blah blah not an email")

      expect(response).to render_template(current_template)
    end
  end
end
