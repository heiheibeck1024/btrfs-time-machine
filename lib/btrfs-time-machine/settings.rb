require 'yaml'

module TimeMachine
  class Settings
    def initialize config
      @config = config
    end

    def to_hash
      @config
    end

    def sources
      @config["sources"]
    end

  end
end
