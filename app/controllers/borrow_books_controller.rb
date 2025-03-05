class BorrowBooksController < ApplicationController
  before_action :authenticate_user!

  def create
    borrow_book_data = BorrowBook.new(user: current_user, book: book).call

    respond_to do |format|
      if borrow_book_data[:success]
        format.json { render json: { success: true, message: "Book borrowed successfully!" }, status: :ok }
      else
        format.json { render json: { success: false, errors: borrow_book_data[:error] }, status: :unprocessable_entity }
      end
    end
  end

  private

  def book
    @book ||= Book.find(borrow_books_params[:book_id])
  end

  def borrow_books_params
    params.require(:borrow_book).permit(:book_id)
  end
end
