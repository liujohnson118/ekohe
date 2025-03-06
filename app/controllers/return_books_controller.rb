class ReturnBooksController < ApplicationController
  def create
    return_book_data = ReturnBook.new(book_loan: book_loan).call

    respond_to do |format|
      if return_book_data[:success]
        format.json { render json: { success: true, message: "Book returned successfully!", book_loan: return_book_data[:book_loan] }, status: :ok }
      else
        format.json { render json: { success: false, errors: return_book_data[:error] }, status: :unprocessable_entity }
      end
    end
  end

  private

  def book_loan
    @book_loan ||= BookLoan.not_returned.find_by(user_id: return_books_params[:user_id], book_id: return_books_params[:book_id])
  end

  def return_books_params
    params.require(:return_book).permit(:book_id, :user_id)
  end
end
