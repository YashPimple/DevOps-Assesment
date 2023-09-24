FROM ruby:3.1

WORKDIR /app

COPY Gemfile Gemfile.lock ./

RUN apt-get update && apt-get install -y nodejs yarn

RUN gem install bundler
RUN bundle install

COPY . .

RUN rake assets:precompile

EXPOSE 3000

CMD ["rails", "server", "-b", "0.0.0.0"]
