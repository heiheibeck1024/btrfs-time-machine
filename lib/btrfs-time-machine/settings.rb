require 'yaml'

module TimeMachine
  class Settings
    def initialize config
      @config = config

      @config["sources"].each do |s|
        # drop the ./ of exclusions because rsync doesn't like em.
        s["exclusions"].map!{|e| e.gsub(/^\.\//, '') } if s.has_key?("exclusions")
      end
    end

    def global_settings
      @config.reject{|k,v| k == "sources"}
    end

    def source_settings source
      s = {}
      @config["sources"].each do |data|
        s = data if data["source"] == source
      end

      global_settings.each do |k,v|
        case v.class.to_s
          when "Hash"
            s[k] ||= {}
          when "Array"
            s[k] ||= []
            s[k] += v
          when "String"
            s[k] ||= v
          when "Fixnum"
            s[k] ||= v
          when "TrueClass"
            s[k] = v unless s.include?(k)
          when "FalseClass"
            s[k] = v unless s.has_key?(k)
        end
      end

      s["destination"] = File.join(s["backup_mount_point"], "/latest", source)
      s
    end

    def to_hash
      @config
    end

    def sources
      @config["sources"].map {|s| s["source"] }
    end

    def rsync_options source
      options = %w[
        --acls
        --archive
        --delete
        --delete-excluded
        --human-readable
        --inplace
        --no-whole-file
        --numeric-ids
        --verbose
        --xattrs
      ]

      options += @config["rsync_options"]

      settings = source_settings(source)
      options += settings["rsync_options"]

      if settings["snapshot"] || settings["one-filesystem"]
        options += ["--one-file-system"] 
      end

      options += settings["exclusions"].map{|e| "--exclude #{e}"}
      options.uniq
    end

  end
end
