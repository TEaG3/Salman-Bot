class CreateAutomations < ActiveRecord::Migration[8.0]
  def change
    create_table :automations do |t|
      t.string :name, null: false
      t.text :description
      t.string :status, null: false, default: "draft"
      t.string :trigger_type, null: false, default: "manual"
      t.datetime :next_run_at
      t.jsonb :definition, null: false, default: { "steps" => [] }
      t.datetime :last_run_at
      t.jsonb :last_result
      t.timestamps
    end

    add_index :automations, :status
    add_index :automations, :next_run_at
  end
end
