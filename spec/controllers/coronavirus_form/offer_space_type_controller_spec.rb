# frozen_string_literal: true

require "spec_helper"

RSpec.describe CoronavirusForm::OfferSpaceTypeController, type: :controller do
  include_examples "session expiry"

  let(:current_template) { "coronavirus_form/offer_space_type" }
  let(:session_key) { :offer_space_type }

  describe "GET show" do
    it "renders the form when first question answered" do
      session["accommodation"] = I18n.t("coronavirus_form.questions.accommodation.options.option_yes.label")

      get :show
      expect(response).to render_template(current_template)
    end

    it "redirects to first question when first question not answered" do
      get :show
      expect(response).to redirect_to(accommodation_path)
    end
  end

  describe "POST submit" do
    let(:selected) do
      [
        I18n.t("coronavirus_form.questions.offer_space_type.options.warehouse_space.label"),
        I18n.t("coronavirus_form.questions.offer_space_type.options.office_space.label"),
      ]
    end

    let(:params) do
      {
        offer_space_type: [
          I18n.t("coronavirus_form.questions.offer_space_type.options.warehouse_space.label"),
          I18n.t("coronavirus_form.questions.offer_space_type.options.office_space.label"),
          I18n.t("coronavirus_form.questions.offer_space_type.options.other.label"),
        ],
        warehouse_space_description: "200msq",
        offer_space_type_other: "500sqm",
        office_space_description: "400msq",
        general_space_description: "I have extra space of 1000msq",
        space_cost: I18n.t("coronavirus_form.how_much_charge.options").map { |_, item| item[:label] }.sample,
      }
    end

    it "sets session variables" do
      post :submit, params: params

      expect(session.to_h).to eq params.deep_stringify_keys
    end

    it "redirects to next step" do
      post :submit, params: params

      expect(response).to redirect_to(offer_staff_path)
    end

    it "redirects to check your answers if check your answers already seen" do
      session[:check_answers_seen] = true
      post :submit, params: params

      expect(response).to redirect_to("/check-your-answers")
    end

    context "when Other option is selected" do
      it "validates the Other option description is provided" do
        post :submit,
             params: { offer_space_type: [
               I18n.t("coronavirus_form.questions.offer_space_type.options.other.label"),
               I18n.t("coronavirus_form.questions.offer_space_type.options.office_space.label"),
             ] }

        expect(response).to have_http_status(:unprocessable_entity)
        expect(response).to render_template(current_template)
      end

      it "adds the other option description to the session" do
        post :submit,
             params: params.merge(
               offer_space_type: [
                 I18n.t("coronavirus_form.questions.offer_space_type.options.other.label"),
                 I18n.t("coronavirus_form.questions.offer_space_type.options.office_space.label"),
               ],
               offer_space_type_other: "A really big garden.",
             )

        expect(response).to redirect_to(offer_staff_path)
        expect(session[session_key]).to eq [
          I18n.t("coronavirus_form.questions.offer_space_type.options.other.label"),
          I18n.t("coronavirus_form.questions.offer_space_type.options.office_space.label"),
        ]
        expect(session[:offer_space_type_other]).to eq "A really big garden."
      end
    end

    described_class::OPTIONS.each do |(option_id, option)|
      context "when the option #{option_id} is selected" do
        description_id = option.dig(:description, :id).to_sym

        context "when the option #{option_id} is not provided" do
          let(:acceptable_params) do
            params.merge(
              offer_space_type: params[:offer_space_type].reject do |type|
                type == option.dig(:label)
              end,
            ).except(description_id)
          end
          it "doesn't require the description field #{description_id}" do
            post :submit, params: acceptable_params
            expect(response).to redirect_to(offer_staff_path)
          end
        end

        context "when the corresponding description field #{description_id} is not provided" do
          it "won't accept the input" do
            post :submit, params: params.except(description_id)
            expect(response).to have_http_status(:unprocessable_entity)
            expect(response).to render_template(current_template)
          end
        end
      end
    end

    it "validates any space type option is chosen" do
      post :submit, params: { offer_space: "" }

      expect(response).to have_http_status(:unprocessable_entity)
      expect(response).to render_template(current_template)
    end

    it "validates a valid space type option is chosen" do
      post :submit, params: { offer_space: "<script></script>" }

      expect(response).to have_http_status(:unprocessable_entity)
      expect(response).to render_template(current_template)
    end

    it "validates a space cost option is chosen" do
      post :submit, params: params.except(:space_cost)

      expect(response).to have_http_status(:unprocessable_entity)
      expect(response).to render_template(current_template)
    end

    it "redirects to check your answers if check your answers previously seen" do
      session[:check_answers_seen] = true
      post :submit, params: params

      expect(response).to redirect_to(check_your_answers_path)
    end

    (described_class::TEXT_FIELDS + described_class::DESCRIPTION_FIELDS).each do |field|
      it "validates that #{field} is 1000 or fewer characters" do
        params[field] = SecureRandom.hex(1001)
        post :submit, params: params

        expect(response).to have_http_status(:unprocessable_entity)
        expect(response).to render_template(current_template)
      end
    end
  end
end
