require "rails_helper"

RSpec.describe BorrowBooksController, type: :controller do
  let(:user) { create(:user, email: "john@doe.com") }
  let(:book) { create(:book) }
  let(:valid_params) { { borrow_book: { user_id: user.id, book_id: book.id } } }
  let(:borrow_book) { instance_double(BorrowBook) }

  describe "POST #create" do
    before do
      allow(BorrowBook).to receive(:new).with(user: user, book: book).and_return(borrow_book)
    end

    context "when borrowing a book is successful" do
      before do
        allow(borrow_book).to receive(:call).and_return({ success: true, book_loan: double(id: 1) })
      end

      it "returns a success response" do
        post :create, params: valid_params, format: :json

        expect(response).to have_http_status(:ok)
        json_response = JSON.parse(response.body)
        expect(json_response["success"]).to be true
        expect(json_response["message"]).to eq("Book borrowed successfully!")
      end
    end

    context "when borrowing a book fails" do
      before do
        allow(borrow_book).to receive(:call).and_return({ success: false, error: "Boom" })
      end

      it "returns an error response" do
        post :create, params: valid_params, format: :json

        expect(response).to have_http_status(:unprocessable_entity)
        json_response = JSON.parse(response.body)
        expect(json_response["success"]).to be false
        expect(json_response["errors"]).to eq("Boom")
      end
    end
  end
end
