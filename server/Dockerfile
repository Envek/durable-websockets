FROM ruby:2.3.1
RUN apt-get update -qq && apt-get install -y build-essential
RUN mkdir -p /srv/server
WORKDIR /srv/server
COPY Gemfile /srv/server
COPY Gemfile.lock /srv/server
RUN bundle install
ADD . /srv/server
EXPOSE 3000
CMD bundle exec rails server
