<% if @districts.nil? == false %>
	<label>District:</label>
	<select id="district_select">
	<% @districts.each do |district| %>
	  <option value="<%=district[1]%>"><%=district[0]%></option>
	<% end%>
	<end> 
	</select>
	<a href="#" onclick="goToDistrict();">Go</a>
<% end %>