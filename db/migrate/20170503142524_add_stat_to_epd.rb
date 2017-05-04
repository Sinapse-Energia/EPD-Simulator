class AddStatToEpd < ActiveRecord::Migration
  def change
    add_column :epds, :stat, :integer
    add_column :epds, :dstat, :integer
    add_column :epds, :nominal_power, :integer
  end
end
