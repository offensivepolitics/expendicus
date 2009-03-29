class CreateCommitteeTransactions < ActiveRecord::Migration
  def self.up
    create_table :committee_transactions, :options => 'engine=MyISAM' do |t|
      t.integer :committee_id
      t.integer :candidate_id
      t.date :transaction_date
      t.float :amount
      t.integer :transaction_type_id
			
      t.timestamps
    end
  end

  def self.down
    drop_table :committee_transactions
  end
end
