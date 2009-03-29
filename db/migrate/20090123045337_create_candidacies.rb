class CreateCandidacies < ActiveRecord::Migration
  def self.up 
    create_table :candidacies, :options => 'engine=MyISAM' do |t|
      t.integer :election_id
      t.integer :candidate_id
      t.integer :winner
      t.integer :votecount

      t.timestamps
    end
  end

  def self.down
    drop_table :candidacies
  end
end
