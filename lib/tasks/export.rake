namespace :export do
  desc "Exports all form responses for a specific date in JSON format"
  task :form_responses, [:date] => [:environment] do |_, args|
    responses = FormResponse.where(created_at: Date.parse(args.date).all_day)
    puts responses.to_json
  end
end
