class CreateEpds < ActiveRecord::Migration
  def change
    create_table :epds do |t|
      t.integer :id_radio, unique: true
      t.integer :temperature
      t.integer :current
      t.float :voltage
      t.float :active_power
      t.float :reactive_power
      t.float :apparent_power
      t.integer :aggregated_active_energy
      t.integer :aggregated_reactive_energy
      t.integer :aggregated_apparent_energy
      t.integer :frequency

      t.timestamps null: false
    end
  end
end
