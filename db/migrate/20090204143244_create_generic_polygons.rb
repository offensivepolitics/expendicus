class CreateGenericPolygons < ActiveRecord::Migration
  def self.up
    create_table :generic_polygons, :options => 'engine=MyISAM', :force=>true do |t|
      t.string :name
      t.column :geometry, :multi_polygon ,:null => false
      t.integer :district_id
			t.integer :state_id
      t.string :encoded_points
      t.string :levels
      t.integer :zoom_factor
      t.integer :num_levels
      
      t.timestamps
    end

		add_index :generic_polygons, :geometry, :spatial => true 
  end

  def self.down
    drop_table :generic_polygons
  end
end
