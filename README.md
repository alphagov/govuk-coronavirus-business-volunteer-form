![Run tests](https://github.com/alphagov/govuk-coronavirus-business-volunteer-form/workflows/Run%20tests/badge.svg)

# GOV.UK Coronavirus Business Volunteer Form

This is an application for submitting a form.

## Getting started

The instructions will help you to get the application running
locally on your machine.

### Prequisites

You will need Postgres installed in order for bundler to install the `pg` gem (and `libpq-dev` if on Linux).  
You'll need a JavaScript runtime: https://github.com/rails/execjs  
Clone the app and run `bundle` locally.  

### Running Postgres

#### Locally

    brew install postgres
    postgres -D /usr/local/var/postgres

Then set up your local database

    rails db:setup

#### Docker

    docker pull postgres
    docker run -d -e POSTGRES_PASSWORD=password -e POSTGRES_USER=user -e POSTGRES_DB=coronavirus_form_development -p 5432:5432 postgres

Then set up your Docker database

    DATABASE_URL="postgres://user:password@localhost:5432/coronavirus_business_volunteer_form_development" rails db:setup

You'll then need to specify the `DATABASE_URL` environment variable before the below tasks.

### Running Redis

#### Locally

    brew install redis
    brew services start redis

### Running Sidekiq

We're using [Sidekiq][], a redis-backed queue, which plays nicely with ActiveJob
and ActionMailer, to send emails.

In staging and production, we run instances of the application as workers,
to process the email queue.

#### Locally

Sidekiq will start automatically when you run `foreman start`, but you can
also run it alone with `bundle exec sidekiq`.

#### Sending emails locally

You'll need to pass a GOV.UK Notify API key as an environment variable
`NOTIFY_API_KEY`, and change the delivery method in [development.rb][]:

```ruby
config.action_mailer.delivery_method = :notify
```

You'll also need to set a `GOVUK_NOTIFY_TEMPLATE_ID`, which might involve
creating a template in Notify if your Notify service doesn't have one.

The template should have a Message of `((body))` only.

[Sidekiq]: https://github.com/mperham/sidekiq
[development.rb]: config/environments/development.rb

### Running the application (Postgres will need to be running)

    foreman start

### Running the tests

    bundle exec rake

## Deployment pipeline

Every commit to master is deployed to GOV.UK PaaS by
[this concourse pipeline](https://cd.gds-reliability.engineering/teams/govuk-tools/pipelines/govuk-coronavirus-business-volunteer-form),
which is configured in [concourse/pipeline.yml](concourse/pipeline.yml).

The concourse pipeline has credentials for the `govuk-forms-deployer` user in
GOV.UK PaaS. This user has the SpaceDeveloper role, so it can `cf push` the application.

## Exporting data

Data can be exported in JSON format for a single data using a Rake task:

```
rake export:form_responses["2020-03-26"]
```

## How to deploy breaking changes

Details can be found [here](docs/how-to-deploy-breaking-changes.md).
