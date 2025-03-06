class ReturnBook
  def initialize(book_loan:)
    @book_loan = book_loan
  end

  def call
    ActiveRecord::Base.transaction do
      book_loan.update!(returned_at: Time.zone.now)

      user.decrement!(:balance, book_loan.fee)
      book.increment!(:available_copies)

      { success: true, book_loan: book_loan }
    end
  rescue StandardError => e
    { success: false, error: e.message }
  end

  private

  attr_reader :book_loan

  def book
    @book ||= book_loan.book
  end

  def user
    @user ||= book_loan.user
  end
end
