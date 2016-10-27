require 'base64'
require 'json'

module CSI
  module Plugins
    # This plugin is somewhat of a hack used for extracting OAuth2 tokens 
    # from HTTP responses to be used for subsequent HTTP requests.
    module OAuth2
      # Supported Method Parameters::
      # CSI::Plugins::OAuth2.decode(
      #   :oauth2_token => 'required oauth2 token'
      # )
      public
      def self.decode(opts)
        oauth2_token = opts[:oauth2_token]
        return Base64.decode64(oauth2_token)
      end

      # Supported Method Parameters::
      # CSI::Plugins::OAuth2.get_value_by_key(
      #   :oauth2_token => 'required oauth2 token', 
      #   :key => 'required oauth2 token key name located within the Base64 encoded token as symbol, e.g. :company_id'
      # )
      public
      def self.get_value_by_key(opts)
        oauth2_token = opts[:oauth2_token]
        # Make sure we're receiving a symbol.  Convert to string first in case an int is passed.
        key = opts[:key].to_s.to_sym 

        # Holy omg...strip out the ugly tail of this stuff.
        readable_oauth2_token = Base64.decode64(oauth2_token).match(/^(.*?)\]\}/).to_s
        
        json_oauth2_token_body = JSON.parse(readable_oauth2_token.split(/^\{(.*?)\}/)[-1], symbolize_names: true)
        return json_oauth2_token_body[key]
      end

      # Author(s):: Jacob Hoopes <jake.hoopes@gmail.com>
      public
      def self.authors
        authors = %Q{AUTHOR(S):
          Jacob Hoopes <jake.hoopes@gmail.com>
        }

        return authors
      end

      # Display Usage for this Module
      public
      def self.help
        puts %Q{USAGE:
          #{self}.decode(:oauth2_token => 'required oauth2 token')"

          #{self}.get_value_by_key(
            :oauth2_token => 'required oauth2 token', 
            :key => 'required oauth2 token key name located within the Base64 encoded token as symbol, e.g. :company_id'
          )

          #{self}.authors
        }
      end
    end
  end
end
