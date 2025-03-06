class BooksController < ApplicationController
  def book_incomes
    respond_to do |format|
      format.json { render json: { book_loans: book_loans, total_revenue: book_loans.sum(:fee) } }
    end
  end

  private

  def book
    @book ||= Book.find(params[:id])
  end

  def book_loans
    @book_loans ||= book
      .book_loans
      .returned
      .where(
        "returned_at >= ? AND returned_at <= ?",
        params[:start_date],
        params[:end_date]
      )
  end
end
