# frozen_string_literal: true

require "spec_helper"

RSpec.describe BusinessVolunteering::ThankYouController, type: :controller do
  let(:current_template) { "business_volunteering/thank_you" }

  describe "GET show" do
    it "renders the form" do
      get :show
      expect(response).to render_template(current_template)
    end
  end
end
