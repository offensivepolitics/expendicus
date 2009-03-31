include TransAPI
class DistrictController < ApplicationController

	def index
    @expenditures_by_district_page = params[:expenditures_by_district_page]
    @expenditures_by_district_page ||= 1
    
    
    if (request.xhr?() == false || (request.xhr?()==true && params[:expenditures_by_district_page].nil? == false) )
      @expenditures_by_district = Expenditure.expenditures_by_district.paginate(:page => @expenditures_by_district_page,:per_page => 10)
    end
    
    @states = State.find(:all, :order => "name", :conditions => "states.name <> '' and states.abbreviation not in ('PR','GU','AS')").collect {|s| [s.name,s.id]}
    @states.insert(0,['Choose a state','0'])
    @districts = []
    
    respond_to do |format|
      format.html
      format.js do
        if params[:expenditures_by_district_page] != nil
          render :update do |page|            
            page.replace_html 'expenditures_by_district_table', :partial => 'expenditure_by_district_table', :object => @expenditures_by_district
          end
        end        
      end
    end
    

    
	end
	
	def search
    @results = []

    @results = Candidate.find(:all,:conditions => ["lastname like ?",'%' + params[:name] + '%'],:limit => 5)

    respond_to do |format|
      format.js { render :partial => 'home/search' } 
    end
  end
	
	def get_districts
	  if params[:id].nil? == false && params[:id] != "0" then
      @districts = State.find(params[:id]).districts.find(:all,:order => 'number').collect {|d| [d.number,d.id]}
    end
    respond_to do |format|
      format.js {render :layout => false    }
    end
  end
  
  def show
    @district = District.find(:first, :conditions => {:id => params[:id]},:include => [:state])

    redirect_to :action => "index" and return if @district.nil? == true
    @election = @district.find_election(2008,'G')
    @candidacies = []
    @total_votes_cast =0
    if @election.nil? == false
      if @election.candidacies.size >0
        @candidacies = @election.candidacies
        @total_votes_cast = @election.candidacies.sum(:votecount)
        @candidates_support_oppose = {}

        @election.candidacies.each do |candidacy|
          @candidates_support_oppose[candidacy.candidate_id] = {}
          @candidates_support_oppose[candidacy.candidate_id]["S"] = 0.0
          @candidates_support_oppose[candidacy.candidate_id]["O"] = 0.0

        end

        @r_hash = ActiveRecord::Base.connection.execute("select candidate_id,support_oppose, sum(expenditure_amount) as 'exp_sum' from expenditures where district_id = #{@district.id} group by candidate_id,support_oppose")
        @r_hash.each_hash { |v|
            #@candidates_support_oppose[v["candidate_id"]] ||= {}
            #@candidates_support_oppose[v["candidate_id"]]["S"] ||= 0.0
            #@candidates_support_oppose[v["candidate_id"]]["O"] ||= 0.0
            next if @candidates_support_oppose[v["candidate_id"].to_i].nil?
            #@candidates_support_oppose[v["candidate_id"]] ||= {}
            #@candidates_support_oppose[v["candidate_id"]]["S"] ||= 0
            #@candidates_support_oppose[v["candidate_id"]]["O"] ||= 0
            if v["candidate_id"].nil? == false && v["support_oppose"].nil? == false && v["exp_sum"].nil? == false
              @candidates_support_oppose[v["candidate_id"].to_i][v["support_oppose"]] = v["exp_sum"]
            end
          }


        @candidates_support_oppose||= Hash.new

        @youtube_search_terms = @election.candidates.collect { |c| "#{c.firstname} #{c.lastname}"}
        @youtube_search_terms << "#{@district.to_s}"
      end
    end
    
    @expenditures = @district.expenditures_as_array

    
    @expenditures_itemized_page = params[:expenditures_itemized_page]
    @expenditures_itemized_page ||= 1
    
    @pac_summary = @district.pac_summary
        
    @pac_summary_ofc_chart = open_flash_chart_object(360,300,url_for(:controller => 'district',:action => 'pac_summary_data',:id => @district.id),true,"#{ActionController::Base.relative_url_root}/")
    
    
    if (request.xhr?() == false || (request.xhr?() == true && params[:key].nil? == false)) then
      @expenditures_for_timeline = @district.expenditures_for_timeline
    end
    
    if (request.xhr?() == false || (request.xhr?()==true && params[:expenditures_itemized_page].nil? == false) )
      @expenditures = @district.expenditures.paginate(:page => @expenditures_itemized_page, :per_page => 10,:order => "expenditure_date desc")
    end    
    respond_to do |format|
      format.html
      format.js do
        if params[:expenditures_itemized_page] != nil
          render :update do |page|            
            page.replace_html 'expenditure_itemized_table', :partial => 'expenditure_itemized_table', :object => @expenditures
          end
        end
      end
      format.csv do
         key = params[:key]
          key ||= ""

          if key == "expenditures_itemized"
            @expenditures = @district.expenditures.find(:all,:order => "expenditure_date")

            csv_string = FasterCSV.generate do |csv|
              csv << ["district_state","distric_number","committee_name","committee_fecid","transaction_date",'candidate_name',"candidate_fecid",'candidate_party','candidate_state','candidate_district','support_oppose','amount','ytd']

              @expenditures.each do |ex|
                csv << [@distirct.state.abbreviation,@district.number,
                    ex.committee.name,ex.committee.fecid,ex.expenditure_date.to_s,(ex.candidate.nil? == false)?ex.candidate.name : "",(ex.candidate.nil? == false)?ex.candidate.fecid :  "",(ex.candidate.nil? == false)?ex.candidate.party : "",
                  (ex.district.nil? == false)?ex.district.state.abbreviation : "",
                  (ex.district.nil? == false)?ex.district.number : "",
                  ex.support_oppose,ex.expenditure_amount,ex.expenditure_ytd]
              end
            end 
            send_data csv_string,:type => 'text/csv;charset=iso-8859-1;header=present',
                    :disposition => "attachment;filename=#{@district.to_s.parameterize.to_s}-expenditures-2008.csv"        
          elsif key == "expenditures_by_committee"
            csv_string = FasterCSV.generate do |csv|
              csv << ["district_state","district_number","committee_name","committee_fecid","support_amount","oppose_amount"]
              @pac_summary.keys.sort.each do |key|
                c = Committee.find(key)
                csv << [@district.state.abbreviation,@district.number,
                    c.name, c.fecid,
                    @pac_summary[key]["S"],@pac_summary[key]["O"]]
              end
            end
            send_data csv_string,:type => 'text/csv;charset=iso-8859-1;header=present',
                    :disposition => "attachment;filename=#{@district.to_s.parameterize.to_s}-committee_summary-2008.csv"        
          elsif key == "timeline"
            csv_string = FasterCSV.generate do |csv|
              csv << ["district_state","district_number","date","amount"]
              @expenditures_for_timeline.each_item do |date,amount|
                csv << [@district.state.abbreviation,@district.number,
                    date,amount]
              end
            end
            send_data csv_string,:type => 'text/csv;charset=iso-8859-1;header=present',
                    :disposition => "attachment;filename=#{@district.to_s.parameterize.to_s}-timeline-2008.csv"        
            
          end
      end
    end
  end
  
  def pac_summary_data
    @district = District.find(params[:id],:include => [:state])  rescue nil
    @election = @district.find_election(2008,'G')
    @pac_summary = @district.pac_summary

    labels = []
    y_min = 0
    y_max = 0
    
    bar = BarStack.new
  
    bar.set_keys [
        {:colour => '#4D89F9',:text => 'Support',"font-size" => 12},
        {:colour => '#074AC5',:text => 'Oppose',"font-size" => 12}
    ]
    
    #C6D9FD
    bar.tooltip = '#x_label#: $#val#<br>Total: $#total#'
    #$bar_stack->set_tooltip( 'X label [#x_label#], Value [#val#]<br>Total [#total#]' );
  
    
    @pac_summary.keys.each do |k|
      cm= Committee.find(k)
      xl = XAxisLabel.new(cm.name.gsub(" ","\n"),'#000066', 0, 'horizontal')
      xl.visible = false
      labels << xl
      v = @pac_summary[k]['S'] + @pac_summary[k]['O']
      bv1 =BarStackValue.new(@pac_summary[k]['S'],'#4D89F9')
      bv1.set_key('Support',12)
      bv2 =BarStackValue.new(@pac_summary[k]['O'],'#074AC5')
      bv2.set_key('Oppose',12)
       
      bar.append_stack([bv1,bv2])
      if v > y_max
        y_max = v
      end
    end
    
  
    y = YAxis.new
    y.set_range(y_min,y_max + y_max*0.1,500000)
    
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
  
  def search_by_zipcode
    zipcode = params[:zipcode] 
    result = TransAPI::SunlightLabsAPI::districts_all_for_zip(zipcode)
    @results = []
    if result.is_a?(String)
      @error_string = result
    else
      search_results_head = result["response"]["districts"]
      if search_results_head.nil? == false
        search_results = search_results_head["district"]
        if search_results.is_a?(Hash) then
          search_results = [search_results]
        end
        search_results ||= []
        search_results.each do |result|
          state = State.find_by_abbreviation(result["state"])
          next if state.nil? == true
          district = state.find_district(result["number"].to_i)
          next if district.nil? == true
          @results << district
        end
      end
    end
    
    respond_to do |format|
      format.js do
        render :partial => 'district/search_by_district'
      end
    end
  end
  
end
  