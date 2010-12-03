module Virtuoso
  module API
    # Base class specifying the API for all hypervisors. Every feature in
    # this base class must be overloaded by any hypervisors.
    class Hypervisor
      # The libvirt connection instance.
      attr_reader :connection

      # Initializes a hypervisor with the given libvirt connection. The
      # connection should be established through {Virtuoso.connect}, which
      # also chooses the correct hypervisor.
      def initialize(connection)
        @connection = connection
      end

      # Returns a new {VM} instance that can be used to create a new virtual
      # machine.
      #
      # @return [VM]
      def new_vm; end
    end
  end
end
