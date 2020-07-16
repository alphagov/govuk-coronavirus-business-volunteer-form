module CheckAnswersHelper
  def sections_scope
    "coronavirus_form.check_your_answers.sections"
  end

  def charge_text
    I18n.t("coronavirus_form.check_your_answers.charge")
  end
end
