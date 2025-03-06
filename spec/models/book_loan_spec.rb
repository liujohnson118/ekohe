require "rails_helper"

RSpec.describe BookLoan, type: :model do
  let(:user) { create(:user, email: "john@doe.com", balance: 50.0) }
  let(:book) { create(:book, fee: 10.0, available_copies: 1) }

  describe "validations" do
    context "when the user has an outstanding loan" do
      before { create(:book_loan, user: user, book: book, returned_at: nil) }

      it "does not allow the user to borrow another book" do
        new_loan = build(:book_loan, user: user, book: book)
        expect(new_loan.save).to be(false)
        expect(new_loan.errors[:user]).to include("must return the current book before borrowing a new one.")
      end
    end

    context "when the user does not have enough balance" do
      let(:user) { create(:user, email: "john@doe.com", balance: 5.0) }

      it "does not allow the user to borrow the book" do
        loan = build(:book_loan, user: user, book: book)
        expect(loan.save).to be(false)
        expect(loan.errors[:user]).to include("does not have enough balance to borrow this book.")
      end
    end

    context "when the book has no available copies" do
      before { book.update(available_copies: 0) }

      it "does not allow borrowing the book" do
        loan = build(:book_loan, user: user, book: book)
        expect(loan.save).to be(false)
        expect(loan.errors[:book]).to include("has no available copies left to borrow.")
      end
    end
  end

  describe "scopes" do
    let!(:returned_loan) { create(:book_loan, user: user, book: book, returned_at: Time.current) }
    let!(:not_returned_loan) { create(:book_loan, user: user, book: book, returned_at: nil) }

    it "returns only not returned loans" do
      expect(BookLoan.not_returned).to contain_exactly(not_returned_loan)
    end

    it "returns only returned loans" do
      expect(BookLoan.returned).to contain_exactly(returned_loan)
    end
  end
end
