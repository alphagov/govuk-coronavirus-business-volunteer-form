module CheckAnswersHelper
  def sections_scope
    "coronavirus_form.check_your_answers.sections"
  end

  def charge_text
    I18n.t("coronavirus_form.check_your_answers.charge")
  end

  def question_items(question)
    if session[question].is_a?(Array)
      [{
        field: I18n.t("coronavirus_form.questions.#{question}.title"),
        value: render("govuk_publishing_components/components/list", {
          visible_counters: true,
          items: session[question],
        }),
      }]
    else
      [{
        field: I18n.t("coronavirus_form.questions.#{question}.title"),
        value: session[question],
      }]
    end
  end

  def sections
    %w[
      accommodation
      transport
      space
      staff
      care
      services
      other_support
      location
      business_details
      contact_details
    ]
  end
end
