class AddPeriodToEpds < ActiveRecord::Migration
  def change
  	add_column :epds, :period, :integer
  end
end
