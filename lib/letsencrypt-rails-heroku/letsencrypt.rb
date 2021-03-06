module Letsencrypt
  class << self
    attr_accessor :configuration
  end

  def self.configure
    self.configuration ||= Configuration.new
    yield(configuration) if block_given?
  end

  def self.challenge_configured?(acme_challenge_filename)
    return false unless configuration.acme_challenges.is_a?(Hash)
    configuration.acme_challenges.key?(acme_challenge_filename)
  end

  class Configuration
    attr_accessor :heroku_token, :heroku_app, :acme_email, :acme_domain,
      :acme_endpoint, :ssl_type

    # Not settable by user; part of the gem's behaviour.
    attr_reader :acme_challenges

    def initialize
      @heroku_token = ENV["HEROKU_TOKEN"]
      @heroku_app = ENV["HEROKU_APP"]
      @acme_email = ENV["ACME_EMAIL"]
      @acme_domain = ENV["ACME_DOMAIN"]
      @acme_endpoint = ENV["ACME_ENDPOINT"] || 'https://acme-v01.api.letsencrypt.org/'
      @ssl_type = ENV["SSL_TYPE"] || 'sni'
      @acme_challenges = begin
          JSON.parse(ENV["ACME_CHALLENGES"]) if ENV["ACME_CHALLENGES"]
        rescue JSON::ParserError
          nil
        end
    end

    def valid?
      heroku_token && heroku_app && acme_email
    end
  end
end
