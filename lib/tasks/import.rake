require 'date'
require 'rubygems'
require "fastercsv"
require "ar-extensions"
require 'geo_ruby'

require 'lib/gmap_polyline_encoder.rb'

include GeoRuby::Shp4r

namespace :import do 

	desc 'load political parties'
	task :parties => :environment do 
	
		clear_model(PoliticalParty)

		items = []
		cols = [:name,:abbreviation]

		FasterCSV.open("#{dev_data_path}/parties.csv","r").each do |line|
			items << [line[1],line[2]]
		end

		print "about to import #{items.size} party objects..."
		PoliticalParty.import(cols,items,:validate=>false)
		puts "done."


	end

	desc 'load end of cycle financial summaries'
	task :candidate_financial_summaries => :environment do 
    clear_model(CandidateFinancialSummary)

    candidates = {}
    Candidate.find(:all).each do |c|
     candidates[c.fecid] = c.id
    end

    items = []
    cols = [:candidate_id,
      :year,
      :total_receipts,
      :total_disbursments,
      :beginning_coh,
      :ending_coh,
      :authorized_transfers_from,
      :authorized_transfers_to,
      :contributions_from_candidate,
      :loans_from_candidate,
      :other_loans,
      :candidate_loan_repayments,
      :other_loan_repayments,
      :debts_owed_by,
      :total_individual_contributions,
      :total_pac_contributions,
      :total_party_contributions,
      :individual_refunds,
      :committee_refunds]

    FasterCSV.open("#{dev_data_path}/candidate-summaries-2008.csv","r").each do |line|
      candidate_id = candidates[line[0]]
      arr = [candidate_id]
      line[1..-1].each do |subitem|
        arr << subitem
      end

      items << arr
    end

    print "about to import #{items.size} candidates..."
    CandidateFinancialSummary.import(cols,items,:validate=>false)
    puts "done."	
	end
	
	desc 'load candidates' 
	task :candidates => :environment do 
		
		clear_model(Candidate)
		clear_model(Candidacy)

		parties = cache_parties

		unknown_party_id = parties['UNK']

		items = []
		cols = [:fecid,:fullname,:firstname,:lastname,:political_party_id,:crpid,:govtrackid,:bioguideid,:votesmartid]

		FasterCSV.open("#{dev_data_path}/candidates-2008.csv","r").each do |line|			
			party_id = parties[line[4].upcase]
			party_id ||= unknown_party_id
			items << [line[0],line[1],line[2],line[3],party_id,line[6],line[7],line[8],line[9]]
		end	

		print "about to import #{items.size} candidates..."
		Candidate.import(cols,items,:validate=>false)
		puts "done."

		candidates = {}
		Candidate.find(:all).each do |c|
			candidates[c.fecid] = c.id
		end

		items = []
		cols = [:election_id,:candidate_id,:winner,:votecount]

		FasterCSV.open("#{dev_data_path}/candidacies-2008.csv","r",:headers => true).each do |line|			

			candidate_id = candidates[line["fecid"]]

			if candidate_id.nil? then
				puts "null candidate id on #{line['fecid']}"
				next
			end

			election_id = State.find_by_abbreviation(line["state"]).find_district(line["district"]).find_election(2008,'G')
			winner = line["winner"]
			votecount = line["votecount"]
			
			items << [election_id,candidate_id,winner,votecount]

		end

		print "about to import #{items.size} candidacy objects..."
		Candidacy.import(cols,items,:validate=>false)
		puts "done."


	end

	desc 'load elections'
	task :elections => :environment do 
		
		clear_model(Election)

		FasterCSV.open("#{dev_data_path}/candidacies-2008.csv","r",:headers=>true).each do |line|
		
			year = line[0]
			state = State.find_by_abbreviation(line[1])
			if state.nil? then
				puts "we got a nil state for #{line[1]}"
				next
			end
			district = state.find_district(line[3])
			
			election = Election.find_or_create_by_district_id_and_election_type_and_year(district.id,'G',year)

			election.save!
			
		end

	end

	desc 'load states' 
	task :states => :environment do 
		clear_model(State)

		items = []

		columns = [:name,:abbreviation,:fipscode]

		FasterCSV.open("#{dev_data_path}/states.csv","r").each do |line|
			items << [line[1],line[2],line[3]]
		end

		print "about to import #{items.size} states..."
		State.import(columns,items,:validate=>false)
		puts "done."

	end

	desc 'load districts'
	task :districts => :environment do 
		clear_model(District)

		states = {}
		State.find(:all).each do |state|
			states[state.fipscode.to_s] = state.id
		end

		columns = []

		items = [:district_name,:number,:usecode,:state_id]

		FasterCSV.open("#{dev_data_path}/districts.csv","r").each do |line|
			state_id = states[line[0].to_s]
			usecode = ''
			if line[3]!= nil then
				usecode = line[3]
			end

			dist = District.create(:name => line[1], :number => line[2].to_i, :usecode=>usecode , :state_id => state_id)
      
      dist.save!
		end


	end

	desc 'Load Legislaators'
	task :legislators => :environment do 
		clear_model(Legislator)

    # cache candidates
    candidates = {}
    Candidate.find(:all).each do |candidate|
      candidates[candidate.fecid] = candidates.id
    end

		items = []
    columns = [ :title,:firstname,:lastname,:candidate_id,:state_id,:district_id,:gender,:bioguide_id,:votesmart_id,:govtrack_id,:crp_id,:youtube_url,:rss_url,:congresspedia_url,:phone,:fax,:website]
    FasterCSV.open(File.join(dev_data_path,'apidata.csv'),"r",:headers => true).each do |line|
      next if line["title"] == "Sen"
      next if line["state"] == "PR"
      state = State.find_by_abbreviation(line["state"])
      
      district = state.find_district(line["district"])
      next if district.nil? == true 
      candidate_id = candidates[line["fec_id"]]

      items << [line["title"],line["firstname"],line["lastname"],candidate_id,state.id,district.id,
          line["gender"],line["bioguide_id"],line["votesmart_id"],line["govtrack_id"],line["crp_id"],
          line["youtube_url"],line["rss_url"],line["congresspedia_url"],line["phone"],line["fax"],line["website"]]
      
      #items << [line["title"],line["firstname"],line["lastname"],candidate_id,state.id,district.id,
      #  line["gender"],line["bioguide_id"],line["votesmart_id"],line["govtrack_id"],line["crp_id"],
      #  line["youtube_url"],line["rss_url"],line["congresspedia_url"],line["phone"],line["fax"],line["website"] ]
    end

	  print "about to import #{items.size} legislators..."
  	Legislator.import(columns,items,:validate=>false)
  	puts "done."

	end
	
	desc 'load committee financial summaries' 
	task :committee_financial_summaries => :environment do
	 
    clear_model(CommitteeFinancialSummary)

    items = []

    columns = [:committee_id,
              :total_receipts,:transfers_from_affiliates,:contributions_from_individuals,:contributions_from_other_committees,
              :total_loans_received,:total_disbursements,:transfers_to_affiliates,:refunds_to_individuals,:refunds_to_other_committees,
              :loan_repayments,:cash_on_hand_beginning_of_year,:cash_on_hand_close_of_period,:debts_owed_by,:nonfederal_transfers_received,
              :contributions_to_other_committees,:independent_expenditures,:party_coordinated_expenditures,:nonfederal_share_of_expenditures,
              :date_through
              ]

    committees = {}
    # cache committees
    Committee.find(:all).each do |cm|
      committees[cm.fecid] = cm.id
    end

    FasterCSV.open("#{dev_data_path}/committee-summaries-2008.csv","r").each do |item|
      committee_id = committees[item[0]]
      committee_id ||= -1
      arr = [committee_id]
      item[1..-1].each do |subitem|
				arr << subitem
			end
			items << arr
    end
    
    puts "about to import #{items.size} committee financial summaries"
    CommitteeFinancialSummary.import(columns,items,:validate => false)
    puts "done."
	 
	end

	desc 'Load Committees'
	task :committees => :environment do 
		clear_model(Committee)

		items = []

		columns = [:fecid,:name,:connected_org_name,:interest_group_category,:committee_designation]
   
		columns = [:fecid,:name,:committee_designation,:connected_org_name,:interest_group_category,:committee_type,:political_party_id,:candidate_id]

		candidates = {}
		Candidate.find(:all).each do |candidate|
			candidates[candidate.fecid] = candidate.id
		end

		parties = cache_parties

		FasterCSV.open(File.join(dev_data_path,'committees-2008.csv'),'r',:headers=>true).each do |line|			
			candidate_id = candidates[line["CANDIDATE_FECID"]]
			candidate_id ||= -1

			party_id = parties[line["PARTY"]]
			party_id ||= parties['UNK']

			items << [line["FECID"],line["NAME"],line["DESIGNATION"],line["ORGNAME"],line["CATEGORY"],line["TYPE"],party_id,candidate_id]
		end

		print "about to import #{items.size} committees..."
		Committee.import(columns,items,:validate=>false)
		puts "done."

	end

	desc 'load transaction types'
	task :transaction_types => :environment do 
		clear_model(TransactionType)
    columns = [:code, :name]
    
    values = [
      ['10','RECEIPT--EXEMPT FROM LIMITS'],
      ['11','TRIBAL CONTRIBUTION'],
      ['15','CONTRIBUTION'],
      ['15C','CONTRIBUTION FROM CANDIDATE'],
      ['15E','EARMARKED CONTRIBUTION'],
      ['15F','LOANS FORGIVEN BY CANDIDATE'],
      ['15I','EARMARKED INTERMEDIARY IN'],
      ['15J','MEMO(FILERS % OF CONTRB GIVEN TO JT FR)'],
      ['15P','PROCESSING ERROR'],
      ['15T','EARMARKED INTERMEDIARY TREASURY IN'],
      ['15Z','IN-KIND CONTR RECVD FROM REG. FILER'],
      ['16C','LOANS RECEIVED FROM THE CANDIDATE'],
      ['16F','LOANS RECEIVED FROM BANKS'],
      ['16G','LOAN FROM INDIVIDUAL'],
      ['16H','LOAN FROM CANDIDATE/COMMITTEE'],
      ['16J','LOAN REP FROM INDIVIDUAL'],
      ['16K','LOAN REP FROM CANDIDATE/COMMITTEE'],
      ['16L','LOAN REP RECVD FROM UNREG. ENTITY'],
      ['16R','LOANS RECEIVED FROM REG FILERS'],
      ['16U','LOAN RECVD FROM UNREG. ENTITY'],
      ['17R','CONTR REF RCVD FROM REG FILER'],
      ['17U','REF/REB/RET RECVD FROM UNREG. ENTITY'],
      ['17Y','REF/REB/RET FROM INDIVIDUAL/CORPORATION'],
      ['17Z','REF/REB/RET FROM CANDIDATE/COMMITTEE'],
      ['18G','TRANSFER IN AFFILIATED'],
      ['18H','HONORARIUM RECEIVED'],
      ['18J','MEMO(FILERS % OF CONTRB GIVEN TO JT FR)'],
      ['18K','CONTRIBUTION RECVD FROM REG FILER'],
      ['18S','RECEIPTS FROM SEC OF STATE'],
      ['18U','CONTRIBUTION RECVD FROM UNREG.'],
      ['19','ELECTIONEERING DONATIONS RECEIVED'],
      ['20','DISBURSEMENT - EXEMPT FROM LIMITS'],
      ['20C','LOAN REPAYMENTS MADE TO CANDIDATE'],
      ['20F','LOAN REPAYMENTS MADE TO BANKS'],
      ['20G','LOAN REPAYMENTS MADE TO INDIVIDUAL'],
      ['20R','LOAN REPAYMENTS MADE TO REG FILER'],
      ['22G','LOAN TO INDIVIDUAL'],
      ['22H','LOAN TO CANDIDATE/COMMITTEE'],
      ['22J','LOAN REP TO INDIVIDUAL'],
      ['22K','LOAN REP TO CANDIDATE/COMMITTEE'],
      ['22L','LOAN REP TO BANK'],
      ['22R','CONTRIB REFUND TO UNREG. ENTITY'],
      ['22U','LOAN REPAID TO UNREGISTERED ENTITY'],
      ['22X','LOAN MADE TO UNREGISTERED ENTITY'],
      ['22Y','CONTRIBUTION REF TO INDIVIDUAL'],
      ['22Z','CONTRIBUTION REF TO CANDIDATE/COMMITTEE'],
      ['24A','INDEPENDENT EXPENDITURE AGAINST'],
      ['24C','COORDINATED EXPENDITURE'],
      ['24E','INDEPENDENT EXPENDITURE FOR'],
      ['24F','COMMUN COST FOR CANDIDATE (C7)'],
      ['24G','TRANSFER OUT AFFILIATED'],
      ['24H','HONORARIUM TO CANDIDATE'],
      ['24I','EARMARKED INTERMEDIARY OUT'],
      ['24K','CONTRIBUTION MADE TO NON-AFFILIATED'],
      ['24N','COMMUN COST AGAINST CANDIDATE (C7)'],
      ['24P','CONTRIB MADE TO POSSIBLE CANDIDATE'],
      ['24R','ELECTION RECOUNT DISBURSEMENT'],
      ['24T','EARMARKED INTERMEDIARY TREASURY OUT'],
      ['24U','CONTRIBUTION MADE TO UNREGISTERED'],
      ['24Z','IN-KIND CONTRIB MADE TO REG. FILER'],
      ['29','ELECTIONEERING DISBURSEMENT']
    ]

		print "about to import #{values.size} transaction types..."
		TransactionType.import(columns,values,:validate=>false)
		puts "done"
	end

	desc 'load committee transactions' 
	task :committee_transactions => :environment do 
		clear_model(CommitteeTransaction)

		items = []

		columns = [:committee_id,:candidate_id,:transaction_date,:amount,:transaction_type_id]

		transtypes = {}
		TransactionType.find(:all).each do |tt|
			transtypes[tt.code] = tt.id
		end

		candidates = {}
		Candidate.find(:all).each do |candidate|
			candidates[candidate.fecid] = candidate.id
		end
		
		committees = {}
		Committee.find(:all).each do |committee|
			committees[committee.fecid] = committee.id
		end

		FasterCSV.open("#{dev_data_path}/pas2-2008.csv","r",:headers=>true).each do |line|
			candidate_id = candidates[line["CANDIDATEID"]]
			next if candidate_id.nil?

			committee_id = committees[line["COMMITTEEID"]]
			next if committee_id.nil?

			transaction_type_id = transtypes[line["TRANSTYPE"]]

			items << [committee_id,candidate_id,line["TRANSDATE"],line["TRANSAMOUNT"],transaction_type_id]

			if items.size > 5000 then
				print "about to import #{items.size} committee transactions..."
				CommitteeTransaction.import(columns,items,:validate=>false)
				puts "done."
				items = []
			end
		
		end

		if items.size > 0
			print "about to import #{items.size} committee transactions..."
			CommitteeTransaction.import(columns,items,:validate=>false)
			puts "done."
		end

