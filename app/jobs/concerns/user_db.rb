module UserDb
  def self.url
    host = ENV.fetch("USER_DB_HOST", "localhost")
    port = ENV.fetch("USER_DB_PORT", "5433")

    "postgres://postgres:password@#{host}:#{port}/postgres"
  end
end
