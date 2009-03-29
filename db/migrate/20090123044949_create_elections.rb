class CreateElections < ActiveRecord::Migration
  def self.up
    create_table :elections, :options => 'engine=MyISAM' do |t|
      t.integer :year
      t.string :election_type
      t.integer :district_id

      t.timestamps
    end
  end

  def self.down
    drop_table :elections
  end
end