#ALTER TABLE `inex_development`.`committee_transactions` ADD INDEX `ix_committee_id`(`committee_id`),
# ADD INDEX `ix_candidate_id`(`candidate_id`);		

	end

	desc 'load independent expenditures'
	task :independent_expenditures => :environment do 
		clear_model(Expenditure)

		items = []

		columns = [:schedule,:committee_id,:election_code,:expenditure_date,:expenditure_amount,:expenditure_ytd,:expenditure_purpose_code,:category_code,:payee_fecid,:support_oppose,:candidate_id,:district_id]

		puts "caching objects"

		candidates = {}
		Candidate.find(:all).each do |candidate|
			candidates[candidate.fecid] = candidate.id
		end

		committees = {}
		Committee.find(:all).each do |committee|
			committees[committee.fecid] = committee.id
		end
		
		puts "done."

		FasterCSV.open(File.join(dev_data_path,'electronic_f24_se_2008.csv'),'r',:headers=>true).each do |line|
			committee_id = committees[line[1]]
			candidate_id = candidates[line[10]]
			candidate_id ||= -1
			
			next if line["CANDIDATE_OFFICE"] != 'H' || line["CANDIDATE_FECID"][0...1] != 'H'

      district_id = 0

      if candidate_id != -1
        state = line["CANDIDATE_STATE"]
        district = line["CANDIDATE_DISTRICT"]
        
        if district != "" 
          if state == 'AK' && district == "01"
            district = "0"
          end
          
          if (district == "00" || district  == "") && (state != 'AK' && state!= 'WY' && state!= "ND" && state!='SD' && state!= 'HI')
            district = Candidate.find(candidate_id).candidacies[0].election.district.number
          end
        end
        
        district_id = State.find_by_abbreviation(state).find_district(district)
      end

			items << [line[0],committee_id,line[2],line[3],line[4],line[5],line[6],line[7],line[8],line[9],candidate_id,district_id]

			if items.size > 500
				print "about to import #{items.size} expenditure objects."
				Expenditure.import(columns,items,:validate=>false)
				puts "done."
				items = []				
			end
		end
		
		if items.size > 0
			print "about to import #{items.size} expenditure objects."
			Expenditure.import(columns,items,:validate=>false)
			puts "done."
			items = []				
		end


	end

  desc 'state and district shapefiles'
	task :shapefiles => :environment do 
    clear_model(GenericPolygon)
    clear_model(StatePolygon)
    clear_model(DistrictPolygon)

    ShpFile.open("#{dev_data_path}/shapes/st99_d00") do |shp|
      shp.each do |shape|
        state_fips = shape.data['STATE']
        state = State.find_by_fipscode(state_fips)
  				next if state.abbreviation == 'PR'

        print "#{state.abbreviation}."

				
        poly = StatePolygon.create(:geometry => shape.geometry, :state_id => state.id,:district_id => nil)
        poly.save!
        print "."        
      end
    end

		ShpFile.open("#{dev_data_path}/shapes/cd99_110-polygons-ms1") do |shp|
      shp.each do |shape|
      state_fips = shape.data['STATE']
      
      state = State.find_by_fipscode(state_fips)
      
      
      
      district_name = shape.data['name']
      district_number = shape.data['CD']

      if state.abbreviation == 'DC' then
        district_number = '0'
      end

      district = state.find_district(district_number)
      if district != nil then
        
        print "#{state.abbreviation}-#{district_number}."
        zoom_factor = 2
        num_levels = 12
        pts = shape.geometry[0][0].points.collect { |pt| [pt.y,pt.x]}
        encoder = GMapPolylineEncoder.new(:zoomfactor => zoom_factor, :numlevels => num_levels)
        result = encoder.encode(pts)
        poly = GenericPolygon.create(:geometry => shape.geometry, :district_id => district.id,:state_id => nil,
          :encoded_points => result[:points],:levels => result[:levels],:zoom_factor => zoom_factor,:num_levels => num_levels)
          
        poly.save
      else 
        print "skip #{state.abbreviation}-#{district_number}."
      end
    end
    end
		
	end
	
	

	desc 'load all'
	task :all => [:environment, :states,:districts,:parties, :elections, :candidates, :candidate_financial_summaries, :committees,:committee_financial_summaries,:independent_expenditures,:transaction_types,:shapefiles]

  def clear_model(model_class)
    execute "truncate table #{model_class.table_name} "
    execute "alter table #{model_class.table_name} auto_increment = 0"
  end
  
  def milliseconds_to_time(milliseconds)
    Time.at(milliseconds)
  end
  
  def execute(cmd)
    ActiveRecord::Base.connection.execute cmd
  end
  
  def dev_data_path
    File.join(File.dirname(__FILE__),"../../dev_data")
  end 

  def cache_parties
    parties = {}
    PoliticalParty.find(:all).each {|p|
      if p.abbreviation != nil then
        parties[p.abbreviation] = p.id
      end
    }

    parties['RE['] = parties['REP']
    parties['R'] = parties['REP']
    parties['GOP'] = parties['REP']
    parties['GRN'] = parties['GRE']
    parties['GR'] = parties['GRE']
    parties['CON'] = parties['CST']
    parties['NA'] = parties['NNE']
    parties['0'] = parties['UNK']
    parties['1'] = parties['UNK']
    parties['NON'] = parties['UNK']

    parties['D'] = parties['DEM']
    parties['LBR'] = parties['LAB']
    parties['RFM'] = parties['REF']
    parties['INP'] = parties['IND']

    parties
  end  


end

