class CreateLightingProfile < ActiveRecord::Migration
  def change
    create_table :lighting_profiles do |t|
    	t.references :epd, index: true
    	t.string :profile 
    	t.boolean :active
    end
  end
end
