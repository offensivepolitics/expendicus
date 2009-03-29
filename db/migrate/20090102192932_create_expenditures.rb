class CreateExpenditures < ActiveRecord::Migration
  def self.up
    create_table :expenditures, :options => 'engine=MyISAM' do |t|
      t.string :schedule
      t.integer :committee_id
      t.string :election_code
      t.date :expenditure_date
      t.float :expenditure_amount
      t.float :expenditure_ytd
      t.string :expenditure_purpose_code
      t.string :category_code
      t.string :payee_fecid
      t.string :support_oppose
      t.integer :candidate_id
      t.integer :district_id

      t.timestamps
    end
  end

  def self.down
    drop_table :expenditures
  end
end
