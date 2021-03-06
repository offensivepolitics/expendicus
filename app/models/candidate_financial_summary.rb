# == Schema Information
# Schema version: 20090225132948
#
# Table name: candidate_financial_summaries
#
#  id                             :integer(4)      not null, primary key
#  candidate_id                   :integer(4)
#  year                           :integer(4)
#  total_receipts                 :integer(4)
#  total_disbursments             :integer(4)
#  beginning_coh                  :integer(4)
#  ending_coh                     :integer(4)
#  authorized_transfers_from      :integer(4)
#  authorized_transfers_to        :integer(4)
#  contributions_from_candidate   :integer(4)
#  loans_from_candidate           :integer(4)
#  other_loans                    :integer(4)
#  candidate_loan_repayments      :integer(4)
#  other_loan_repayments          :integer(4)
#  debts_owed_by                  :integer(4)
#  total_individual_contributions :integer(4)
#  total_pac_contributions        :integer(4)
#  total_party_contributions      :integer(4)
#  individual_refunds             :integer(4)
#  committee_refunds              :integer(4)
#  created_at                     :datetime
#  updated_at                     :datetime
#

class CandidateFinancialSummary < ActiveRecord::Base

	belongs_to :candidate
end
