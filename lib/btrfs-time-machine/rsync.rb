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

      ## TODO: fix this
      ## if source is a directory make sure it's got a trailing slash
      #if !File.directory?(s["source"]) && File.exist?(s["source"]) && !!s["source"].match(/\/$/)
      #  s["source"] = s["source"] + "/" 
      #end

      # rsync wants a trailing slash.
      "#{@rsync_bin} #{o} #{s} #{d}"
    end

    private
  end
end
