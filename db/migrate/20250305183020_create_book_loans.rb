class CreateBookLoans < ActiveRecord::Migration[8.0]
  def change
    create_table :book_loans do |t|
      t.belongs_to :user, null: false, foreign_key: true
      t.belongs_to :book, null: false, foreign_key: true
      t.datetime :borrowed_at, null: false
      t.datetime :returned_at
      t.decimal :fee

      t.timestamps
    end

    add_check_constraint :book_loans, "fee >= 0", name: "book_loans_fee_check"
  end
end
