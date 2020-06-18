#========================================================================================
# This Dockerfile creates a container image which contains Ruby,
# Google Chrome, Redis and Postgres, as well as the application source and bundled dependencies.
#
# This is needed for running the feature tests in a container environment like Concourse.
#========================================================================================
FROM ruby:2.6.6-buster

# Updates all debian dependencies
# Adds google chrome to software sources, install chrome, install postgres and redis
# clear up lists behind ourselves
RUN apt-get update --fix-missing && apt-get -y upgrade \
    && wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb \
    && apt-get install -y --no-install-recommends \
      ./google-chrome-stable_current_amd64.deb \
      postgresql-11 \
      redis-server \
    && rm ./google-chrome-stable_current_amd64.deb

ENV CHROME_NO_SANDBOX=true

COPY Gemfile* .ruby-version /application/

WORKDIR /application/

RUN bundle install

COPY . /application/

ENTRYPOINT ["/bin/bash"]
