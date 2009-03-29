class CreatePoliticalParties < ActiveRecord::Migration
  def self.up
    create_table :political_parties, :options => 'engine=MyISAM' do |t|
      t.string :name
      t.string :abbreviation

      t.timestamps
    end
  end

  def self.down
    drop_table :political_parties
  end
end
