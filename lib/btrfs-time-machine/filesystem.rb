module TimeMachine
  class FileSystem
    def initialize device,mount_point
      `btrfs device scan`
      @device = device
      @mount_point = mount_point
    end

    def mount_options path=""
      File.open('/proc/mounts', 'r').each_line do |line|
        details = line.split(" ")
        next unless "#{details[1]}/" == full_path(path)
        return details[3].split(",")
      end
      nil
    end

    def mounted? path=""
      !mount_options(path).nil?
    end

    def mount
      puts mounted?.inspect
      unless mounted? then
        `mount #{@device} #{@mount_point}`
        $?.success?
      end
    end

    def umount
      return nil unless mounted?
      `umount #{@mount_point}`
      $?.success?
    end

    def btrfs_volume?
      return false unless File.directory? @mount_point
      return nil unless mounted?
      return true if File.stat(@mount_point).ino == 256
      false
    end

    def btrfs_subvolume? path
      return false unless btrfs_volume?
      btrfs_subvolumes.include? path
    end

    def btrfs_subvolume_create path
      return false unless btrfs_volume?
      return true if btrfs_subvolume?(path)
      `btrfs subvolume create #{full_path(path)}`
      $?.success?
    end

    def btrfs_subvolume_delete path
      return false unless btrfs_subvolume?(path)
      `btrfs subvolume delete #{full_path(path)}`
      $?.success?
    end

    def btrfs_subvolumes
      return false unless btrfs_volume?
      `btrfs subvolume list #{@mount_point} | awk '{ print $7 }'`.split
    end

    def btrfs_snapshot_create src, dst, options={:read_only=>false}
      return false unless btrfs_subvolume? src
      return false if btrfs_subvolume? dst

      `btrfs subvolume snapshot \
        #{"-r" if options[:read_only]} \
        #{full_path src} #{full_path dst}
      `
      $?.success?
    end

    def read_only? path=""
      return nil unless mounted?(path)
      mount_options(path).include? "ro"
    end

    def remount(options) path=""
      return false unless mounted?
      return false unless options.is_a? Array

      options.push("remount")
      `mount -o #{options.join(",")} #{@device} #{full_path(path)}`
      $?.success?
    end

    private
    def full_path path
      File.join(@mount_point, path)
    end
  end

end
