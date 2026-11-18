module Api
  module V1
    class AutomationsController < ApplicationController
      before_action :require_api_token!
      before_action :set_automation, only: %i[show update destroy run]

      def index
        render json: Automation.order(updated_at: :desc)
      end

      def show
        render json: @automation
      end

      def create
        automation = Automation.new(automation_params)
        if automation.save
          render json: automation, status: :created
        else
          render json: { errors: automation.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def update
        if @automation.update(automation_params)
          render json: @automation
        else
          render json: { errors: @automation.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def destroy
        @automation.destroy!
        head :no_content
      end

      def run
        result = AutomationRunner.new(@automation).call
        render json: { automation: @automation.reload, result: result }
      rescue AutomationRunner::UnsafeWorkflow => e
        render json: { error: e.message }, status: :unprocessable_entity
      end

      private

      def require_api_token!
        expected = ENV["SALMAN_API_TOKEN"].to_s
        return render(json: { error: "Set SALMAN_API_TOKEN on the server first" }, status: :service_unavailable) if expected.empty?

        supplied = request.authorization.to_s.delete_prefix("Bearer ")
        valid = ActiveSupport::SecurityUtils.secure_compare(supplied, expected)
        render(json: { error: "Unauthorized" }, status: :unauthorized) unless valid
      end

      def set_automation
        @automation = Automation.find(params[:id])
      end

      def automation_params
        params.require(:automation).permit(:name, :description, :status, :trigger_type, :next_run_at,
          definition: { steps: %i[type message key value operator expected] })
      end
    end
  end
end
