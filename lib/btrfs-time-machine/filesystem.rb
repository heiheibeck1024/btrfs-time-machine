require 'fileutils'
require 'mixlib/shellout'

module TimeMachine
  class FileSystem
    include Command

    def initialize device,mount_point
      execute({
        :cmd => "btrfs device scan",
        :failure => {:msg => "failed to scan for btrfs devices."},
        :success => {:msg => "scanned for btrfs devices."}
      })

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
      execute(
        {
          :cmd => "mount #{@device} #{@mount_point}",
          :test_cmd => :mounted?,
          :failure => {:msg => "failed to mount #{@device} to #{@mount_point}"},
          :success => {:msg => "mounted #{@mount_point} to #{@mount_point}"}
        }
      )
    end

    def umount
      !execute(
        {
          :cmd => "umount #{@device}",
          :test_cmd => :mounted?,
          :failure => {:msg => "failed to unmount #{@device}"},
          :success => {:msg => "unmounted #{@device}"}
        }
      )
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

      LOG.fatal <<-EOF.gsub(/^\s*/, '').strip unless btrfs_volume?
        cannot create btrfs subvolume at #{path} because it is not a btrfs
        subvolume.
      EOF

      LOG.fatal <<-EOF.gsub(/^\s*/, '').strip if btrfs_subvolume?(path)
        cannot create btrfs subvolume at #{path} because it already exists.
      EOF

      execute(
        {
          :cmd => "btrfs subvolume create #{path}",
          :failure => {:msg => "failed to create btrfs subvolume at #{path}"},
          :success => {:msg => "created btrfs subvolume at #{path}"}
        }
      )
    end

    def btrfs_subvolume_delete path
      path = full_path(path)
      unless btrfs_subvolume? path
        execute(
          {
            :cmd => "btrfs subvolume delete #{path}",
            :failure => {:msg => "failed to delete btrfs subvolume at #{path}"},
            :success => {:msg => "deleted btrfs subvolume at #{path}"}
          }
        )
      end
      !btrfs_subvolume?(path)
    end

    def btrfs_subvolumes
      cmd = Mixlib::ShellOut.new("btrfs subvolume list #{@mount_point}").run_command
      cmd.stdout.each_line.map{|l| l.split(" ").last}
    end

    def btrfs_snapshot_create src, dst, options={:read_only=>false}
      cmd = []
      cmd.push "btrfs subvolume snapshot"
      cmd.push "-r" if options[:read_only]
      cmd.push full_path(src)
      cmd.push full_path(dst)

      execute(
        {
          :cmd => cmd.join(" "),
          :failure => {:msg => "Failed to create snapshot of #{src} at #{dst}."},
          :success => {:msg => "Created snapshot of #{src} at #{dst}."}
        }
      )

      LOG.fatal <<-EOF.gsub(/^\s*/, '').strip unless btrfs_subvolumes.include?(full_path(dst))
        An error occured creating smapshot. This should not happen.
      EOF
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
      return nil unless mounted? path
      return !File.writable?(full_path(path))
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
