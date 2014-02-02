module TimeMachine
  class Btrfs
    def initialize device,mount_point
      @device = device
      @mount_point = mount_point
    end

    def mounted?
      File.open('/proc/mounts', 'r').each_line do |line|
        return true if line.include? @mount_point
      end
      false
    end

    def mount
      unless mounted? then
        #log "Mounting #{@device} to #{@mount_point}"
        `mount #{@device} #{@mount_point}`
      end
      #alert_and_abort "Could not mount #{@device} to #{@backup_mount_point}" unless $?.success?
      #$?.success?
    end

    def umount
      return true unless mounted?

      #log "Mounting #{@device} to #{@mount_point}"
      `umount #{@mount_point}`
      $?.success?

      #alert_and_abort "Could not mount #{@device} to #{@backup_mount_point}" unless $?.success?
    end

    #def remount_as(option,device,mount_point)
    #  alert_and_abort "I don't have a mount option, device and mount point." unless option && device && mount_point
    #  alert_and_abort "Cannot remount because #{mount_point} is not mounted" unless is_mounted?(device,mount_point)
    #  log "Remounting #{mount_point} as #{option}"

    #  mount_opts = ['remount']
    #  mount_opts.push(@mount_options) unless @mount_options.nil?
    #  mount_opt_str = mount_opts.join(',')

    #  `sudo mount -o #{mount_opt_str},#{option} #{device} #{mount_point}`
    #  alert_and_abort "mount #{device} as #{option} failed" unless $?.success?
    #  $?.success?
    #end


    #def btrfs_scan()
    #  `sudo btrfs device scan >> #{@log_file} 2>&1`
    #end

    #def btrfs_volume?(path)
    #  unless File.directory? path
    #    return false
    #  end

    #  return true if File.stat(path).ino == 256
    #  false
    #end

    #def btrfs_snapshot
    #  date = Time.now.strftime("%Y-%m-%d %H:%M:%S")
    #  FileUtils.mkdir_p @snapshot_dir

    #  log "Creating file system snapshot."
    #  alert_and_abort "A snapshot by that name already exists" if File.directory?("#{@snapshot_dir}/#{date}")
    #  `sudo btrfs subvolume snapshot -r #{@backup_mount_point}/latest '#{@snapshot_dir}/#{date}' >> #{@log_file} 2>&1`        # TODO: make logging better
    #  $?.success?
    #end

    #def btrfs_delete_snapshot(date)
    #  log "deleting snapshot from #{date}"
    #  `sudo btrfs subvolume delete '#{@snapshot_dir}/#{date}' >> #{@log_file} 2>&1`
    #end

    #def btrfs_snapshot_rotate
    #  snapshots = Dir.entries(@snapshot_dir)
    #  snapshots.delete ".."
    #  snapshots.delete "."

    #  snapshots.each do |snapshot|
    #    btrfs_delete_snapshot snapshot if Time.parse(snapshot) < Time.now - (@snapshot_max_age * 3600)
    #  end
    #end
  end
end
