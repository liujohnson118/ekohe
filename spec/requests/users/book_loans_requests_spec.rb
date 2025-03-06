require "rails_helper"

RSpec.describe Users::BookLoansController, type: :request do
  describe "GET /users/:user_id/book_loans" do
    let!(:user) { create(:user, email: "john@doe.com") }
    let!(:book1) { create(:book, title: "Book A") }
    let!(:book2) { create(:book, title: "Book B") }

    let!(:loan_1) do
      create(:book_loan, user: user, book: book1, fee: 10.00, borrowed_at: 5.days.ago, returned_at: 2.days.ago)
    end
    let!(:loan_2) do
      create(:book_loan, user: user, book: book2, fee: 15.00, borrowed_at: 3.days.ago, returned_at: 1.day.ago)
    end
    let!(:loan_outside_range) do
      create(:book_loan, user: user, book: book1, fee: 20.00, borrowed_at: 15.days.ago, returned_at: 10.days.ago)
    end
    let(:params) do
      {
        start_date: start_date,
        end_date: end_date
      }
    end

    context "with valid date range" do
      let(:start_date) { 7.days.ago.to_date.to_s }
      let(:end_date) { Time.zone.now.to_date.to_s }
      it "returns the user's book loans and summary within the range" do
        get user_book_loans_path(user.id), params: params, as: :json

        expect(response).to have_http_status(:success)

        json = JSON.parse(response.body)
        expect(json["book_loans"].size).to eq(2)

        summary = json["summary"]
        expect(summary["times_borrowed"]).to eq(2)
        expect(summary["unique_books_borrowed"]).to eq(2)
        expect(summary["total_fees"]).to eq("25.0")
      end
    end

    context "with no book loans in the given date range" do
      let(:start_date) { 30.days.ago.to_date.to_s }
      let(:end_date) { 20.days.ago.to_date.to_s }

      it "returns zero counts and an empty book loans array" do
        get user_book_loans_path(user.id), params: params, as: :json

        expect(response).to have_http_status(:success)

        json = JSON.parse(response.body)
        expect(json["book_loans"]).to be_empty

        summary = json["summary"]
        expect(summary["times_borrowed"]).to eq(0)
        expect(summary["unique_books_borrowed"]).to eq(0)
        expect(summary["total_fees"]).to eq("0.0")
      end
    end
  end
end
