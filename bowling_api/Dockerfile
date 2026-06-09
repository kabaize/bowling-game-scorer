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
