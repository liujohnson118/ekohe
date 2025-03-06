require "rails_helper"

RSpec.describe ReturnBooksController, type: :controller do
  let(:user) { create(:user, email: "john@doe.com") }
  let(:book) { create(:book) }
  let(:book_loan) { create(:book_loan, user: user, book: book, returned_at: nil) }
  let(:valid_params) { { return_book: { user_id: user.id, book_id: book.id } } }
  let(:return_book) { instance_double(ReturnBook) }

  describe "POST #create" do
    before do
      allow(ReturnBook).to receive(:new).with(book_loan: book_loan).and_return(return_book)
    end

    context "when returning a book is successful" do
      before do
        allow(BookLoan).to receive_message_chain(:not_returned, :find_by).and_return(book_loan)
        allow(return_book).to receive(:call).and_return({ success: true, book_loan: book_loan })
      end

      it "returns a success response" do
        post :create, params: valid_params, format: :json

        expect(response).to have_http_status(:ok)
        json_response = JSON.parse(response.body)
        expect(json_response["success"]).to be true
        expect(json_response["message"]).to eq("Book returned successfully!")
      end
    end

    context "when returning a book fails" do
      before do
        allow(BookLoan).to receive_message_chain(:not_returned, :find_by).and_return(book_loan)
        allow(return_book).to receive(:call).and_return({ success: false, error: "Minion" })
      end

      it "returns an error response" do
        post :create, params: valid_params, format: :json

        expect(response).to have_http_status(:unprocessable_entity)
        json_response = JSON.parse(response.body)
        expect(json_response["success"]).to be false
        expect(json_response["errors"]).to eq("Minion")
      end
    end
  end
end
