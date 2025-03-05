class BorrowBook
  def initialize(user:, book:)
    @user = user
    @book = book
  end

  def call
    ActiveRecord::Base.transaction do
      book_loan = BookLoan.create!(user: user, book: book, fee: book.fee, borrowed_at: Time.zone.now)

      book.decrement!(:available_copies)

      { success: true, book_loan: book_loan }
    end
  rescue StandardError => e
    { success: false, error: e.message }
  end

  private

  attr_reader :user, :book
end
