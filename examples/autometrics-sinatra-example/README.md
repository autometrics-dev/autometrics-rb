# Autometrics Sinatra Example

This project contains a simple Sinatra app that can be used to test the Autometrics library.

Here, we're using autometrics in the `db.rb` module, in order to generate metrics for our database calls.

## App Overview

> Example code adatped from https://guides.railsgirls.com/sinatra-app

The app itself is a JSON api that can record vote tallies. To make things concrete, we'll say we're voting on pizza toppings.

There is a `POST /cast` endpoint that accepts a `vote` parameter. The value of the `vote` parameter is the name of a pizza topping. The endpoint will increment the vote count for that topping.

There is a `GET /results` endpoint that returns a JSON object with the current vote tallies.

There is a simple database module in `db.rb` that provides methods for storing votes and retrieving vote tallies. The "database" is really just a local yaml file.

In this example, we generate metrics for our "database" calls, and expose the metrics to prometheus on the `/metrics` endpoint, which is set up in `suffragist.rb`. (See the line `use Prometheus::Middleware::Exporter`.)

## Usage

Test the API

```sh
# Install dependencies
bundle install

# Start server
bundle exec ruby suffragist.rb

# Vote for a pizza topping
curl -XPOST "http://localhost:4567/cast?vote=mushroom"

# See votes
curl localhost:4567/results

# View metrics (these would be scraped by prometheus)
curl localhost:4567/metrics
```
