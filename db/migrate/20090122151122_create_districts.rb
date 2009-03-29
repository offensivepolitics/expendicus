class CreateDistricts < ActiveRecord::Migration
  def self.up
    create_table :districts, :options => 'engine=MyISAM' do |t|
      t.string :name
      t.integer :number
      t.string :usecode
      t.integer :state_id

      t.timestamps
    end
  end

  def self.down
    drop_table :districts
  end
end
