class AddContactMessage < ActiveRecord::Migration
  def self.up
	  create_table :contact_messages do |t|
		  t.string :from
		  t.string :regarding
		  t.text :body
		  t.datetime :occurred

		  t.timestamps
	  end
  end

  def self.down
	  drop_table :contact_messages
  end
end
