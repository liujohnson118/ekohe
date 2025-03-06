require "rails_helper"

RSpec.describe BorrowBook do
  let!(:user) { create(:user, email: "john@doe.com") }
  let!(:book) { create(:book, fee: 10.00, available_copies: 3) }

  context "when borrowing is successful" do
    it "creates a book loan, deducts book copy, and returns success" do
      result = BorrowBook.new(user: user, book: book).call

      expect(result[:success]).to be true
      expect(result[:book_loan]).to be_persisted

      expect(user.book_loans.count).to eq(1)
      expect(book.reload.available_copies).to eq(2)
    end
  end

  context "when user already has an active book loan" do
    before do
      create(:book_loan, user: user, book: book, borrowed_at: Time.now, returned_at: nil)
    end

    it "fails and does not create a new book loan" do
      result = BorrowBook.new(user: user, book: book).call

      expect(result[:success]).to be false
      expect(result[:error]).to eq("Failed to save the record")

      expect(BookLoan.count).to eq(1)
      expect(book.reload.available_copies).to eq(3)
    end
  end

  context "when user does not have enough balance" do
    before { user.update(balance: 5.00) }

    it "fails and does not create a new book loan" do
      result = BorrowBook.new(user: user, book: book).call

      expect(result[:success]).to be false
      expect(result[:error]).to eq("Failed to save the record")

      expect(BookLoan.count).to eq(0)
      expect(book.reload.available_copies).to eq(3)
    end
  end

  context "when the book has no available copies" do
    before { book.update(available_copies: 0) }

    it "fails and does not create a new book loan" do
      result = BorrowBook.new(user: user, book: book).call

      expect(result[:success]).to be false
      expect(result[:error]).to eq("Failed to save the record")

      expect(BookLoan.count).to eq(0)
      expect(book.reload.available_copies).to eq(0)
    end
  end
end
