class Automation < ApplicationRecord
  validates :name, presence: true, length: { maximum: 120 }
  validates :status, inclusion: { in: %w[draft active paused] }
  validates :trigger_type, inclusion: { in: %w[manual scheduled] }
  validate :definition_is_safe

  scope :due, -> { where(status: "active", trigger_type: "scheduled").where("next_run_at <= ?", Time.current) }

  private

  def definition_is_safe
    return if definition.blank?
    errors.add(:definition, "must be an object") unless definition.is_a?(Hash)
    steps = definition.is_a?(Hash) ? definition["steps"] : nil
    errors.add(:definition, "must contain a steps array") unless steps.is_a?(Array)
    return unless steps.is_a?(Array)
    errors.add(:definition, "contains too many steps") if steps.length > 30
    allowed = %w[log set_value condition]
    steps.each do |step|
      unless step.is_a?(Hash) && allowed.include?(step["type"])
        errors.add(:definition, "contains an unsupported step")
        break
      end
    end
  end
end
