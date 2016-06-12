FROM ruby:2.3.1
RUN apt-get update -qq && apt-get install -y build-essential
RUN mkdir -p /srv/server
WORKDIR /srv/server
ADD . /srv/server
RUN bundle install
EXPOSE 3000
CMD bundle exec rails server
