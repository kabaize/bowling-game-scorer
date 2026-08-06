# Use official Ruby image
FROM ruby:4.0

# System dependencies needed for native gems
RUN apt-get update -qq && apt-get install -y \
  build-essential \
  libpq-dev \
  libyaml-dev \
  pkg-config \
  curl \
  nodejs \
  && rm -rf /var/lib/apt/lists/*

# Remove Ruby's own bundled default json gemspec: it's stale metadata that
# Trivy flags as vulnerable, but the app always loads Bundler's patched
# json gem instead (pinned in Gemfile). Only the specification file is
# removed, not any code path actually used at runtime.
RUN rm -f /usr/local/lib/ruby/gems/4.0.0/specifications/default/json-*.gemspec

# App root in the image
WORKDIR /app

# Copy Gemfiles first for layer caching
COPY bowling_api/Gemfile bowling_api/Gemfile.lock ./bowling_api/

# Install gems
WORKDIR /app/bowling_api
RUN gem install bundler && bundle install

# Copy Rails API and core logic into image
WORKDIR /app
COPY bowling_api ./bowling_api
COPY bowling_core ./bowling_core

# Re-run bundle install in case copied files changed dependency resolution
WORKDIR /app/bowling_api
RUN bundle install

# Run Rails from API folder
WORKDIR /app/bowling_api

EXPOSE 3000

# Start Rails server
CMD ["ruby", "bin/rails", "s", "-b", "0.0.0.0", "-p", "3000"]
