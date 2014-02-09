module TimeMachine
  class Rsync
    def initialize(sources,config)
      @rsync_bin = `which rsync`.strip
      @sources = sources
      @config = config

      # TODO:
      # - make sure that source is a directory
      # - make sure that destination is a btrfs directory
      # - raise an error if the rsync bin was not found.
      # - raise an error if destination is unknown

    end

    def run
      @sources.each do |source|
        FileUtils.mkdir_p destination
        cmd = Mixlib::ShellOut(command)
        cmd.run_command
        return false unless cmd.status.to_i.zero?
      end
      true
    end

    def command source
      o = options(source).join(" ")
      d = destination(source)
      s = source

      # rsync wants a trailing slash.
      s += "/" unless !!source.match(/\/$/)
      "#{@rsync_bin} #{o} #{s} #{d}"
    end

    private
    def source_settings source
      @sources.each do |s|
        return s if s["source"] == source
      end
      false
    end

    def options source
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

      settings = source_settings(source)
      options += settings["rsync_options"]

      if settings["snapshot"] || settings["one-filesystem"]
        options += ["--one-file-system"] 
      end

      options += settings["exclusions"].map{|e| "--exclude #{e}"}
      options.uniq
    end

    def destination source
      File.expand_path(
        File.join(@config["backup_mount_point"], "/latest", source)
      )
    end
  end
end
