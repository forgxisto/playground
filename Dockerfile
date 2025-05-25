# https://hub.docker.com/r/library/ruby/

ARG RUBY_VERSION=3.4.2

FROM ruby:$RUBY_VERSION-slim AS base

WORKDIR /app

# Configure bundler and environment
ENV LANG=C.UTF-8 \
    BUNDLE_JOBS=4 \
    BUNDLE_RETRY=3 \
    BUNDLE_PATH=/app/vendor/bundle

# Common dependencies
RUN apt-get update -qq \
    && apt-get install -y --no-install-recommends \
    default-mysql-client-core \
    tzdata \
    locales \
    && rm -rf /var/lib/apt/lists/* \
    && truncate -s 0 /var/log/*log \
    && update-locale LANG=C.UTF-8 LC_ALL=C.UTF-8

# Upgrade RubyGems and install the latest Bundler version
RUN gem update --system \
    && gem install --no-document bundler \
    && gem cleanup all

CMD ["/bin/bash"]

# ================================================= For development
FROM base AS development

# Set development environment
RUN apt-get update -qq \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    build-essential \
    curl \
    unzip \
    git \
    libyaml-dev \
    libsqlite3-dev \
    default-mysql-client \
    locales \
    vim \
    && rm -rf /var/lib/apt/lists/* \
    && truncate -s 0 /var/log/*log

# Copy source
COPY . .
