# frozen_string_literal: true

require 'aws-sdk'

module CSI
  module AWS
    # This module provides a client for making API requests to AWS Security Token Service.
    module STS
      @@logger = CSI::Plugins::CSILogger.create

      # Supported Method Parameters::
      # CSI::AWS::STS.get_temp_credentials(
      #   region: 'required - region name to connect (eu-west-1, ap-southeast-1, ap-southeast-2, eu-central-1, ap-northeast-2, ap-northeast-1, us-east-1, sa-east-1, us-west-1, us-west-2)',
      #   role_arn: 'required - role arn for instance profile to be used',
      #   role_session_name: 'required - the name of the instance profile role',
      #   duration_seconds: 'required - seconds in which sts credentials will expire'
      # )

      public_class_method def self.get_temp_credentials(opts = {})
        region = opts[:region].to_s.scrub.chomp.strip
        role_arn = opts[:role_arn].to_s.scrub.chomp.strip
        role_session_name = opts[:role_session_name].to_s.scrub.chomp.strip
        duration_seconds = opts[:duration_seconds].to_i

        @@logger.info('Retrieving AWS STS Credentials...')
        sts_client = Aws::STS::Client.new(region: region)
        sts_session = sts_client.assume_role(
          role_arn: role_arn,
          role_session_name: role_session_name,
          duration_seconds: duration_seconds
        )
        @@logger.info("complete.\n")

        return sts_session.credentials
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
          credentials = #{self}.get_temp_credentials(
            region: 'required - region name to connect (eu-west-1, ap-southeast-1, ap-southeast-2, eu-central-1, ap-northeast-2, ap-northeast-1, us-east-1, sa-east-1, us-west-1, us-west-2)',
            role_arn: 'required - role arn for instance profile to be used',
            role_session_name: 'required - the name of the instance profile role',
            duration_seconds: 'required - seconds in which sts credentials will expire'
          )

          #{self}.authors
        "
      end
    end
  end
end
