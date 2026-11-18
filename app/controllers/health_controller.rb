class HealthController < ApplicationController
  def show
    render json: { status: "ok", service: "salman-bot-api", ruby: RUBY_VERSION }
  end
end
