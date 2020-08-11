# How to bring back the Business volunteers Form

This document is being written ahead of this service being shut down. The [landing page](https://www.gov.uk/coronavirus-support-from-business) is due to be altered so the that users are no longer linked to the service.

In this case, the definition of ‘shutting down’ means that the site is still running, but is inaccessible to users.
The reason being, that we want to be in a position to be able to bring the service back up quickly if there is a resurgence of COVID 19.

## To bring back the service, these are the steps that will need to be taken

### Bring back the production smoke tests into the concourse pipeline

We removed the production smoke tests from our concourse pipeline.
This was because they made real requests to the application in production, so the tests would fail due to the requests being redirected.
To do this, we would need to revert the changes from [this PR](https://github.com/alphagov/govuk-coronavirus-business-volunteer-form/pull/428).

### Scale up the number of PaaS instances
We scaled down the number of PaaS instances from 10 to 2.
We would need to scale back up, which can be done by reverting the changes in this [PR](https://github.com/alphagov/govuk-coronavirus-business-volunteer-form/pull/431).

### Content changes to the landing page

A content designer will need to make changes to the landing page, using the [Publisher](https://github.com/alphagov/publisher) application.

### Remove the redirect from the CDN
We added a redirect to the CDN in order to redirect traffic to the landing page. This will need to be removed. To do this, remove this [Terraform code](https://github.com/alphagov/covid-engineering/pull/578) and apply the changes.
