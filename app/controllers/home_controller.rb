class HomeController < ApplicationController

  #auto_complete_for :committee, :name

  layout proc { |controller| controller.request.xhr? ? nil : 'application' }
  
	def index
		#@map = GMap.new("map_div")
		#@map.control_init(:large_map => true,:map_type => true)
		#@map.center_zoom_init([37.0625,-95.677068],4)
		
		
		#@last_expenditures = Expenditure.last_expenditures(5)

    @big_spenders = Expenditure.largest_spenders(5)
    
    @largest_districts = Expenditure.largest_districts(5)
    
    @party_pacs = [11,486,399,262].map {|id| Committee.find(id)}
    #@spending_for_last_30_days = Expenditure.aggregate_spending_for(30)
    
  
		#sp = State.find(2).find_district(0).district_polygon
		#@polygon = GPolygon.from_georuby(sp.geometry[0],"#000000",0,0.0,"#ff0000",0.6)	
    #@center = GLatLng.from_georuby(sp.geometry.envelope.center)
    #@zoom = @map.get_bounds_zoom_level(GLatLngBounds.from_georuby(sp.geometry.envelope))
		#@map.clear_overlays
		#@map.overlay_init(@polygon)
		#@map.center_zoom_init(@center,@zoom)

	end

  def search
    
    @results = []
    
    @results += Committee.find(:all,:conditions => ["name like ? and committee_designation <> 'PRINCIPAL CAMPAIGN COMMITTEE OF A CANDIDATE'",'%' + params[:name] + '%'],:limit => 5)
    @results += Candidate.find(:all,:conditions => ["lastname like ?",'%' + params[:name] + '%'],:limit => 5)
    
    respond_to do |format|
      format.js { render :partial => 'search',:layout => false}
    end
  end
	
end
