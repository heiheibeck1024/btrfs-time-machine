module TimeMachine
  class Rsync
    def initialize(source,config)
      @source = source["source"]
      @exclusions = source["exclusions"]
      @rsync_bin = `which rsync`.strip

      if source.has_key?("rsync_options")
        @rsync_options = source["rsync_options"]
      else
        @rsync_options = []
      end

      @snapshot = !!source["snapshot"]
      @one_filesystem = !!source["one-filesystem"]

      @destination = File.expand_path(
        File.join(config["backup_mount_point"], "/latest", @source)
      )

      # TODO:
      # - make sure that source is a directory
      # - make sure that destination is a btrfs directory
      # - raise an error if the rsync bin was not found.
      # - raise an error if destination is unknown

    end

    def options
      default_options = %w[
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

      options = default_options
      options += @rsync_options
      options += ["--one-file-system"] unless @snapshot || @one_filesystem
      options += exclusions.map{|exclusion| "--exclude #{exclusion}"}
    end

    def run
      src = @source
      src += "/" unless !!@source.match(/\/$/)    # rsync wants a trailing slash.
      FileUtils.mkdir_p @destination
      `#{@rsync_bin} #{options.join(" ")} #{src} #{@destination}`
      $?.success?
    end

    private
    def exclusions
      # drop off the ./ because rsync doesn't like em.
      return @exclusions.map!{|exclusion| exclusion.gsub(/^\.\//, '')}
    end

  end
end
