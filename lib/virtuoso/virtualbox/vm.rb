module Virtuoso
  module VirtualBox
    # VirtualBox VM.
    class VM < API::VM
      def spec
        # Basic settings
        d = domain_spec
        d.name = name
        d.memory = memory

        # Setup the main hard drive. A disk section must always exist and we
        # assume the first disk section is the main one.
        disk = d.devices.find { |d| d.is_a?(Libvirt::Spec::Device::Disk) }
        disk.source = disk_image

        d
      end

      def state
        domain ? domain.state : :new
      end

      def save
        # At this point, assuming the virtuoso settings are correct, we
        # should have a bootable VM spec, so define it and reload the VM
        # information.
        set_domain(connection.domains.define(spec))
      end

      def destroy
        requires_existing_vm
        domain.undefine
        set_domain(nil)
      end

      def start
        requires_existing_vm
        domain.start
      end

      def stop
        requires_existing_vm
        domain.stop
      end

      def reload
        # Load the main disk image path. We assume this is the first "disk"
        # device, though this assumption is probably pretty weak.
        spec = domain.spec
        disk = spec.devices.find { |d| d.is_a?(Libvirt::Spec::Device::Disk) }
        self.disk_image = disk.source

        # Load the basic attributes
        self.name = spec.name
        self.memory = spec.memory
      end

      protected

      def new_spec
        # Setup the basic settings for the VM
        d = Libvirt::Spec::Domain.new
        d.hypervisor = :vbox
        d.vcpu = 1
        d.features = [:acpi, :pae]
        d.clock.offset = :localtime
        d.os.type = :hvm
        d.os.arch = :i386
        d.os.boot = [:cdrom, :hd]

        # Attach a device for the main hard disk.
        disk = Libvirt::Spec::Device.get(:disk).new
        disk.type = :file
        disk.device = :disk
        disk.target_dev = :hda
        disk.target_bus = :ide
        d.devices << disk

        # Attach a basic NAT network interface
        nat = Libvirt::Spec::Device.get(:interface).new
        nat.type = :user
        nat.mac_address = "08:00:27:8f:7a:9f"
        nat.model_type = "82540EM"
        d.devices << nat

        # Attach video information
        video = Libvirt::Spec::Device.get(:video).new
        model = Libvirt::Spec::Device::VideoModel.new
        model.type = :vbox
        model.vram = 12
        model.heads = 1
        model.accel3d = false
        model.accel2d = false
        video.models << model
        d.devices << video

        d
      end
    end
  end
end
