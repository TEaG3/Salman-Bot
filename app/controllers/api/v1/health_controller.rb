module Api
  module V1
    class HealthController < ApplicationController
      def show
        render json: {
          status: "ok",
          service: "salman-bot-api",
          version: "1",
          ruby: RUBY_VERSION,
          timestamp: Time.current.iso8601
        }
      end
    end
  end
end
