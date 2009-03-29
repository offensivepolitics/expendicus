# == Schema Information
# Schema version: 20090225132948
#
# Table name: expenditures
#
#  id                       :integer(4)      not null, primary key
#  schedule                 :string(255)
#  committee_id             :integer(4)
#  election_code            :string(255)
#  expenditure_date         :date
#  expenditure_amount       :float
#  expenditure_ytd          :float
#  expenditure_purpose_code :string(255)
#  category_code            :string(255)
#  payee_fecid              :string(255)
#  support_oppose           :string(255)
#  candidate_id             :integer(4)
#  district_id              :integer(4)
#  created_at               :datetime
#  updated_at               :datetime
#

class Expenditure < ActiveRecord::Base
	belongs_to :committee

	belongs_to :candidate
	
	belongs_to :district

	
	def self.last_expenditures(n=5)
		
		Expenditure.find(:all,:limit=>n,:include => [:candidate,:committee],:order => ' expenditure_date desc')		
	end
	
	def self.expenditures_by_district
	  Expenditure.sum(:expenditure_amount,:group => :district_id,:order => 'sum(expenditure_amount) desc' ).reject {|v| v[0] == 0 || v[0].nil?}.map { |v| [District.find(v[0]),v[1]] }
  end

  def self.largest_spenders(n=5)
    
    tv = Expenditure.sum(:expenditure_amount,:group => :committee_id,
      :order => "sum(expenditures.expenditure_amount) desc",:limit=>n)
    
    v = []
    
    tv.each do |t|
      v << [Committee.find(t[0]),t[1]]
    end
    
    v
  end
  
  def self.total_expenditures_by_candidate(n=5)
    Expenditure.sum(:expenditure_amount, :limit => n,:group => :candidate_id, :order => 'sum(expenditure_amount) desc',:conditions => 'candidate_id > 0').collect { |v| [Candidate.find(v[0]),v[1]]}    
  end
  
  def self.largest_districts(n=5)
    tv = Expenditure.sum(:expenditure_amount,:group => :district_id,
      :order => "sum(expenditures.expenditure_amount) desc",:limit=>n)
    v = []
    tv.each do |t|
      v << [District.find(t[0]),t[1]]
    end
    v    
  end
  
  def self.aggregate_spending_for(n=10)
    tv = Expenditure.sum(:expenditure_amount,:group => :expenditure_date,
      :order => "expenditures.expenditure_date desc",:limit=>n)
    v = {}
    tv.each do |t|
      v[t[0]] = {:amount => t[1]}
    end
    v
  end
  
  def self.expenditure_histogram_keys_ordered
    ["<$1000","<$10,000","<$50,000","<$100,000","<$250,000","<$500,000","<$1,000,000",">$1,000,000"]
  end
  
  def self.expenditure_histogram_by_district
    hist = {}
    expenditure_histogram_keys_ordered.each do |k|
      hist[k] = 0
    end
    
    result_hash =  ActiveRecord::Base.connection.execute("select sum(expenditure_amount) as 'amount', district_id from expenditures group by district_id order by sum(expenditure_amount) desc")
    result_hash.each_hash do |h|
      amount = h["amount"].to_i
      if amount < 1000 then
        hist["<$1000"] += 1
      elsif amount < 10000 then
        hist["<$10,000"] += 1        
      elsif amount < 50000 then
        hist["<$50,000"] += 1        
      elsif amount<100000 then
        hist["<$100,000"] += 1
      elsif amount < 250000 then
        hist["<$250,000"] += 1        
      elsif amount < 500000  then
        hist["<$500,000"] += 1
      elsif amount < 1000000 then
        hist["<$1,000,000"] += 1
      else 
        hist[">$1,000,000"] += 1
      end
    end
    
    hist
  end
  
  def self.expenditure_histogram_by_committee
    #hist = {"<$1000"=>0,"<$10,000"=>0,"<$50,000"=>0,"<$100,000" => 0, "<$250,000" => 0,"<$500,000" => 0,"<$1,000,000" => 0,">$1,000,000"=>0}
    hist = {}
   expenditure_histogram_keys_ordered.each do |k|
      hist[k] = 0
    end
    result_hash =  ActiveRecord::Base.connection.execute("select sum(expenditure_amount) as 'amount', committee_id from expenditures group by committee_id order by sum(expenditure_amount) desc")
    result_hash.each_hash do |h|
      amount = h["amount"].to_i
      if amount < 1000 then
        hist["<$1000"] += 1
      elsif amount < 10000 then
        hist["<$10,000"] += 1        
      elsif amount < 50000 then
        hist["<$50,000"] += 1        
      elsif amount<100000 then
        hist["<$100,000"] += 1
      elsif amount < 250000 then
        hist["<$250,000"] += 1        
      elsif amount < 500000  then
        hist["<$500,000"] += 1
      elsif amount < 1000000 then
        hist["<$1,000,000"] += 1
      else 
        hist[">$1,000,000"] += 1
      end
    end
    
    hist
  end
end
