require 'autometrics'
require 'yaml/store'

module Database
  # A simple database client that stores and retrieves data from a local YAML file.
  class Client
    include Autometrics

    autometrics only: [:save_vote, :get_votes]

    def initialize
      @store = YAML::Store.new 'votes.yml'
    end

    def save_vote(vote)
      @store.transaction do
        @store['votes'] ||= {}
        @store['votes'][vote] ||= 0
        @store['votes'][vote] += 1
      end
    end

    def get_votes
      @store.transaction { @store['votes'] } || {}
    end
  end
end
