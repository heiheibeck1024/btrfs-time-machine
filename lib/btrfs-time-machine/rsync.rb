module TimeMachine
  class Rsync
    def initialize(settings)
      unless settings.is_a? TimeMachine::Settings
        raise "You must provide a settings object"
      end

      @settings = settings

      # TODO:
      # - make sure that source is a directory
      # - make sure that destination is a btrfs directory
      # - raise an error if the rsync bin was not found.
    end

    def run
      commands.each do |destination,cmd|
        FileUtils.mkdir_p destination
        cmd = Mixlib::ShellOut(command)
        cmd.run_command
        return false unless cmd.status.to_i.zero?
      end
      true
    end

    def commands
      cmds = []

      options.each do |s,o|
        rsync_bin = File.which("rsync")
        raise "rsync could not be found" if rsync_bin.nil?

        d = @settings.source_settings(s)["destination"]

        ## TODO: fix this
        ## if source is a directory make sure it's got a trailing slash
        #if !File.directory?(s["source"]) && File.exist?(s["source"]) && !!s["source"].match(/\/$/)
        #  s["source"] = s["source"] + "/"
        #end

        cmds.push([rsync_bin, o, d].join(" "))
      end
      cmds
    end

    def options sources=@settings.sources
      raise "You must parse an array of sources" unless sources.is_a? Array

      options = {}
      sources.each do |s|
        raise "#{s} is an invalid source." unless valid_source?(s)
        options[s] = rsync_options(s)
        options[s] += rsync_extras(s)
        options[s] += rsync_inclusions(s)
        options[s] += rsync_exclusions(s)
        options[s].uniq!
      end
      options
    end

    private
    def valid_source? source
      @settings.sources.include?(source)
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

      if @settings.source_settings(source).has_key?("rsync_options")
        options += @settings.source_settings(source)["rsync_options"]
      end

      options.uniq
    end

    def rsync_extras source
      settings = @settings.source_settings(source)
      options = []
      options += ["--one-file-system"] unless settings["one-file-system"]
      options += ["--one-file-system"] unless settings["snapshot"]
      options.uniq
    end

    def rsync_exclusions source
      settings = @settings.source_settings(source)
      settings["exclusions"].map{|e| "--exclude #{e}"}
    end

    def rsync_inclusions source
      settings = @settings.source_settings(source)
      settings["inclusions"].map{|e| "--include #{e}"}
    end

  end
end
