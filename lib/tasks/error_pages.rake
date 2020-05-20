namespace :error_pages do
  desc "upload public static error pages to S3 bucket"
  task upload: :environment do
    client = Aws::S3::Client.new(
      region: ENV["AWS_REGION"],
      access_key_id: ENV["AWS_ACCESS_KEY_ID"],
      secret_access_key: ENV["AWS_SECRET_ACCESS_KEY"],
    )
    UploadErrorPages.new(
      error_pages: %w[404.html 422.html 500.html],
      s3_client: client,
      bucket_name: ENV["AWS_ERROR_PAGES_BUCKET_NAME"],
    ).upload
  end
end

if Rake::Task.task_defined?("assets:precompile")
  Rake::Task["assets:precompile"].enhance do
    # rails 3.1.1 will clear out Rails.application.config if the env vars
    # RAILS_GROUP and RAILS_ENV are not defined. We need to reload the
    # assets environment in this case.
    # Rake::Task["assets:environment"].invoke if Rake::Task.task_defined?("assets:environment")
    Rake::Task["error_pages:upload"].invoke if defined?(UploadErrorPages) && Rails.application.config.upload_error_pages_to_s3
  end
end
