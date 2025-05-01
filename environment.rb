Dir.chdir(__dir__)

begin
  require_relative ".env"
rescue LoadError
end

require "rack/unreloader"
require "roda"
require "sequel/core"
require "sequel/model"

dev = ENV["RACK_ENV"] == "development"
test = ENV["RACK_ENV"] == "test"

DB = Sequel.connect(ENV.fetch("DATABASE_URL"))

if dev || test
  require "logger"
  logger = Logger.new($stdout)
  logger.level = Logger::FATAL if test
  DB.loggers << logger
else
  # Delete DATABASE_URL from the environment, so it isn't accidently
  # passed to subprocesses. DATABASE_URL may contain passwords.
  ENV.delete("DATABASE_URL")
end

LOGGER = logger

Unreloader = Rack::Unreloader.new(
  subclasses: %w[Roda Sequel::Model],
  logger:,
  reload: dev,
  autoload: dev || test,
  handle_reload_errors: dev
) { App }

Unreloader.require("./app.rb") { "App" }

models_root = File.join(__dir__, "models")
Unreloader.autoload(models_root) do |f, x|
  model = Pathname.new(f).relative_path_from(models_root).sub_ext("")
  Sequel::Model.__send__(:camelize, model)
end
