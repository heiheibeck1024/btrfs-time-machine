module TimeMachine
  class Rsync
    def initialize(source,config)
      @source = source["source"]
      @exclusions = source["exclusions"]
      @snapshot = !!source["snapshot"]
      @destination = File.expand_path(
        File.join(config["backup_mount_point"], "/latest", @source)
      )
    end

    def options
      default_options = %w[
        -v
        -aAX
        --numeric-ids
        --delete
        --delete-excluded
        --human-readable
        --inplace
        --no-whole-file
      ]

      options = default_options

      options
    end

    def rsync
      # XXX Consider an explicit enum, with btrfs, lvm and dm-thin snapshots.

      if @snapshot
        src2 = "#{@source}/ro-snapshot"
        if File.exist? src2
          alert_and_abort "read-only source snapshot already exists at #{src2}"
        end

        `sudo btrfs subvolume snapshot -r #{@source} #{src2}`
        alert_and_abort "Failed to snapshot `#{@source}'" unless $?.success?
      else
        src2 = @source
      end
      rsync = command_path('rsync')
      rsync_opts = '-v -aAX --numeric-ids --delete --delete-excluded --human-readable --inplace --no-whole-file'

      unless @rsync_options.nil?
        rsync_opts += ' ' + @rsync_options.join(' ')
      end

      unless src_data['rsync_options'].nil?
        rsync_opts += ' ' + src_data['rsync_options'].join(' ')
      end

      if src_data.fetch('snapshot', false) or src_data.fetch('one-filesystem', false)
        rsync_opts += ' -x'
      end

      if src_data.key? 'exclusions' then
        src_data['exclusions'].each do |exclusion|
          exclusion.gsub!(/^\.\//, '')                  # drop off the ./ because rsync doesn't like em.
          rsync_opts += " --exclude '#{exclusion}'"
        end
      end

      alert_and_abort "rsync says: I need a source and destination" unless @source && @destination
      alert_and_abort "Could not create #{@destination} directory" unless FileUtils.mkdir_p @destination
    def exclusions
      # drop off the ./ because rsync doesn't like em.
      return @exclusions.map!{|exclusion| exclusion.gsub(/^\.\//, '')}
    end

      # start the backup
      log "Starting the backup:"
      rsync_cmd="sudo #{rsync} #{rsync_opts} #{src2}/ #{@destination} >> #{@log_file} 2>&1" # src needs a trailing slash on dir or it'll go in wrong dir.
      log "Running '#{rsync_cmd}'"
      `#{rsync_cmd}` 
      rsync_failed = ! $?.success?
      if @snapshot and @source != src2
        `sudo btrfs subvolume delete #{src2}`
        alert "Failed to clean up `#{src2}'" unless $?.success?
      end
      alert_and_abort "Failed to backup `#{@source}'" if rsync_failed
    end



  end
end
