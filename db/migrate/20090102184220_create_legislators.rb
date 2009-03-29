class CreateLegislators < ActiveRecord::Migration
  def self.up
    create_table :legislators do |t|
      t.string :title
      t.string :firstname
      t.string :lastname
      t.integer :state_id
      t.integer :candidate_id
      t.integer :district_id
      t.string :gender
      t.string :bioguide_id
      t.string :votesmart_id
      t.integer :govtrack_id
      t.string :crp_id
      
      t.string :youtube_url
      t.string :rss_url
      t.string :congresspedia_url
      
      t.string :phone
      t.string :fax
      t.string :website
      

      t.timestamps
    end
  end

  def self.down
    drop_table :legislators
  end
end
