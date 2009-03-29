# == Schema Information
# Schema version: 20090225132948
#
# Table name: committee_transactions
#
#  id                  :integer(4)      not null, primary key
#  committee_id        :integer(4)
#  candidate_id        :integer(4)
#  transaction_date    :date
#  amount              :float
#  transaction_type_id :integer(4)
#  created_at          :datetime
#  updated_at          :datetime
#

class CommitteeTransaction < ActiveRecord::Base

	belongs_to :candidate
	belongs_to :committee

	belongs_to :transaction_type

end
