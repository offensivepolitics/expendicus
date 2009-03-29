class CreateCommitteeFinancialSummaries < ActiveRecord::Migration
  def self.up
    create_table :committee_financial_summaries, :options => 'engine=MyISAM' do |t|
      t.integer :committee_id
      t.integer :total_receipts
      t.integer :transfers_from_affiliates
      t.integer :contributions_from_individuals
      t.integer :contributions_from_other_committees
      t.integer :total_loans_received
      t.integer :total_disbursements
      t.integer :transfers_to_affiliates
      t.integer :refunds_to_individuals
      t.integer :refunds_to_other_committees
      t.integer :loan_repayments
      t.integer :cash_on_hand_beginning_of_year
      t.integer :cash_on_hand_close_of_period
      t.integer :debts_owed_by
      t.integer :nonfederal_transfers_received
      t.integer :contributions_to_other_committees
      t.integer :independent_expenditures
      t.integer :party_coordinated_expenditures
      t.integer :nonfederal_share_of_expenditures
      t.date :date_through

      t.timestamps
    end
  end

  def self.down
    drop_table :committee_financial_summaries
  end
end
