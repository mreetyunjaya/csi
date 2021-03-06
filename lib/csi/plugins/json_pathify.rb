# frozen_string_literal: true

require 'jsonpath'

module CSI
  module Plugins
    # This plugin is for leveraging XPath-like searching capabilities for JSON data structures
    module JSONPathify
      # Supported Method Parameters::
      # CSI::Plugins::JSONPathify.search_key(
      #   json_data_struct: "required JSON data structure",
      #   key: "required key to find in JSON data structure. returns key values"
      # )

      public_class_method def self.search_key(opts = {})
        key = opts[:key]
        json_data_struct = opts[:json_data_struct]

        json_path = JsonPath.new("$..#{key}")
        json_path_arr = json_path.on(json_data_struct)

        json_path_arr
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
        puts %{USAGE:
          json_path_arr = #{self}.search_key(
            json_data_struct: "required JSON data structure",
            key: "required key to find in JSON data structure. returns key values"
          )
          #{self}.authors
        }
      end
    end
  end
end
