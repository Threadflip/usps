require 'typhoeus'

module USPS
  class Client
    def request(request, &block)
      server = server(request)

      # Make the API request to the USPS servers. Used to support POST, now it's
      # just GET request *grumble*.
      response = Typhoeus::Request.get(server, {
        :timeout => USPS.config.timeout,
        :params => {
          "API" => request.api,
          "XML" => request.build
        }
      })

      # Parse the request
      xml = Nokogiri::XML.parse(response.body)

      # Initialize the proper response object and parse the message
      request.response_for(xml)
    end

    def testing?
      USPS.config.testing
    end

    private
    def server(request)
      dll = testing? ? "ShippingAPITest.dll" : "ShippingAPI.dll"

      case
      when request.secure?
        "https://secure.shippingapis.com/#{dll}"
      when testing?
        "http://testing.shippingapis.com/#{dll}"
      else
        "http://production.shippingapis.com/#{dll}"
      end
    end
  end
end
