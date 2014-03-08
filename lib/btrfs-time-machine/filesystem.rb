# TODO: use Mixlib::ShellOut everywhere.
# TODO: log errors

require 'fileutils'

module TimeMachine
  class FileSystem
    include Command

    def initialize device,mount_point
      `btrfs device scan`
      # TODO: if device == uuid, convert it to a device.
      #@device = `blkid | grep '#{cfg['dest_device_uuid']}'`.split(':').first
      @device = device
      @mount_point = mount_point
    end

    def mount_options path=""
      File.open('/proc/mounts', 'r').each_line do |line|
        details = line.split(" ")
        next unless "#{details[1]}/" == full_path(path)
        return details[3].split(",")
      end
      []
    end

    def mounted? path=""
      return true if btrfs_subvolume?(path)

      File.open('/proc/mounts', 'r').each_line do |line|
        return true if "#{line.split(" ")[1]}/" == full_path(path)
      end

      false
    end

    def mount
      unless mounted?
        execute(
          {
            :cmd => "mount #{@device} #{@mount_point}",
            :success => { 
              :msg => "mounted #{@mount_point}",
              :level => "info"
            },
            :failure => {
              :msg => "message",
              :level => "info"
            }
          }
        )
        LOG.debug "mounting #{@device} to #{@mount_point}"
        cmd = Mixlib::ShellOut.new("mount #{@device} #{@mount_point}").run_command
        if cmd.exitstatus.zero?
          LOG.info("mounted #{@mount_point}")
          return true
        else
          LOG.error("failed to umount #{@mount_point}")
          return false
        end
      end

      LOG.debug "cannot mount because #{@device} is already mounted."
    end

    def umount
      if mounted?
        cmd = Mixlib::ShellOut.new("umount #{@device}").run_command
        if cmd.exitstatus.zero?
          LOG.info("umounted #{@mount_point}")
          return true
        else
          LOG.error("failed to umount #{@mount_point}")
          return false
        end
      end

      LOG.debug "cannot umount because #{@device} is not mounted."
      nil
    end

    def btrfs_volume?
      return false unless File.directory? @mount_point
      return nil unless mounted?
      return true if File.stat(@mount_point).ino == 256
      false
    end

    def btrfs_subvolume? path
      btrfs_subvolumes.include? path
    end

    def btrfs_subvolume_create path
      path = full_path(path)

      unless btrfs_volume?
        LOG.error "cannot create btrfs subvolume at #{path} because it is not a btrfs subvolume."
        return false
      end

      if btrfs_subvolume?(path)
        LOG.error "cannot create btrfs subvolume at #{path} because it already exists."
        return false
      end

      LOG.info "creating btrfs subvolume at #{full_path(path)}"
      cmd = Mixlib::ShellOut.new("btrfs subvolume create #{path}").run_command
      cmd.exitstatus.zero?
    end

    def btrfs_subvolume_delete path
      unless btrfs_subvolume?(path)
        LOG.error "cannot delete btrfs subvolume at #{path} because it does not exist."
        return false
      end

      path = full_path(path)
      cmd = Mixlib::ShellOut.new("btrfs subvolume delete #{path}").run_command
      cmd.exitstatus.zero?
    end

    def btrfs_subvolumes
      cmd = Mixlib::ShellOut.new("btrfs subvolume list #{@mount_point}").run_command
      cmd.stdout.each_line.map{|l| l.split(" ").last}
    end

    def btrfs_snapshot_create src, dst, options={:read_only=>false}
      # TODO: destination should always be the date.
      unless btrfs_subvolume? src
        LOG.error "cannot create snapshot of #{src} because it's not a btrfs subvolume"
      end

      src = full_path(src)
      dst = full_path(dst)
      LOG.info "creating snapshot of #{src} at #{dst}."

      cmd = Mixlib::ShellOut.new(
        "btrfs subvolume snapshot \
          #{"-r" if options[:read_only]} \
          #{full_path src} #{full_path dst}
        "
      ).run_command
      cmd.exitstatus.zero?
    end

    alias_method :btrfs_snapshot_delete, :btrfs_subvolume_delete

    def btrfs_snapshots source
      # TODO: return list of snapshots of a source.
      nil
    end

    def btrfs_snapshot_date
      # TODO: return a DateTime object from the snapshot name.
      nil
    end

    def read_only? path=""
      return nil unless mounted?(path)

      if btrfs_subvolume?(path)
        !!FileUtils.touch(full_path(path))
      end

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
