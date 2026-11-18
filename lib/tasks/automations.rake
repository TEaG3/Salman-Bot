namespace :automations do
  desc "Run due scheduled automations (invoke from a trusted cron service)"
  task run_due: :environment do
    Automation.due.find_each do |automation|
      begin
        AutomationRunner.new(automation).call
        automation.update!(next_run_at: nil, status: "paused")
        puts "Completed automation ##{automation.id}"
      rescue StandardError => e
        automation.update!(last_run_at: Time.current, last_result: { status: "failed", error: e.message })
        warn "Automation ##{automation.id} failed: #{e.class}"
      end
    end
  end
end
