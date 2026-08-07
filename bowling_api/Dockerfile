# Use official Ruby image
FROM ruby:4.0

# System dependencies needed for native gems
RUN apt-get update -qq && apt-get install -y \
  build-essential \
  libyaml-dev \
  pkg-config \
  curl \
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

# Containers never boot their own kernel, and native gem extensions are
# already compiled at this point, so the C toolchain and kernel headers
# it pulled in (linux-libc-dev) have no further purpose at runtime.
# Purging them removes a package Trivy flags against kernel CVEs that
# can't actually apply here (see .github/workflows/cicd.yml history /
# https://github.com/aquasecurity/trivy/discussions/6562). Note: since
# this is a single-stage build, this doesn't shrink the image itself
# (the bytes still exist in the earlier install layer) -- it only
# removes the packages from the final dpkg state that Trivy scans.
#
# imagemagick (and its libheif backend) ships preinstalled in the
# ruby:4.0 base image, not something this Dockerfile asks for. Nothing
# in the app uses it: no has_one_attached/has_many_attached, no
# ActiveStorage migrations, no MiniMagick/ImageProcessing call anywhere
# -- the image_processing gem in the Gemfile is unused Rails boilerplate.
RUN apt-get purge -y build-essential linux-libc-dev imagemagick \
  && apt-get autoremove -y \
  && apt-get clean

# Run Rails from API folder
WORKDIR /app/bowling_api

EXPOSE 3000

# Start Rails server
CMD ["ruby", "bin/rails", "s", "-b", "0.0.0.0", "-p", "3000"]
