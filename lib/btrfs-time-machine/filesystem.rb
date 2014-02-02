module TimeMachine
  class FileSystem
    def initialize device,mount_point
      `btrfs device scan`
      @device = device
      @mount_point = mount_point
    end

    def mount_options
      File.open('/proc/mounts', 'r').each_line do |line|
        details = line.split(" ")
        next unless details[1] == @mount_point
        return details[3].split(",")
      end
      false
    end

    def mounted?
      !!mount_options
    end

    def mount
      unless mounted? then
        `mount #{@device} #{@mount_point}`
        $?.success?
      end
    end

    def umount
      return true unless mounted?
      `umount #{@mount_point}`
      $?.success?
    end

    def btrfs_volume?
      return false unless File.directory? @mount_point
      return nil unless mounted?
      return true if File.stat(@mount_point).ino == 256
      false
    end

    def btrfs_subvolume_create
    end

    def btrfs_subvolume_delete
    end

    def btrfs_subvolumes
      return false unless btrfs_volume?
      subvolumes = `btrfs_subvolume list #{mount_point} | awk '{ print $7 }'`.split
      subvolumes.map { |dir| File.join(mount_point, dir) }
    end

    def btrfs_take_snapshot(destination,options={:read_only=>false})
      `btrfs subvolume snapshot \
        #{"-r" if options[:read_only]} \
        #{@device} #{destination}
      `
      $?.success?
    end

    def read_only?
      return nil unless mounted?
      mount_options.include? "ro"
    end

    def remount(options)
      return false unless mounted?
      return false unless options.is_a? Array

      options.push("remount")
      `mount -o #{options.join(",")} #{@device} #{@mount_point}`
      $?.success?
    end
  end
end
