require 'yaml'

module TimeMachine
  class Settings
    def initialize config
      @config = config

      %w[backup_mount_point].each do |k|
        raise "Your config must include '#{k}'." unless @config.has_key?(k)
      end

      #@config["sources"].each do |s|
      #  # drop the ./ of exclusions because rsync doesn't like em.
      #  s["exclusions"].map!{|e| e.gsub(/^\.\//, '') } if s.has_key?("exclusions")
      #end
    end

    def global_settings
      @config
    end

    def source_settings source
      s = {}
      @config["sources"].each do |data|
        s = data if data["path"] == source
      end

      s["exclusions"] ||= []
      s["inclusions"] ||= []

      global_settings.each do |k,v|
        ignored_global_settings = %w[sources backup_mount_point]
        next if ignored_global_settings.include?(k)

        case v.class.to_s
          when "Hash"
            s[k] ||= {}
            s[k] = v.merge(s[k])
          when "Array"
            s[k] ||= []
            s[k] += v
          when "Fixnum"
            s[k] ||= v
          when "String"
            s[k] ||= v
          when "TrueClass" || "FalseClass"
            s[k] = v unless s.include?(k)
        end
      end
      s["destination"] = destination_directory(source)
      s
    end

    def sources
      return [] unless @config.has_key?("sources")
      @config["sources"].map {|s| s["path"] }
    end

    def add_source source
      %w[path].each do |k|
        raise "Your config must include '#{k}'." unless source.has_key?(k)
      end

      raise "You already have a source at that path" if sources.include?(source["path"])

      @config["sources"] = [] unless @config.has_key?("sources")
      @config["sources"].push source
    end

    private
    def destination_directory(source)
      source = "root" if source == "/"
      File.expand_path(
        File.join(@config["backup_mount_point"], "/latest", source)
      )
    end

  end
end
