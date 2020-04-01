require "aws-sdk-s3"

namespace :export do
  desc "Exports all form responses for a specific date in JSON format"
  task :form_responses, [:date] => [:environment] do |_, args|
    args.with_defaults(date: Date.yesterday.to_s)

    responses = FormResponse.where(created_at: Date.parse(args.date).all_day)
    puts responses.to_json
  end

  desc "Uploads all form responses since a specific date (e.g. \"2015-03-24\") in JSON format to a S3 bucket"
  task :form_responses_s3, [:date] => [:environment] do |_, args|
    args.with_defaults(date: Date.yesterday.to_s)

    start_time = Date.parse(args.date).beginning_of_day
    end_time = Time.current
    puts "finding responses between #{start_time} and #{end_time}"

    responses = FormResponse.where(created_at: start_time..end_time)
    puts "found #{responses.count} responses"

    credentials = JSON.parse(ENV["VCAP_SERVICES"]).to_h.dig("aws-s3-bucket", 0, "credentials")

    s3 = Aws::S3::Client.new(
      region: credentials["aws_region"],
      access_key_id: credentials["aws_access_key_id"],
      secret_access_key: credentials["aws_secret_access_key"],
    )

    filename = "#{args.date}_to_#{end_time.strftime('%Y-%m-%d')}.json"
    s3.put_object(
      bucket: credentials["bucket_name"],
      key: filename,
      body: responses.to_json,
    )
    puts "Uploaded responses #{filename} to #{credentials['bucket_name']}"
  end
end
