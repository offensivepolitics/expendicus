# == Schema Information
# Schema version: 20090225132948
#
# Table name: committees
#
#  id                      :integer(4)      not null, primary key
#  fecid                   :string(255)
#  name                    :string(255)
#  committee_designation   :string(255)
#  connected_org_name      :string(255)
#  interest_group_category :string(255)
#  committee_type          :string(255)
#  political_party_id      :integer(4)
#  candidate_id            :integer(4)
#  created_at              :datetime
#  updated_at              :datetime
#

class Committee < ActiveRecord::Base
	has_many :expenditures

	belongs_to :candidate

	has_many :committee_transactions
	
	has_many :committee_financial_summaries
	
	belongs_to :political_party
	
	def total_expenditures
	  @expenditure_sum ||= expenditures.sum(:expenditure_amount)
	  @expenditure_sum
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
  
  def expenditures_by_district
    expenditures.sum(:expenditure_amount,:group => 'district_id').reject {|v| v[0] == 0}.map { |v| [District.find(v[0]),v[1]] }    
  end
  
  def expenditures_by_district_split
    
    #expenditures.sum(:expenditure_amount,:group => 'district_id,support_oppose')    
  end

  def expenditures_divided(scale=1000)
    results = ActiveRecord::Base.connection.find_by_sql()
    tv = expenditures.sum("expenditure_amount/#{scale}", :group => :district_id, :order => "sum(expenditure_amount/#{scale}) desc")

    v = []
    tv.each do |vv|
     v 
    end

    v
  end  

  
  def expenditures_scaled(scale=50,function="scale_variable")
    tv = expenditures.sum(:expenditure_amount, :group => :district_id, :order => "sum(expenditure_amount) desc")
    
    vs = tv.collect {|i| i[1]}
    puts vs.class
    max = vs.max
    min = vs.min
    
    v = {}
    tv.each do |t|
      next if t[0] == 0
      val = t[1]
      if function == "scale_variable"
        scaled = ((val-min)/(max-min))*scale
      elsif function=="scale_static"
        scaled = val / scale
      end
      v[t[0]] = scaled.to_i
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
  
  
  def self.big_spenders(n = 10)
    v = []
    Expenditure.sum(:expenditure_amount,:group => :committee_id,:order => "sum(expenditure_amount) desc",:limit => n).each do |data|
      v << [Committee.find(data[0]),data[1]]
    end    
    v
  end

  def self.big_fundraisers(n = 10)
    v = []
    CommitteeFinancialSummary.find(:all,:limit => n,:order => "total_receipts desc", :include => :committee).each do |c|
      v << [c.committee,c.total_receipts]
    end
    v
  end
  
end
