# == Schema Information
# Schema version: 20090225132948
#
# Table name: political_parties
#
#  id           :integer(4)      not null, primary key
#  name         :string(255)
#  abbreviation :string(255)
#  created_at   :datetime
#  updated_at   :datetime
#

class PoliticalParty < ActiveRecord::Base
end
