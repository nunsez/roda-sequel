require_relative "environment"

dev = ENV["RACK_ENV"] == "development"

run(dev ? Unreloader : App.freeze.app)
