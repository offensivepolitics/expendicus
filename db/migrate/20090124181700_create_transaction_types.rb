class CreateTransactionTypes < ActiveRecord::Migration
  def self.up
    create_table :transaction_types, :options => 'engine=MyISAM' do |t|
      t.string :name
      t.string :code

      t.timestamps
    end

		add_index :transaction_types,:code
  end

  def self.down
    drop_table :transaction_types
  end
end
