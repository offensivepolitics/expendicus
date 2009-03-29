# == Schema Information
# Schema version: 20090225132948
#
# Table name: committee_financial_summaries
#
#  id                                  :integer(4)      not null, primary key
#  committee_id                        :integer(4)
#  total_receipts                      :integer(4)
#  transfers_from_affiliates           :integer(4)
#  contributions_from_individuals      :integer(4)
#  contributions_from_other_committees :integer(4)
#  total_loans_received                :integer(4)
#  total_disbursements                 :integer(4)
#  transfers_to_affiliates             :integer(4)
#  refunds_to_individuals              :integer(4)
#  refunds_to_other_committees         :integer(4)
#  loan_repayments                     :integer(4)
#  cash_on_hand_beginning_of_year      :integer(4)
#  cash_on_hand_close_of_period        :integer(4)
#  debts_owed_by                       :integer(4)
#  nonfederal_transfers_received       :integer(4)
#  contributions_to_other_committees   :integer(4)
#  independent_expenditures            :integer(4)
#  party_coordinated_expenditures      :integer(4)
#  nonfederal_share_of_expenditures    :integer(4)
#  date_through                        :date
#  created_at                          :datetime
#  updated_at                          :datetime
#

class CommitteeFinancialSummary < ActiveRecord::Base

  belongs_to :committee
end
