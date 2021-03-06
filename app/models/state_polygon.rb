# == Schema Information
# Schema version: 20090225132948
#
# Table name: generic_polygons
#
#  id          :integer(4)      not null, primary key
#  name        :string(255)
#  geometry    :geometry        not null
#  district_id :integer(4)
#  state_id    :integer(4)
#  created_at  :datetime
#  updated_at  :datetime
#

class StatePolygon < GenericPolygon

	belongs_to :state, :foreign_key => 'state_id'


end
