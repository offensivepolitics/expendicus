class CreateCommittees < ActiveRecord::Migration
  def self.up
    create_table :committees, :options => 'engine=MyISAM' do |t|
      t.string :fecid
      t.string :name
      t.string :committee_designation
      t.string :connected_org_name
      t.string :interest_group_category
			t.string :committee_type
			t.integer :political_party_id
			t.integer :candidate_id

      t.timestamps
    end
  end

  def self.down
    drop_table :committees
  end
end
