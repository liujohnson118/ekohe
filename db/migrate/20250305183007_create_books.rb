
class CreateBooks < ActiveRecord::Migration[8.0]
  def change
    create_table :books do |t|
      t.string :title
      t.integer :available_copies
      t.decimal :fee, default: 0, null: false

      t.timestamps
    end

    add_check_constraint :books, "available_copies >= 0", name: "books_available_copies_check"
  end
end
