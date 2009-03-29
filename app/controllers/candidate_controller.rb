include TransAPI
require 'open_flash_chart'
include OpenFlashChart

class CandidateController < ApplicationController

	def index
	  
	  @expenditures_by_candidate = Expenditure.total_expenditures_by_candidate(5)
	  @expenditures_historgram_data = Expenditure.expenditure_histogram_by_district
    @expenditures_histogram_keys = Expenditure.expenditure_histogram_keys_ordered
    @expenditures_historgram_chart = open_flash_chart_object(360,300,url_for(:controller => :candidate, :action => "expenditures_by_district"))
	  
	end
	
	def expenditures_by_district
	  @expenditures_historgram_data = Expenditure.expenditure_histogram_by_district
    @expenditures_histogram_keys = Expenditure.expenditure_histogram_keys_ordered

      labels = []
      y_min = 0
      y_max = 0

      bar = BarFilled.new('#4D89F9')
    
      #C6D9FD
      bar.tooltip = 'Count: #val#'
      #$bar_stack->set_tooltip( 'X label [#x_label#], Value [#val#]<br>Total [#total#]' );


      values = []
       @expenditures_histogram_keys.each do |k|
        xl = XAxisLabel.new(k,'#000066', 8, 'vertical')
        xl.visible = true
        labels << xl
        v = @expenditures_historgram_data[k]
        #bv1 =BarFilledValue.new(v)
        #bar.data << bv1
        values << v
        if v > y_max
          y_max = v
        end
      end

      bar.set_values(values)
      y = YAxis.new
      y.set_range(y_min,y_max + y_max*0.1,500000)
      y.set_steps(10)
      x = XAxis.new
      x_labels = XAxisLabels.new
      x_labels.labels = labels 

      x.labels = labels

      tooltip = Tooltip.new
      tooltip.set_hover

      chart = OpenFlashChart.new
      chart.bg_colour = '#fafafa'
      chart.y_axis = y
      chart.x_axis = x
      chart.add_element(bar)
      chart.tooltip = tooltip

      render :text => chart.to_s    
  end

	def show
	  @candidate = Candidate.find(:first, :conditions => {:id => params[:id]}) 
	  redirect_to url_for :controller => 'candiate', :action => 'index' and return if @candidate.nil? == true
    
    if @candidate.candidate_financial_summaries.size > 0 then
      @financial_summary = @candidate.candidate_financial_summaries[0]
    end
    @financial_summary ||= nil

    @district = @candidate.district_for(2008)
    @election = @district.find_election(2008,'G')
    
    @youtube_search_terms = @election.candidates.collect { |c| "#{c.firstname} #{c.lastname}"}
    @youtube_search_terms << "#{@district.to_s}"    
    
    @expenditures_by_candidate_page = params[:expenditures_by_candidate_page]
    @expenditures_by_candidate_page ||= 1

    if (request.xhr?() == false || (request.xhr?()==true && params[:expenditures_by_candidate_page].nil? == false) )
      @expenditures = Expenditure.paginate(:page => @expenditures_by_candidate_page, :per_page => 10,:conditions => {:candidate_id => @candidate.id}, :order => "expenditure_date desc")
    end    
    
    if (request.xhr?() == false && @candidate.crpid != '')
      v = OpenSecretsAPI::candidate_industries({:cid => @candidate.crpid})
      if v.is_a?(String)
        @industry_contributions = v
      else
        @industry_contributions = v["response"]
      end
      
      v = OpenSecretsAPI::candidate_contributors({:cid => @candidate.crpid})
      if v.is_a?(String)
        @org_contributions = v
      else
        @org_contributions = v["response"]
      end
    end
    @industry_contributions ||= nil
    @org_contributions ||= nil
    
    respond_to do |format|
      format.html
      format.js do
        if params[:expenditures_by_candidate_page] != nil then
          render :update do |page|            
            page.replace_html 'expenditures_by_candidate_table', :partial => 'expenditure_by_candidate_table', :object => @expenditures
          end
        end
      end    
      format.csv do
        if params[:key] == "itemized" then
          @expenditures = @candidate.expenditures.find(:all,:order => "expenditure_date")

          csv_string = FasterCSV.generate do |csv|
            csv << ["committee_name","committee_fecid","transaction_date",'candidate_name',"candidate_fecid",'candidate_party','candidate_state','candidate_district','support_oppose','amount','ytd']

            @expenditures.each do |ex|
              csv << [ex.committee.name,ex.committee.fecid,ex.expenditure_date.to_s,(ex.candidate.nil? == false)?ex.candidate.name : "",(ex.candidate.nil? == false)?ex.candidate.fecid :  "",(ex.candidate.nil? == false)?ex.candidate.party : "",
                (ex.district.nil? == false)?ex.district.state.abbreviation : "",
                (ex.district.nil? == false)?ex.district.number : "",
                ex.support_oppose,ex.expenditure_amount,ex.expenditure_ytd]
            end
          end 
          send_data csv_string,:type => 'text/csv;charset=iso-8859-1;header=present',
                  :disposition => "attachment;filename=#{@candidate.lastname.parameterize.to_s}-expenditures-2008.csv"        
        end
      end
    end
	end
	
	def search
     @results = []

      @results = Candidate.find(:all,:conditions => ["lastname like ?",'%' + params[:name] + '%'],:limit => 5)

      respond_to do |format|
        format.js { render :partial => 'home/search',:locals => {:render_as_candidate => true} } 
      end	  
  end

end
