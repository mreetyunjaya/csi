# frozen_string_literal: true

require 'aws-sdk'

module CSI
  module AWS
    # This module provides a client for making API requests to Amazon CloudWatch.
    module CloudWatch
      @@logger = CSI::Plugins::CSILogger.create

      # Supported Method Parameters::
      # CSI::AWS::CloudWatch.connect(
      #   region: 'required - region name to connect (eu-west-1, ap-southeast-1, ap-southeast-2, eu-central-1, ap-northeast-2, ap-northeast-1, us-east-1, sa-east-1, us-west-1, us-west-2)',
      #   access_key_id: 'required - Use AWS STS for best privacy (i.e. temporary access key id)',
      #   secret_access_key: 'required - Use AWS STS for best privacy (i.e. temporary secret access key',
      #   sts_session_token: 'optional - Temporary token returned by STS client for best privacy'
      # )

      public_class_method def self.connect(opts = {})
        region = opts[:region].to_s.scrub.chomp.strip
        access_key_id = opts[:access_key_id].to_s.scrub.chomp.strip
        secret_access_key = opts[:secret_access_key].to_s.scrub.chomp.strip
        sts_session_token = opts[:sts_session_token].to_s.scrub.chomp.strip

        @@logger.info('Connecting to AWS CloudWatch...')
        if sts_session_token == ''
          cloud_watch_obj = Aws::CloudWatch::Client.new(
            region: region,
            access_key_id: access_key_id,
            secret_access_key: secret_access_key
          )
        else
          cloud_watch_obj = Aws::CloudWatch::Client.new(
            region: region,
            access_key_id: access_key_id,
            secret_access_key: secret_access_key,
            session_token: sts_session_token
          )
        end
        @@logger.info("complete.\n")

        return cloud_watch_obj
      rescue => e
        raise e
      end

      # Supported Method Parameters::
      # CSI::AWS::CloudWatch.disconnect(
      #   cloud_watch_obj: 'required - cloud_watch_obj returned from #connect method'
      # )

      public_class_method def self.disconnect(opts = {})
        cloud_watch_obj = opts[:cloud_watch_obj]
        @@logger.info('Disconnecting...')
        cloud_watch_obj = nil
        @@logger.info("complete.\n")

        cloud_watch_obj
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
          cloud_watch_obj = #{self}.connect(
            region: 'required - region name to connect (eu-west-1, ap-southeast-1, ap-southeast-2, eu-central-1, ap-northeast-2, ap-northeast-1, us-east-1, sa-east-1, us-west-1, us-west-2)',
            access_key_id: 'required - Use AWS STS for best privacy (i.e. temporary access key id)',
            secret_access_key: 'required - Use AWS STS for best privacy (i.e. temporary secret access key',
            sts_session_token: 'optional - Temporary token returned by STS client for best privacy'
          )
          puts cloud_watch_obj.public_methods

          #{self}.disconnect(
            cloud_watch_obj: 'required - cloud_watch_obj returned from #connect method'
          )

          #{self}.authors
        "
      end
    end
  end
end
