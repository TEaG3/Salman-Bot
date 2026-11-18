class AutomationRunner
  class UnsafeWorkflow < StandardError; end

  def initialize(automation)
    @automation = automation
  end

  def call
    definition = @automation.definition
    steps = definition.is_a?(Hash) ? definition["steps"] : nil
    raise UnsafeWorkflow, "Workflow steps are missing" unless steps.is_a?(Array) && steps.length <= 30

    context = {}
    results = steps.map.with_index do |step, index|
      raise UnsafeWorkflow, "Unsupported step at position #{index + 1}" unless step.is_a?(Hash)

      case step["type"]
      when "log"
        { step: index + 1, status: "ok", message: step["message"].to_s.first(500) }
      when "set_value"
        key = step["key"].to_s
        raise UnsafeWorkflow, "Invalid variable name" unless key.match?(/\A[a-zA-Z][a-zA-Z0-9_]{0,39}\z/)
        context[key] = step["value"].to_s.first(500)
        { step: index + 1, status: "ok", variable: key }
      when "condition"
        key = step["key"].to_s
        actual = context[key].to_s
        expected = step["expected"].to_s
        passed = step["operator"] == "not_equals" ? actual != expected : actual == expected
        { step: index + 1, status: "ok", condition: passed }
      else
        raise UnsafeWorkflow, "Unsupported action type"
      end
    end

    payload = { status: "completed", steps: results, context: context }
    @automation.update!(last_run_at: Time.current, last_result: payload) if @automation.persisted?
    payload
  end
end
