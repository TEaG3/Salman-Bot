require "test_helper"

class AutomationRunnerTest < ActiveSupport::TestCase
  test "runs only the supported safe step types" do
    automation = Automation.new(
      name: "Preview",
      definition: {
        "steps" => [
          { "type" => "set_value", "key" => "state", "value" => "ready" },
          { "type" => "condition", "key" => "state", "operator" => "equals", "expected" => "ready" },
          { "type" => "log", "message" => "Finished" }
        ]
      }
    )

    result = AutomationRunner.new(automation).call

    assert_equal "completed", result[:status]
    assert_equal "ready", result[:context]["state"]
    assert_equal true, result[:steps][1][:condition]
  end

  test "rejects unsupported executable step types" do
    automation = Automation.new(name: "Unsafe", definition: { "steps" => [{ "type" => "shell", "command" => "echo unsafe" }] })

    assert_raises(AutomationRunner::UnsafeWorkflow) do
      AutomationRunner.new(automation).call
    end
  end
end
