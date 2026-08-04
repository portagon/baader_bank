# frozen_string_literal: true

module BaaderBank
  # Base class for all errors raised by this gem. Mirrors the API's
  # `ErrorResponse` schema (timestamp, status, code, title, detail).
  class Error < StandardError
    attr_reader :status, :code, :title, :detail, :response_body

    def initialize(status: nil, code: nil, title: nil, detail: nil, response_body: nil)
      @status = status
      @code = code
      @title = title
      @detail = detail
      @response_body = response_body

      super([status, code, title || detail].compact.join(" "))
    end

    # Builds the right typed error for a given HTTP response, or nil for
    # success statuses.
    def self.from_response(status, body)
      klass = ERROR_CLASSES[status]
      return nil unless klass

      body = body.is_a?(Hash) ? body : {}
      klass.new(
        status: status,
        code: body["code"],
        title: body["title"],
        detail: body["detail"],
        response_body: body
      )
    end

    class BadRequestError < Error; end
    class UnauthorizedError < Error; end
    class ForbiddenError < Error; end
    class NotFoundError < Error; end
    class ConflictError < Error; end
    class ServerError < Error; end
    class ServiceUnavailableError < Error; end

    ERROR_CLASSES = {
      400 => BadRequestError,
      401 => UnauthorizedError,
      403 => ForbiddenError,
      404 => NotFoundError,
      409 => ConflictError,
      500 => ServerError,
      503 => ServiceUnavailableError
    }.freeze
  end
end
