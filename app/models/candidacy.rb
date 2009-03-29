# == Schema Information
# Schema version: 20090225132948
#
# Table name: candidacies
#
#  id           :integer(4)      not null, primary key
#  election_id  :integer(4)
#  candidate_id :integer(4)
#  winner       :integer(4)
#  votecount    :integer(4)
#  created_at   :datetime
#  updated_at   :datetime
#

class Candidacy < ActiveRecord::Base
	
	belongs_to :election
	belongs_to :candidate

end
