# == Schema Information
# Schema version: 20090225132948
#
# Table name: candidates
#
#  id                 :integer(4)      not null, primary key
#  firstname          :string(255)
#  lastname           :string(255)
#  fullname           :string(255)
#  political_party_id :integer(4)
#  fecid              :string(255)
#  crpid              :string(255)
#  govtrackid         :string(255)
#  bioguideid         :string(255)
#  votesmartid        :string(255)
#  created_at         :datetime
#  updated_at         :datetime
#

class Candidate < ActiveRecord::Base

	has_many :candidacies
  has_many :elections, :through => :candidacies
  
	belongs_to :political_party

	has_one :vv_rank

	has_one :committee

	has_many :expenditures

	has_many :candidate_financial_summaries

	has_many :committee_transactions
	
	has_one :legislator

	def party
		political_party.abbreviation
	end

	def summary_for(year)
		candidate_financial_summaries.find(:first,:conditions => ["year = ?",year])
	end

  def district_for(election_year=2008)
    elections.find(:first,:conditions => ['year = ?',2008]).district
  end

  def name
    "#{firstname} #{lastname}"
  end
  
  def name_and_party
    "#{lastname}, #{firstname} (#{party})"
  end
  
  def govtrack_url
    if govtrackid != ''
      url = "http://www.govtrack.us/congress/person.xpd?id=#{govtrackid}"
    end
    url ||= nil
    
    url
  end
  
  def crp_url
    if crpid != ''
      url = "http://www.govtrack.us/congress/person.xpd?id=#{govtrackid}"
    end
    url ||= nil
    
    url
  end  
  
  def votesmart_url
    if votesmartid != ''
      url = "http://www.votesmart.org/summary.php?can_id=#{votesmartid}"
    end
    url ||= nil

    url
  end

  def crp_url
    if crpid != ''
      url = "http://www.opensecrets.org/politicians/summary.php?cid=#{crpid}"
    end
    url ||= nil

    url
  end
  
  def bioguide_url
    if crpid != ''
      url = "http://bioguide.congress.gov/scripts/biodisplay.pl?index=#{bioguideid}"
    end
    url ||= nil
    url    
  end
end
