require "net/http"
require "uri"

module Api
  module V1
    class AssistantController < ApplicationController
      before_action :require_api_token!

      def plan
        prompt = params.require(:prompt).to_s.strip
        return render(json: { error: "Prompt is required" }, status: :unprocessable_entity) if prompt.blank?
        return render(json: { error: "Prompt is too long" }, status: :unprocessable_entity) if prompt.length > 4000

        api_key = ENV["OPENAI_API_KEY"].to_s
        return render(json: { error: "Configure OPENAI_API_KEY on the Ruby server to enable the AI builder" }, status: :service_unavailable) if api_key.empty?

        uri = URI("https://api.openai.com/v1/chat/completions")
        request = Net::HTTP::Post.new(uri)
        request["Authorization"] = "Bearer #{api_key}"
        request["Content-Type"] = "application/json"
        request.body = {
          model: ENV.fetch("OPENAI_MODEL", "gpt-4o-mini"),
          temperature: 0.2,
          response_format: { type: "json_object" },
          messages: [
            { role: "system", content: "You are Salman-Bot, an automation workflow designer. Return only JSON with keys name, description, trigger_type, steps. trigger_type must be manual or scheduled. steps must be an array of at most 12 objects. Allowed types only: log {type,message}, set_value {type,key,value}, condition {type,key,operator,expected}. Never output code, shell commands, arbitrary URLs, credentials, or unsupported actions. Explain limitations in description. Use Arabic when the user writes Arabic." },
            { role: "user", content: prompt }
          ]
        }.to_json

        response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true, open_timeout: 8, read_timeout: 35) do |http|
          http.request(request)
        end
        data = JSON.parse(response.body)
        unless response.is_a?(Net::HTTPSuccess)
          return render(json: { error: "AI provider request failed", details: data.dig("error", "message") }, status: :bad_gateway)
        end

        content = data.dig("choices", 0, "message", "content")
        plan = JSON.parse(content)
        steps = plan["steps"]
        allowed = %w[log set_value condition]
        unless steps.is_a?(Array) && steps.length <= 12 && steps.all? { |step| step.is_a?(Hash) && allowed.include?(step["type"]) }
          return render(json: { error: "The AI returned an unsupported workflow. Please try a simpler request." }, status: :unprocessable_entity)
        end

        render json: { plan: plan }
      rescue JSON::ParserError
        render json: { error: "The AI returned an invalid plan" }, status: :bad_gateway
      rescue Net::OpenTimeout, Net::ReadTimeout, SocketError
        render json: { error: "AI provider is temporarily unavailable" }, status: :gateway_timeout
      end

      private

      def require_api_token!
        expected = ENV["SALMAN_API_TOKEN"].to_s
        return render(json: { error: "Set SALMAN_API_TOKEN on the server first" }, status: :service_unavailable) if expected.empty?

        supplied = request.authorization.to_s.delete_prefix("Bearer ")
        valid = ActiveSupport::SecurityUtils.secure_compare(supplied, expected)
        render(json: { error: "Unauthorized" }, status: :unauthorized) unless valid
      end
    end
  end
end
