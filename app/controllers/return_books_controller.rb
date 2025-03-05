class ReturnBooksController < ApplicationController
  before_action :authenticate_user!

  def create
    debugger
    return_book_data = ReturnBook.new(book_loan: book_loan).call

    respond_to do |format|
      if return_book_data[:success]
        format.json { render json: { success: true, message: "Book returned successfully!" }, status: :ok }
      else
        format.json { render json: { success: false, errors: return_book_data[:error] }, status: :unprocessable_entity }
      end
    end
  end

  private

  def book_loan
    @book_loan ||= current_user.book_loans.find(return_books_params[:book_loan_id])
  end

  def return_books_params
    params.require(:return_book).permit(:book_loan_id)
  end
end
