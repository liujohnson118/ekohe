require "rails_helper"

RSpec.describe BooksController, type: :request do
  describe "GET /books/:id/book_incomes" do
    let!(:book) { create(:book) }
    let!(:user) { create(:user, email: "john@doe.com") }

    let!(:loan_1) do
      create(:book_loan, book: book, user: user, fee: 10.00, returned_at: 2.days.ago)
    end
    let!(:loan_2) do
      create(:book_loan, book: book, user: user, fee: 15.00, returned_at: 1.day.ago)
    end
    let!(:loan_outside_range) do
      create(:book_loan, book: book, user: user, fee: 20.00, returned_at: 10.days.ago)
    end

    context "with valid date range" do
      let(:start_date) { 3.days.ago.to_date.to_s }
      let(:end_date) { Time.zone.now.to_date.to_s }

      it "returns the total revenue and book loans within range" do
        get book_incomes_book_path(book.id), params: { start_date: start_date, end_date: end_date }, as: :json

        expect(response).to have_http_status(:success)

        json = JSON.parse(response.body)
        expect(json["total_revenue"]).to eq("25.0")
        expect(json["book_loans"].size).to eq(2)
      end
    end

    context "with no loans in the given date range" do
      let(:start_date) { 30.days.ago.to_date.to_s }
      let(:end_date) { 20.days.ago.to_date.to_s }

      it "returns zero revenue and empty book_loans" do
        get book_incomes_book_path(book.id), params: { start_date: 30.days.ago, end_date: 20.days.ago }, as: :json

        expect(response).to have_http_status(:success)

        json = JSON.parse(response.body)
        expect(json["total_revenue"]).to eq("0.0")
        expect(json["book_loans"]).to be_empty
      end
    end
  end
end
