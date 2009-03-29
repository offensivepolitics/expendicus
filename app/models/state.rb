# == Schema Information
# Schema version: 20090225132948
#
# Table name: states
#
#  id           :integer(4)      not null, primary key
#  name         :string(255)
#  abbreviation :string(255)
#  fipscode     :integer(4)
#  created_at   :datetime
#  updated_at   :datetime
#

class State < ActiveRecord::Base

	has_many :districts

	has_one :state_polygon, :foreign_key => 'state_id',:class_name => 'StatePolygon'

	def find_district(number)
		districts.find(:first,:conditions => ["number = ?",number])
	end

end
