class BookLoansController < ApplicationController
  before_action :authenticate_user!

  def index
    @book_loans = current_user.book_loans
    respond_to do |format|
      format.html
    end
  end

  def show
    @book_loan = current_user.book_loans.includes(:book, :user).find(params[:id])
    respond_to do |format|
      format.html
    end
  end

  def new
    @new_book_loan = BookLoan.new
    @available_books = Book.available
    respond_to do |format|
      format.html
    end
  end

  def create
    create_book_loan_data = CreateBookLoan.new(user: current_user, book: book).call

    respond_to do |format|
      if create_book_loan_data[:success]
        format.json { render json: { success: true, message: "Book borrowed successfully!" }, status: :ok }
      else
        format.json { render json: { success: false, errors: create_book_loan_data[:error] }, status: :unprocessable_entity }
      end
    end
  end

  private

  def book
    @book ||= Book.find(book_loan_params[:book_id])
  end

  def book_loan_params
    params.require(:book_loan).permit(:book_id)
  end
end