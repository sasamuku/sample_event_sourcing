module Byodb
  def self.url
    host = ENV.fetch("BYODB_HOST", "localhost")
    port = ENV.fetch("BYODB_PORT", "5433")

    "postgres://postgres:password@#{host}:#{port}/postgres"
  end
end
