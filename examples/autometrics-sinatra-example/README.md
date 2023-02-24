# Autometrics Sinatra Example

> Example code adatped from https://guides.railsgirls.com/sinatra-app

This project contains a simple Sinatra app that can be used to test the Autometrics library.

The app itself is a JSON api that can record vote tallies. To make things concrete, we'll say we're voting on pizza toppings.

There is a `POST /cast` endpoint that accepts a `vote` parameter. The value of the `vote` parameter is the name of a pizza topping. The endpoint will increment the vote count for that topping.

There is a `GET /results` endpoint that returns a JSON object with the current vote tallies.

There is a simple database module in `db.rb` that provides methods for storing votes and retrieving vote tallies.

In this example, we generate metrics for our "database" calls.

We expose the metrics to prometheus on the `/metrics` endpoint, which is set up in `suffragist.rb` with the line `use Prometheus::Middleware::Exporter`.

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

# View metrics
curl localhost:4567/metrics
```
