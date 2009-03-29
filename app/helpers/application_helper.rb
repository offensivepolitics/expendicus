# Methods added to this helper will be available to all templates in the application.
require 'fastercsv'
module ApplicationHelper
  def ellipsiate(str,len=50)
    str.length > len ? str[0..len-3] + "..." : str
  end
  
  def CSVGenerator(header,items)
    csv_string = FasterCSV.generate(:force_quotes => true) do |csv|
      csv << header
      
      items.each do |item|
        csv << yield(item)
      end
    end
    return csv_string
  end
  
end
