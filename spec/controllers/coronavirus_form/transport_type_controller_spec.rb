# frozen_string_literal: true

require "spec_helper"

RSpec.describe CoronavirusForm::TransportTypeController, type: :controller do
  let(:current_template) { "coronavirus_form/transport_type" }
  let(:session_key) { :transport_type }

  describe "GET show" do
    it "renders the form" do
      get :show
      expect(response).to render_template(current_template)
    end
  end

  describe "POST submit" do
    let(:options) do
      I18n.t("coronavirus_form.transport_type.options").map { |_, item| item[:label] }
    end
    let(:selected) { [options, [options.sample]].sample }

    it "sets session variables" do
      post :submit, params: { transport_type: selected }

      expect(session[session_key]).to eq selected
    end

    it "redirects to next step" do
      post :submit, params: { transport_type: selected }

      expect(response).to redirect_to(coronavirus_form_offer_space_path)
    end

    it "redirects to check your answers if check your answers previously seen" do
      session[:check_answers_seen] = true
      puts "selected"
      puts selected
      post :submit, params: { transport_type: selected }

      expect(response).to redirect_to("/coronavirus-form/check-your-answers")
    end

    it "validates any option is chosen" do
      post :submit, params: { transport_type: [] }

      expect(response).to render_template(current_template)
    end

    it "validates a valid option is chosen" do
      post :submit, params: { transport_type: ["<script></script", "invalid option", "Medical equipment"] }

      expect(response).to render_template(current_template)
    end
  end
end
