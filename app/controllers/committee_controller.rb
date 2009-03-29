require 'fastercsv'

class CommitteeController < ApplicationController
  def index
    
    @big_spenders = Committee.big_spenders(5)
    @big_fundraisers = Committee.big_fundraisers(5)
    
  end
	
	def show
    @committee = Committee.find(:first, :conditions => {:id => params[:id]})
    redirect_to :action=>'index' and return if @committee.nil? == true

    #@expenditures = @committee.expenditures_as_array
    @financial_summary = nil
    if @committee.committee_designation == "PRINCIPAL CAMPAIGN COMMITTEE OF A CANDIDATE"
      @financial_summary = @committee.candidate.candidate_financial_summaries[0]
    else
      @financial_summary = @committee.committee_financial_summaries[0]
    end
    
    
    @expenditures_by_candidate_page = params[:expenditures_by_candidate_page]
    @expenditures_by_candidate_page ||= 1
    
    if (request.xhr?() == false || (request.xhr?()==true && params[:expenditures_by_candidate_page].nil? == false) )
      @expenditures = Expenditure.paginate(:page => @expenditures_by_candidate_page, :per_page => 10,:conditions => {:committee_id => @committee.id}, :order => "expenditure_date desc")
    end
    
    @expenditures_by_district_page = params[:expenditures_by_district_page]
    @expenditures_by_district_page ||= 1
  
    if (request.xhr?() == false || (request.xhr?()==true && params[:expenditures_by_district_page].nil? == false) )
      @expenditures_by_district = @committee.expenditures_by_district.paginate(:page => @expenditures_by_district_page,:per_page => 10)
    end
    
    if (request.xhr?() == false || (request.xhr?()==true && params[:key] == "timeline") )
      @expenditures_for_timeline = @committee.expenditures_for_timeline
    end
    
    @youtube_search_terms = [@committee.name]
    
    respond_to do |format|
      format.html
      format.js do
        if params[:expenditures_by_candidate_page] != nil
          render :update do |page|            
            page.replace_html 'expenditures_by_candidate_table', :partial => 'expenditure_by_candidate_table', :object => @expenditures
          end
        elsif params[:expenditures_by_district_page] != nil
          render :update do |page|            
            page.replace_html 'expenditures_by_district_table', :partial => 'expenditure_by_district_table', :object => @expenditures_by_district
          end
          
        end
      end
      format.csv do
        key = params[:key]
        key ||= ""
        
        if key == "candidate"
          @expenditures = @committee.expenditures.find(:all,:order => "expenditure_date")
          
          csv_string = FasterCSV.generate do |csv|
            csv << ["committee_name","committee_fecid","transaction_date",'candidate_name',"candidate_fecid",'candidate_party','candidate_state','candidate_district','support_oppose','amount','ytd']
            
            @expenditures.each do |ex|
              csv << [@committee.name,@committee.fecid,ex.expenditure_date.to_s,(ex.candidate.nil? == false)?ex.candidate.name : "",(ex.candidate.nil? == false)?ex.candidate.fecid :  "",(ex.candidate.nil? == false)?ex.candidate.party : "",
                (ex.district.nil? == false)?ex.district.state.abbreviation : "",
                (ex.district.nil? == false)?ex.district.number : "",
                ex.support_oppose,ex.expenditure_amount,ex.expenditure_ytd]
            end
          end 
          send_data csv_string,:type => 'text/csv;charset=iso-8859-1;header=present',
                  :disposition => "attachment;filename=#{@committee.name.parameterize.to_s}-expenditures-2008.csv"
        elsif key == "district"
          @expenditures_by_district = @committee.expenditures_by_district
          csv_string = FasterCSV.generate(:force_quotes => true) do |csv|
            csv << ["committee_name","committee_fecid","state","district","amount"]
            @expenditures_by_district.each do |ex|
              csv << [@committee.name,@committee.fecid,ex[0].state.abbreviation,ex[0].number,ex[1]]
            end
          end
          send_data csv_string,:type => 'text/csv;charset=iso-8859-1;header=present',
                  :disposition => "attachment;filename=#{@committee.name.parameterize.to_s}-expenditures-districts-2008.csv"
        elsif key == "timeline"
          csv_string = FasterCSV.generate(:force_quotes => true) do |csv|
            csv << ["committee_name","committee_fecid","date", "amount"]
            @expenditures_for_timeline.keys.each do |ex_key|
              csv << [@committee.name,@committee.fecid,ex_key,currency_formatted(@expenditures_for_timeline[ex_key][:amount])]
            end
          end
          send_data csv_string,:type => 'text/csv;charset=iso-8859-1;header=present',
                  :disposition => "attachment;filename=#{@committee.name.parameterize.to_s}-expenditures-timeline-2008.csv"            
        else
          redirect_to committee_path(@committee)
        end
        
      end
    end
    
    #@districts_expenditures_scaled = @committee.expenditures_scaled(64)
    
    #@map = GMap.new("map_div")
    #@map.control_init(:large_map => true, :map_type => true)
    #@map.center_zoom_init([33, -87],6)
    
    #@polydata = []
    
    #@districts_expenditures_scaled.keys.each do |district|
    #  val = @districts_expenditures_scaled[district]
    #  district_record = District.find(district)
      
    #  color = "#0000#{(191+val).to_s(16)}"
    #  next if district == 228
    #  @polydata << [district_record.district_polygon.encoded_points,district_record.district_polygon.num_levels,
    #    district_record.district_polygon.levels,district_record.district_polygon.zoom_factor,color]
      #poly = GPolygon.from_georuby(district_record.district_polygon.geometry[0],"#ff0000",0,0.0,color,0.6)
      
    #end
    #@polydata = @polydata[0...3]
    #ol = GeoRssOverlay.new("http://localhost:3000/AZ-8.kml")
    #"http://localhost:3000/AZ-8.kml",:proxy => 'http://localhost:3000/AZ-8.kml')
    #@map.add_overlay(ol)
    
  end
  
  def search
    
    @results = []
    
    @results += Committee.find(:all,:conditions => ["name like ?",'%' + params[:name] + '%'],:limit => 5)
    
    respond_to do |format|
      format.js { render :partial => 'home/search' } 
    end
  end  
  

end
