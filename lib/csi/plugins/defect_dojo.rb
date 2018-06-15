# frozen_string_literal: true

require 'json'

module CSI
  module Plugins
    # This plugin converts images to readable text
    # TODO: Convert all rest requests to POST instead of GET
    module DefectDojo
      @@logger = CSI::Plugins::CSILogger.create

      # Supported Method Parameters::
      # dd_obj = CSI::Plugins::DefectDojo.login_v1(
      #   host: 'required - host/ip of DefectDojo Server',
      #   port: 'optional - port of DefectDojo server (defaults to 8000)',
      #   username: 'required - username to AuthN w/ api v1)',
      #   api_key: 'optional - defect dojo api key (will prompt if nil)'
      # )

      public

      def self.login_v1(opts = {})
        dd_obj = {}
        dd_obj[:host] = opts[:host]
        dd_obj[:port] = if opts[:port]
                          opts[:port].to_i
                        else
                          8000
                        end

        username = opts[:username].to_s.scrub

        http_body[:api_key] = if opts[:api_key].nil?
                                 CSI::Plugins::AuthenticationHelper.mask_password(
                                   prompt: 'API Key'
                                 )
                               else
                                 opts[:api_key].to_s.scrub
                               end

        dd_obj[:authz_header] = "ApiKey #{username}:#{api_key}"

        return dd_obj
      rescue => e
        raise e
      end

      # Supported Method Parameters::
      # dd_obj = CSI::Plugins::DefectDojo.login_v2(
      #   host: 'required - host/ip of DefectDojo Server',
      #   port: 'optional - port of DefectDojo server (defaults to 8000)',
      #   username: 'required - username to AuthN w/ api v2)',
      #   password: 'optional - defect dojo api key (will prompt if nil)'
      # )

      public

      def self.login_v2(opts = {})
        http_body = {}

        host = opts[:host]
        port = if opts[:port]
                 opts[:port].to_i
               else
                 8000
               end

        http_body[:username] = opts[:username].to_s.scrub

        base_dd_api_uri = "#{host}:#{port}/api/v2".to_s.scrub

        http_body[:password] = if opts[:password].nil?
                                 CSI::Plugins::AuthenticationHelper.mask_password
                               else
                                 opts[:password].to_s.scrub
                               end

        http_headers = {}
        http_headers[:content_type] = 'application/json'

        @@logger.info("Logging into DefectDojo REST API: #{base_dd_api_uri}")
        rest_client = CSI::Plugins::TransparentBrowser.open(browser_type: :rest)::Request
        response = rest_client.execute(
          method: :post,
          url: "#{base_dd_api_uri}/api-token-auth/",
          verify_ssl: false,
          headers: http_headers,
          payload: http_body.to_json
        )

        # Return array containing the post-authenticated DefectDojo REST API token
        json_response = JSON.parse(response, symbolize_names: true)
        dd_obj = json_response[:token]

        return dd_obj
      rescue => e
        raise e
      end

      # Supported Method Parameters::
      # dd_v1_rest_call(
      #   dd_obj: 'required dd_obj returned from #login_v1 method',
      #   rest_call: 'required rest call to make per the schema',
      #   http_method: 'optional HTTP method (defaults to GET)
      #   http_body: 'optional HTTP body sent in HTTP methods that support it e.g. POST'
      # )

      private_class_method def self.dd_v1_rest_call(opts = {})
        dd_obj = opts[:dd_obj]
        rest_call = opts[:rest_call].to_s.scrub
        http_method = if opts[:http_method].nil?
                        :get
                      else
                        opts[:http_method].to_s.scrub.to_sym
                      end
        params = opts[:params]
        http_body = opts[:http_body].to_s.scrub
        host = dd_obj[:host]
        port = dd_obj[:port]
        base_dd_api_uri = "http://#{host}:#{port}/api/v1".to_s.scrub

        rest_client = CSI::Plugins::TransparentBrowser.open(browser_type: :rest)::Request

        case http_method
        when :get
          response = rest_client.execute(
            method: :get,
            url: "#{base_dd_api_uri}/#{rest_call}",
            headers: {
              content_type: 'application/json; charset=UTF-8',
              authorization: dd_obj[:authz_header]
              params: params
            },
            verify_ssl: false
          )

        when :post
          response = rest_client.execute(
            method: :post,
            url: "#{base_dd_api_uri}/#{rest_call}",
            headers: {
              content_type: 'application/json; charset=UTF-8',
              authorization: dd_obj[:authz_header]
            },
            payload: http_body,
            verify_ssl: false
          )

        else
          raise @@logger.error("Unsupported HTTP Method #{http_method} for #{self} Plugin")
        end

        sleep 3

        return response
      rescue StandardError, SystemExit, Interrupt => e
        logout(dd_obj) unless dd_obj.nil?
        raise e
      end

      # Supported Method Parameters::
      # product_list = CSI::Plugins::DefectDojo.product_list(
      #   dd_obj: 'required dd_obj returned from #login_v1 method'
      # )

      public

      def self.product_list(opts = {})
        response = dd_v1_rest_call(
          dd_obj: dd_obj,
          rest_call: 'products'
        )

        # Return array containing the post-authenticated DefectDojo REST API token
        json_response = JSON.parse(response, symbolize_names: true)
        product_list = json_response

        return dd_obj
      rescue => e
        raise e
      end

      # Supported Method Parameters::
      # CSI::Plugins::DefectDojo.logout(
      #   dd_obj: 'required dd_obj returned from #login_v1 or #login_v2 method'
      # )

      public

      def self.logout(opts = {})
        dd_obj = opts[:dd_obj]
        @@logger.info('Logging out...')
        # TODO: Terminate Session if Possible via API Call
        dd_obj = nil
      rescue => e
        raise e
      end

      # Author(s):: Jacob Hoopes <jake.hoopes@gmail.com>

      public

      def self.authors
        authors = "AUTHOR(S):
          Jacob Hoopes <jake.hoopes@gmail.com>
        "

        authors
      end

      # Display Usage for this Module

      public

      def self.help
        puts "USAGE:
          dd_obj = #{self}.login_v2(
            host: 'required - host/ip of DefectDojo Server',
            port: 'optional - port of DefectDojo server (defaults to 8000)',
            username: 'required - username to AuthN w/ api v2)',
            password: 'optional - defect dojo api key (will prompt if nil)'
          )

          product_list = #{self}.product_list(
            dd_obj: 'required dd_obj returned from #login_v1 method'
          )

          #{self}.logout(
            dd_obj: 'required dd_obj returned from #login_v1 or #login_v2 method'
          )

          #{self}.authors
        "
      end
    end
  end
end
