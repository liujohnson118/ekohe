module Users
  class BookLoansController < ApplicationController
    def index
      respond_to do |format|
        format.json do
          render json: {
            book_loans: book_loans,
            summary: {
              times_borrowed: book_loans.count,
              unique_books_borrowed: book_loans.distinct.count(:book_id),
              total_fees: returned_book_loans.sum(:fee)
            }
          }
        end
      end
    end

    private

    def book_loans
      @book_loans ||= user
        .book_loans
        .where(
          "borrowed_at >= ? AND borrowed_at <= ?",
          params[:start_date],
          params[:end_date]
        )
    end

    def returned_book_loans
      @returned_book_loans ||= book_loans.returned
    end

    def user
      @user ||= User.find(params[:user_id])
    end
  end
end