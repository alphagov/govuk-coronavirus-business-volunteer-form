module FormFlowHelper
  FIRST_QUESTION = "medical_equipment".freeze

  def check_first_question_answered
    redirect_to controller: "coronavirus_form/#{FIRST_QUESTION}", action: "show" unless first_question_answered?
  end

private

  def first_question_answered?
    session[FIRST_QUESTION].present?
  end
end
