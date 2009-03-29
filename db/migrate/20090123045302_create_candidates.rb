class CreateCandidates < ActiveRecord::Migration
  def self.up 
    create_table :candidates, :options => 'engine=MyISAM' do |t|
      t.string :firstname
      t.string :lastname
			t.string :fullname
			t.integer :political_party_id
      t.string :fecid
      t.string :crpid
      t.string :govtrackid
      t.string :bioguideid
      t.string :votesmartid
      t.timestamps
    end
  end

  def self.down
    drop_table :candidates
  end
end
