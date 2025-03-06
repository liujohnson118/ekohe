class BookLoan < ApplicationRecord
  scope :not_returned, -> { where(returned_at: nil) }
  scope :returned, -> { where.not(returned_at: nil) }

  belongs_to :user
  belongs_to :book

  validates :fee, numericality: { greater_than_or_equal_to: 0 }
  before_create :validate_loan_conditions

  private

  def validate_loan_conditions
    if user.book_loans.not_returned.exists?
      errors.add(:user, "must return the current book before borrowing a new one.")
      throw(:abort)
    end

    if user.balance < book.fee
      errors.add(:user, "does not have enough balance to borrow this book.")
      throw(:abort)
    end

    if book.available_copies < 1
      errors.add(:book, "has no available copies left to borrow.")
      throw(:abort)
    end
  end
end
