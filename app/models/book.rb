class Book < ApplicationRecord
  DEFAULT_FEE = 1.25

  has_many :book_loans
  has_many :users, through: :book_loans

  scope :available, -> { where("available_copies > 0") }
end
