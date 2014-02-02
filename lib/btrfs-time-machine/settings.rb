require 'yaml'

module TimeMachine
  class Settings
    def initialize settings
      config = settings[:config]
      sources = settings[:sources]

      raise "Config file '#{config}' not found" unless File.exist?(config)
      raise "Config file '#{sources}' not found" unless File.exist?(sources)

      @config = YAML.load_file(config)
      @sources = YAML.load_file(sources)

      @settings = @config
      @settings[:sources] = @sources
    end

    def to_hash
      @settings
    end

    def config
      @config
    end

    def sources
      @sources
    end

  end
end
