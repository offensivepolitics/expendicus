# == Schema Information
# Schema version: 20090225132948
#
# Table name: districts
#
#  id         :integer(4)      not null, primary key
#  name       :string(255)
#  number     :integer(4)
#  usecode    :string(255)
#  state_id   :integer(4)
#  created_at :datetime
#  updated_at :datetime
#

class District < ActiveRecord::Base

	belongs_to :state

	has_many :elections

	has_one :district_polygon, :foreign_key => 'district_id',:class_name => 'DistrictPolygon'

  has_many :expenditures

	def find_election(year,type)
		elections.find(:first,:conditions=>["year = ? and election_type = ?",year,type])
	end
  
  def expenditures_as_array
    tv = expenditures.sum(:expenditure_amount,:group => :expenditure_date,
      :order => "expenditures.expenditure_date desc")
    v = {}
    tv.each do |t|
      v[t[0]] = {:amount => t[1]}
    end
    v
  end
  
  def expenditures_for_timeline(n=365)
     tv = expenditures.sum(:expenditure_amount,:group => :expenditure_date,
       :order => "expenditures.expenditure_date desc",:limit=>n)
     v = {}
     tv.each do |t|
       v[t[0]] = {:amount => t[1]}
     end
     v  
  end
     
  def pac_summary(scale=1)
    results_hash = ActiveRecord::Base.connection.execute("select committee_id,support_oppose, sum(expenditure_amount) as 'exp_sum' from expenditures where district_id = #{id} group by committee_id,support_oppose")
    values = {}
    results_hash.each_hash { |v|
      values[v["committee_id"].to_i] ||= {}
      values[v["committee_id"].to_i]["S"] ||= 0.0
      values[v["committee_id"].to_i]["O"] ||= 0.0
      val = v["exp_sum"].to_i
      if scale > 1
        val = val / scale
      end
      values[v["committee_id"].to_i][v["support_oppose"]] = val
    }
    
    values
  end
  
  def pac_summary_to_gchart_list
    summary = pac_summary
    pacs = summary.keys.sort.uniq
    
    data_support = []
    data_oppose = []
    min_s = 50000000.0
    max_s = 0.0
    min_o = 50000000.0
    max_o = 0.0
    
    pacs.sort.each do |pac|
      val = summary[pac]["S"].to_i
      if val < min_s
        min_s = val
      end
      if val > max_s
        max_s = val
      end

      val = summary[pac]["O"].to_i
      if val < min_o
        min_o = val
      end
      if val > max_o
        max_o = val
      end

    end
    #593924
    pacs.sort.each do |pac|
      #data_support << summary[pac]["S"].to_i
      #data_oppose << summary[pac]["O"].to_i
      val = summary[pac]["S"]
      scaled = (((val-min_s)/(max_s-min_s))*100.0).to_i
      if scaled < 0.0 then scaled = 0.0 end
      data_support << scaled

      val = summary[pac]["O"]
      scaled = (((val-min_o)/(max_o-min_o))*100.0).to_i
      if scaled < 0.0 then scaled = 0.0 end
      data_oppose << scaled
      
    end
    [pacs.sort,[data_support,data_oppose]]
  end

	def to_s
		@s ||= "#{state.abbreviation}-#{number}"
		@s
	end

end
