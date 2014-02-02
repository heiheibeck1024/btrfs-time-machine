require 'yaml'

module TimeMachine
  class Config
    def initialize config
      raise "Config file '#{config}' not found" unless File.exist?(config)
      @config = YAML.load_file(config)
    end

    def to_hash
      @config
    end
  end
end
