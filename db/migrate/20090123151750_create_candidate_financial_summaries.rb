class CreateCandidateFinancialSummaries < ActiveRecord::Migration
  def self.up
		create_table :candidate_financial_summaries, :options => 'engine=MyISAM' do |t|
			t.column :candidate_id, :integer
      
      t.column :year, :integer

      t.column :total_receipts, :integer
      t.column :total_disbursments, :integer
      t.column :beginning_coh, :integer
      t.column :ending_coh, :integer
      
      t.column :authorized_transfers_from, :integer
      t.column :authorized_transfers_to, :integer
      t.column :contributions_from_candidate, :integer
      t.column :loans_from_candidate, :integer
      t.column :other_loans, :integer
      t.column :candidate_loan_repayments, :integer
      t.column :other_loan_repayments, :integer
      t.column :debts_owed_by, :integer
      t.column :total_individual_contributions, :integer
      t.column :total_pac_contributions, :integer
      t.column :total_party_contributions, :integer
      t.column :individual_refunds, :integer
      t.column :committee_refunds, :integer
      t.timestamps
    end
  end

  def self.down
    drop_table :candidate_financial_summaries
  end
end
