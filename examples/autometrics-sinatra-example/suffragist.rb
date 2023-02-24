require 'sinatra'
require 'prometheus/middleware/exporter'

require_relative 'db'

# NOTE - This creates a `/metrics` endpoint on the app that can be scraped by Prometheus
use Prometheus::Middleware::Exporter

# POST To vote for a pizza topping with query parameter `?vote=<topping>`
post '/cast' do
  @vote  = params['vote']
  @db = Database::Client.new
  @db.save_vote(@vote)

  content_type :json
  status 201
  { vote: @vote }.to_json
end

# GET results of all votes, result should be a hash of strings to integers
get '/results' do
  @db = Database::Client.new
  @votes = @db.get_votes

  content_type :json
  @votes.to_json
end