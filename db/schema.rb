# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20090225132948) do

  create_table "candidacies", :options=>'ENGINE=MyISAM', :force => true do |t|
    t.column "election_id", :integer
    t.column "candidate_id", :integer
    t.column "winner", :integer
    t.column "votecount", :integer
    t.column "created_at", :datetime
    t.column "updated_at", :datetime
  end

  create_table "candidate_financial_summaries", :options=>'ENGINE=MyISAM', :force => true do |t|
    t.column "candidate_id", :integer
    t.column "year", :integer
    t.column "total_receipts", :integer
    t.column "total_disbursments", :integer
    t.column "beginning_coh", :integer
    t.column "ending_coh", :integer
    t.column "authorized_transfers_from", :integer
    t.column "authorized_transfers_to", :integer
    t.column "contributions_from_candidate", :integer
    t.column "loans_from_candidate", :integer
    t.column "other_loans", :integer
    t.column "candidate_loan_repayments", :integer
    t.column "other_loan_repayments", :integer
    t.column "debts_owed_by", :integer
    t.column "total_individual_contributions", :integer
    t.column "total_pac_contributions", :integer
    t.column "total_party_contributions", :integer
    t.column "individual_refunds", :integer
    t.column "committee_refunds", :integer
    t.column "created_at", :datetime
    t.column "updated_at", :datetime
  end

  create_table "candidates", :options=>'ENGINE=MyISAM', :force => true do |t|
    t.column "firstname", :string
    t.column "lastname", :string
    t.column "fullname", :string
    t.column "political_party_id", :integer
    t.column "fecid", :string
    t.column "crpid", :string
    t.column "govtrackid", :string
    t.column "bioguideid", :string
    t.column "votesmartid", :string
    t.column "created_at", :datetime
    t.column "updated_at", :datetime
  end

  create_table "committee_financial_summaries", :options=>'ENGINE=MyISAM', :force => true do |t|
    t.column "committee_id", :integer
    t.column "total_receipts", :integer
    t.column "transfers_from_affiliates", :integer
    t.column "contributions_from_individuals", :integer
    t.column "contributions_from_other_committees", :integer
    t.column "total_loans_received", :integer
    t.column "total_disbursements", :integer
    t.column "transfers_to_affiliates", :integer
    t.column "refunds_to_individuals", :integer
    t.column "refunds_to_other_committees", :integer
    t.column "loan_repayments", :integer
    t.column "cash_on_hand_beginning_of_year", :integer
    t.column "cash_on_hand_close_of_period", :integer
    t.column "debts_owed_by", :integer
    t.column "nonfederal_transfers_received", :integer
    t.column "contributions_to_other_committees", :integer
    t.column "independent_expenditures", :integer
    t.column "party_coordinated_expenditures", :integer
    t.column "nonfederal_share_of_expenditures", :integer
    t.column "date_through", :date
    t.column "created_at", :datetime
    t.column "updated_at", :datetime
  end

  create_table "committee_transactions", :options=>'ENGINE=MyISAM', :force => true do |t|
    t.column "committee_id", :integer
    t.column "candidate_id", :integer
    t.column "transaction_date", :date
    t.column "amount", :float
    t.column "transaction_type_id", :integer
    t.column "created_at", :datetime
    t.column "updated_at", :datetime
  end

  create_table "committees", :options=>'ENGINE=MyISAM', :force => true do |t|
    t.column "fecid", :string
    t.column "name", :string
    t.column "committee_designation", :string
    t.column "connected_org_name", :string
    t.column "interest_group_category", :string
    t.column "committee_type", :string
    t.column "political_party_id", :integer
    t.column "candidate_id", :integer
    t.column "created_at", :datetime
    t.column "updated_at", :datetime
  end

  create_table "districts", :options=>'ENGINE=MyISAM', :force => true do |t|
    t.column "name", :string
    t.column "number", :integer
    t.column "usecode", :string
    t.column "state_id", :integer
    t.column "created_at", :datetime
    t.column "updated_at", :datetime
  end

  create_table "elections", :options=>'ENGINE=MyISAM', :force => true do |t|
    t.column "year", :integer
    t.column "election_type", :string
    t.column "district_id", :integer
    t.column "created_at", :datetime
    t.column "updated_at", :datetime
  end

  create_table "expenditures", :options=>'ENGINE=MyISAM', :force => true do |t|
    t.column "schedule", :string
    t.column "committee_id", :integer
    t.column "election_code", :string
    t.column "expenditure_date", :date
    t.column "expenditure_amount", :float
    t.column "expenditure_ytd", :float
    t.column "expenditure_purpose_code", :string
    t.column "category_code", :string
    t.column "payee_fecid", :string
    t.column "support_oppose", :string
    t.column "candidate_id", :integer
    t.column "district_id", :integer
    t.column "created_at", :datetime
    t.column "updated_at", :datetime
  end

  create_table "generic_polygons", :options=>'ENGINE=MyISAM', :force => true do |t|
    t.column "name", :string
    t.column "geometry", :multi_polygon, :null => false
    t.column "district_id", :integer
    t.column "state_id", :integer
    t.column "encoded_points", :string
    t.column "levels", :string
    t.column "zoom_factor", :integer
    t.column "num_levels", :integer
    t.column "created_at", :datetime
    t.column "updated_at", :datetime
  end

  add_index "generic_polygons", ["geometry"], :name => "index_generic_polygons_on_geometry", :spatial=> true 

  create_table "legislators", :force => true do |t|
    t.column "title", :string
    t.column "firstname", :string
    t.column "lastname", :string
    t.column "state_id", :integer
    t.column "candidate_id", :integer
    t.column "district_id", :integer
    t.column "gender", :string
    t.column "bioguide_id", :string
    t.column "votesmart_id", :string
    t.column "govtrack_id", :integer
    t.column "crp_id", :string
    t.column "youtube_url", :string
    t.column "rss_url", :string
    t.column "congresspedia_url", :string
    t.column "phone", :string
    t.column "fax", :string
    t.column "website", :string
    t.column "created_at", :datetime
    t.column "updated_at", :datetime
  end

  create_table "political_parties", :options=>'ENGINE=MyISAM', :force => true do |t|
    t.column "name", :string
    t.column "abbreviation", :string
    t.column "created_at", :datetime
    t.column "updated_at", :datetime
  end

  create_table "states", :options=>'ENGINE=MyISAM', :force => true do |t|
    t.column "name", :string
    t.column "abbreviation", :string
    t.column "fipscode", :integer
    t.column "created_at", :datetime
    t.column "updated_at", :datetime
  end

  create_table "transaction_types", :options=>'ENGINE=MyISAM', :force => true do |t|
    t.column "name", :string
    t.column "code", :string
    t.column "created_at", :datetime
    t.column "updated_at", :datetime
  end

  add_index "transaction_types", ["code"], :name => "index_transaction_types_on_code"

  create_table "vv_ranks", :options=>'ENGINE=MyISAM', :force => true do |t|
    t.column "candidate_id", :integer
    t.column "rank", :float
    t.column "errors", :integer
    t.column "total", :integer
    t.column "percentage_correct", :float
    t.column "seat_type", :string
    t.column "created_at", :datetime
    t.column "updated_at", :datetime
  end

end
