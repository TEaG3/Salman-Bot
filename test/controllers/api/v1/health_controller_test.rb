require "test_helper"

class Api::V1::HealthControllerTest < ActionDispatch::IntegrationTest
  test "returns a healthy API status" do
    get "/api/v1/health"

    assert_response :success
    body = response.parsed_body
    assert_equal "ok", body["status"]
    assert_equal "salman-bot-api", body["service"]
    assert_equal "1", body["version"]
  end
end
