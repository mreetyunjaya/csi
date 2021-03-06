# frozen_string_literal: true

module CSI
  module Plugins
    # This plugin is used for interacting with an RFIDler using the
    # the screen command as a terminal emulator.
    module RFIDler
      # Supported Method Parameters::
      # bus_pirate_obj = CSI::Plugins::RFIDler.connect_via_screen(
      #   screen_bin: 'optional - defaults to /usr/bin/screen'
      #   block_dev: 'optional - serial block device path (defaults to /dev/ttyUSB0)'
      # )

      public_class_method def self.connect_via_screen(opts = {})
        if opts[:block_dev].nil?
          block_dev = '/dev/ttyUSB0'
        else
          # TODO: if block_dev doesn't exist it will try to operate on a nil file and fail.
          #  account for this issue.
          block_dev = opts[:block_dev].to_s if File.exist?(opts[:block_dev].to_s)
        end

        if opts[:screen_bin].nil?
          screen_bin = '/usr/bin/screen'
        else
          screen_bin = opts[:screen_bin].to_s.strip.chomp.scrub
        end

        raise "ERROR: #{screen_bin} not found." unless File.exist?(screen_bin)

        screen_params = "#{block_dev} 9600 8 N 1"
        screen_cmd = "#{screen_bin} #{screen_params}"
        system(screen_cmd)
      rescue => e
        raise e
      end

      # Author(s):: Jacob Hoopes <jake.hoopes@gmail.com>

      public_class_method def self.authors
        authors = "AUTHOR(S):
          Jacob Hoopes <jake.hoopes@gmail.com>
        "

        authors
      end

      # Display Usage for this Module

      public_class_method def self.help
        puts "USAGE:
          #{self}.connect_via_screen(
            screen_bin: 'optional - defaults to /usr/bin/screen'
            block_dev: 'optional serial block device path (defaults to /dev/ttyUSB0)'
          )

          #{self}.authors
        "
      end
    end
  end
end
