class CreateStates < ActiveRecord::Migration
  def self.up
    create_table :states, :options => 'engine=MyISAM' do |t|
      t.string :name
      t.string :abbreviation
      t.integer :fipscode

      t.timestamps
    end
  end

  def self.down
    drop_table :states
  end
end
