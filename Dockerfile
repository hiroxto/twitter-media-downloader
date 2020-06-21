FROM ruby:2.7.1-alpine

WORKDIR /app

RUN apk add --no-cache --update tzdata build-base ruby ruby-dev && \
    apk upgrade --no-cache && \
    cp /usr/share/zoneinfo/Asia/Tokyo /etc/localtime && \
    apk del tzdata && \
    rm -rf /var/cache/apk/*

COPY . /app

RUN bundle install --jobs=4 --path=vendor/bundle
