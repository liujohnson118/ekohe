require "rails_helper"

RSpec.describe ReturnBook do
  let!(:user) { create(:user, email: "john@doe.com", balance: 50.00) }
  let!(:book) { create(:book, fee: 10.00, available_copies: 2) }
  let!(:book_loan) { create(:book_loan, user: user, book: book, fee: book.fee, borrowed_at: 2.days.ago, returned_at: nil) }

  context "when returning is successful" do
    it "marks the book as returned, updates balance, and increases available copies" do
      result = ReturnBook.new(book_loan: book_loan).call

      expect(result[:success]).to be true
      expect(result[:book_loan].returned_at).not_to be_nil

      expect(user.reload.balance).to eq(40.00)
      expect(book.reload.available_copies).to eq(3)
    end
  end

  context "when an error occurs during the return process" do
    before do
      allow(book_loan).to receive(:update!).and_raise(StandardError, "Something went wrong")
    end

    it "does not update balance or available copies" do
      result = ReturnBook.new(book_loan: book_loan).call

      expect(result[:success]).to be false
      expect(result[:error]).to eq("Something went wrong")

      expect(user.reload.balance).to eq(50.00)
      expect(book.reload.available_copies).to eq(2)
    end
  end
end
