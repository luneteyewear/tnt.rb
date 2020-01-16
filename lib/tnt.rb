require 'active_support/core_ext/hash/conversions'
require 'active_support/core_ext/hash/keys'
require 'http/rest_client'
require 'gyoku'

# TNT HTTP API Client
module TNT
  # Base endpoint resources class
  class Resource < OpenStruct
    extend HTTP::RestClient::DSL

    endpoint 'https://express.tnt.com'

    XML_HEADER = '<?xml version="1.0" encoding="UTF-8"?>'.freeze
    XML_RENDER_OPTIONS = {
      unwrap: false, key_converter: :upcase, pretty_print: true
    }

    # Returns a payload with service credentials
    #
    # @return [Hash]
    def self.credentials
      {
        company: ENV['TNT_USERNAME'],
        password: ENV['TNT_PASSWORD'],
        appid: :EC,
        appversion: 3.0
      }
    end

    # Renders a dictionary to XML
    #
    # @param data [Hash] object to be rendered
    # @return [String]
    def self.to_xml(data)
      XML_HEADER + Gyoku.xml({ eshipper: data }, XML_RENDER_OPTIONS)
    end

    # Validate error response
    #
    # Looks at the response code by default.
    #
    # @param response [HTTP::Response] the server response
    # @param parsed [Object] the parsed server response
    #
    # @return [TrueClass] if status code is not a successful standard value
    def self.error_response?(response, parsed)
      parsed.is_a?(Hash) && (
        parsed.dig('parse_error') ||
        parsed.dig('runtime_error') ||
        parsed.dig('document', 'error')
      ) || super
    end

    # Extracts the error message from the response
    #
    # @param response [HTTP::Response] the server response
    # @param parsed [Object] the parsed server response
    #
    # @return [String]
    def self.extract_error(response, parsed)
      parsed&.dig('runtime_error') ||
        parsed&.dig('parse_error') ||
        parsed&.dig('document', 'error')&.first ||
        super
    end

    # Parses response (from XML)
    #
    # @param response [HTTP::Response] object
    # @return [Object]
    def self.parse_response(response)
      Hash.from_xml(response.body.to_s).deep_transform_keys(&:downcase)
    rescue StandardError
      [response.body.to_s.split(':')].to_h.deep_transform_keys(&:downcase)
    end
  end

  # Shipments endpoint resource
  class Shipment < Resource
    path '/expressconnect/shipping/ship'

    # Handles the shipment label creation
    #
    # @return [TNT::Shipment]
    def self.create(payload)
      opts = { form: { xml_in: to_xml(payload) } }
      pre_response = request(:post, uri, opts)

      # Use the token and get the real response...
      opts = { form: { xml_in: 'GET_RESULT:' + pre_response['complete'] } }
      response = request(:post, uri, opts)

      new((response['document'] || response).merge(pre_response))
    end
  end

  # Label endpoint resource
  class Label < Resource
    path '/expressconnect/shipping/ship'

    # Handles the shipment label fetching request
    #
    # @return [TNT::Response]
    def self.find(ref)
      new(request(:post, uri, form: { xml_in: 'GET_LABEL:' + ref.to_s }))
    end
  end

  # Manifest endpoint resource
  class Manifest < Resource
    path '/expressconnect/shipping/ship'

    # Handles the shipment manifest fetching request
    #
    # @return [TNT::Response]
    def self.find(ref)
      new(request(:post, uri, form: { xml_in: 'GET_MANIFEST:' + ref.to_s }))
    end
  end
end
