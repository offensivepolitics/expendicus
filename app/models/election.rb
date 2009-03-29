# == Schema Information
# Schema version: 20090225132948
#
# Table name: elections
#
#  id            :integer(4)      not null, primary key
#  year          :integer(4)
#  election_type :string(255)
#  district_id   :integer(4)
#  created_at    :datetime
#  updated_at    :datetime
#

class Election < ActiveRecord::Base

	belongs_to :district
	has_many :candidacies
	has_many :candidates, :through => :candidacies

end
