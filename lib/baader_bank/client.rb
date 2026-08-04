# frozen_string_literal: true

require "digest"

module BaaderBank
  # Low-level HTTP client plus the domain-specific resource methods mixed in
  # below (one module per OpenAPI tag, following Octokit's convention of a
  # single Client class assembled from per-resource modules rather than
  # separate resource objects).
  class Client
    def initialize(configuration = BaaderBank.configuration)
      @configuration = configuration
      @authenticator = Authenticator.new(configuration)
      @connection = Connection.build(configuration)
    end

    def get(path, params = {})
      request(:get, path, params: params)
    end

    def post(path, body = {})
      request(:post, path, body: body)
    end

    def put(path, body = {})
      request(:put, path, body: body)
    end

    # Payments endpoints (SEPA credit transfer / direct debit) take a raw
    # ISO 20022 XML document rather than JSON.
    def post_xml(path, xml_body)
      request(:post, path, body: xml_body, headers: { "Content-Type" => "application/xml" })
    end

    def delete(path, params = {})
      request(:delete, path, params: params)
    end

    # Uploads a file via multipart/form-data, as required by every
    # `.../upload/...` endpoint. `file` is a path or IO; `fields` are the
    # additional form fields (e.g. documentDateTime, customerId).
    # `checksumSha256` is computed automatically unless already present in
    # `fields`.
    def post_multipart(path, file:, file_field: "zipFile", fields: {})
      io = file.respond_to?(:read) ? file : File.open(file, "rb")
      content = io.read
      io.rewind if io.respond_to?(:rewind)

      payload = fields.transform_keys(&:to_s)
      payload["checksumSha256"] ||= Digest::SHA256.hexdigest(content)
      payload[file_field] = Faraday::Multipart::FilePart.new(
        StringIO.new(content), "application/zip", File.basename(file.to_s)
      )

      request(:post, path, body: payload)
    end

    private

    attr_reader :configuration, :authenticator, :connection

    def request(method, path, params: {}, body: nil, headers: {})
      response = connection.public_send(method, path) do |req|
        req.headers["Authorization"] = "Bearer #{authenticator.access_token}"
        req.headers.update(headers) if headers && !headers.empty?
        req.params.update(params) if params && !params.empty?
        req.body = body if body
      end
      handle_response(response)
    rescue Faraday::Error => e
      raise error_from_faraday(e)
    end

    def handle_response(response)
      error = Error.from_response(response.status, response.body)
      raise error if error

      response.body
    end

    def error_from_faraday(faraday_error)
      response = faraday_error.response
      return Error.new(detail: faraday_error.message) unless response

      Error.from_response(response[:status], response[:body]) ||
        Error.new(status: response[:status], detail: faraday_error.message)
    end

    # "The document datetime(ISO 8601). Format: yyyy-MM-ddTHH:mm:ss.SSS"
    # (used by /orders/upload/ordering and /accounts/upload/*).
    def iso8601_millis(time)
      time.strftime("%Y-%m-%dT%H:%M:%S.%L")
    end

    # "The document datetime (ISO 8601). Format: YYYY-MM-DDThh:mm"
    # (used by /accounts/upload/*).
    def iso8601_minutes(time)
      time.strftime("%Y-%m-%dT%H:%M")
    end
  end
end
