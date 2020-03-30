require "aws-sdk-s3"

namespace :export do
  desc "Exports all form responses for a specific date in JSON format"
  task :form_responses, [:date] => [:environment] do |_, args|
    args.with_defaults(date: Date.yesterday)

    responses = FormResponse.where(created_at: Date.parse(args.date).all_day)
    puts responses.to_json
  end

  desc "Uploads all form responses for a specific date (e.g. \"2015-03-24\") in JSON format to a S3 bucket"
  task :form_responses_s3, [:date] => [:environment] do |_, args|
    args.with_defaults(date: Date.yesterday)

    responses = FormResponse.where(created_at: Date.parse(args.date).all_day)

    credentials = JSON.parse(ENV["VCAP_SERVICES"]).to_h.dig("aws-s3-bucket", 0, "credentials")

    s3 = Aws::S3::Client.new(
      region: credentials["aws_region"],
      access_key_id: credentials["aws_access_key_id"],
      secret_access_key: credentials["aws_secret_access_key"],
    )

    s3.put_object(
      bucket: credentials["bucket_name"],
      key: "#{args.date}.json",
      body: responses.to_json,
    )
  end
end
