require "rubygems"
require "httparty"

module TransAPI

  class BaseAPI
  	include HTTParty
  	@@API_KEY = nil

  	def self.api_key=(key)
  		@@API_KEY = key
  	end

  	def self.api_key
  		@@API_KEY
  	end

  end

  class OpenSecretsAPI < BaseAPI
  	API_BASE_URL = "http://www.opensecrets.org/api/?"
	
  	{:candidate_summary => 'candSummary', :candidate_contributors => 'candContrib',
  	 :candidate_industries => 'candIndustry',:candidate_sectors => 'candSector'
   	}.each_pair do |method_name,http_method|
  		(class <<self; self; end).send :define_method, method_name.to_sym do |*args|
  			args = args.first || Hash.new
  			base_get(http_method,args)
  		end
  	end

  	private 
  	def self.base_get(method, args)
  		get(API_BASE_URL ,:query => { :method => method,:apikey => @@API_KEY,:output => :xml, :cycle => 2008}.merge(args))
  	end

  end

  class SunlightLabsAPI
  	include HTTParty
  	@@API_KEY = nil
  	API_BASE_URL = "http://services.sunlightlabs.com/api/"

  	def self.api_key=(key)
  		@@API_KEY = key
  	end

  	def self.api_key
  		@@API_KEY
  	end

  	def self.legislators_all_for_zip(zipcode,format='xml')
  		get("#{API_BASE_URL}legislators.allForZip.#{format}",:query => {"apikey"=>@@API_KEY, :zip => zipcode})
  	end

  end

  def somecrap(*args)
  	puts args[0]
  end
end
#OpenSecretsAPI::api_key = "6be3831022c998769a69db71f6f5f338"
#SunlightLabsAPI::api_key = "de2223c4280719f57f9408c4c409eb9f"

#puts OpenSecretsAPI.candidate_summary(:cid => 'N00027829').inspect
# 'Invalid CID'
#puts OpenSecretsAPI::candidate_contributors_3('N00027829').inspect
#puts OpenSecrets.candidate_sectors('N00027829').inspect
#puts SunlightLabs::legislators_all_for_zip("20005").inspect
		