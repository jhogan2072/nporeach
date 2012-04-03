class AddMailingGreetingToFamily < ActiveRecord::Migration
  def change
    add_column :families, :mailing_greeting, :string
  end
end
