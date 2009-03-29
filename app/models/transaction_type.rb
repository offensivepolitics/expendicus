# == Schema Information
# Schema version: 20090225132948
#
# Table name: transaction_types
#
#  id         :integer(4)      not null, primary key
#  name       :string(255)
#  code       :string(255)
#  created_at :datetime
#  updated_at :datetime
#

class TransactionType < ActiveRecord::Base
end
