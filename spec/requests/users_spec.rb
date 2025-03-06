require "rails_helper"

RSpec.describe UsersController, type: :request do
  let!(:user) { create(:user, email: "john@doe.com",) }
  let!(:book) { create(:book) }
  let!(:book_loan) { create(:book_loan, user: user, book: book, borrowed_at: Time.zone.now) }

  describe "GET /users" do
    it "returns all users" do
      get users_path

      expect(response).to have_http_status(:success)
      json_response = JSON.parse(response.body)
      expect(json_response).to be_an(Array)
      expect(json_response.first["id"]).to eq(user.id)
    end
  end

  describe "PUT /users/:id" do
    context "with valid parameters" do
      it "updates the user balance" do
        put user_path(user), params: { user: { balance: 50.00 } }, as: :json

        expect(response).to have_http_status(:success)
        json_response = JSON.parse(response.body)
        expect(json_response["balance"]).to eq("50.0")
      end
    end

    context "with invalid parameters" do
      it "returns an error when balance is invalid" do
        put user_path(user), params: { user: { balance: nil } }, as: :json

        expect(response).to have_http_status(:unprocessable_entity)
        json_response = JSON.parse(response.body)
        expect(json_response).to include("balance")
      end
    end
  end

  describe "GET /users/:id/account_status" do
    it "returns user balance and book loans" do
      get account_status_user_path(user)

      expect(response).to have_http_status(:success)
      json_response = JSON.parse(response.body)

      expect(json_response["balance"]).to eq("100.0")
      expect(json_response["book_loans"]).to be_an(Array)
      expect(json_response["book_loans"].first["book_title"]).to eq("The Great Gatsby")
    end
  end
end
