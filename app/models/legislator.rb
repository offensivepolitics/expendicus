# == Schema Information
# Schema version: 20090225132948
#
# Table name: legislators
#
#  id                :integer(4)      not null, primary key
#  title             :string(255)
#  firstname         :string(255)
#  lastname          :string(255)
#  state_id          :integer(4)
#  candidate_id      :integer(4)
#  district_id       :integer(4)
#  gender            :string(255)
#  bioguide_id       :string(255)
#  votesmart_id      :string(255)
#  govtrack_id       :integer(4)
#  crp_id            :string(255)
#  youtube_url       :string(255)
#  rss_url           :string(255)
#  congresspedia_url :string(255)
#  phone             :string(255)
#  fax               :string(255)
#  website           :string(255)
#  created_at        :datetime
#  updated_at        :datetime
#

class Legislator < ActiveRecord::Base

  belongs_to :state
  belongs_to :district
  
  belongs_to :candidate

  
end
