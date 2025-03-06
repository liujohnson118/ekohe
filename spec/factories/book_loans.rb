FactoryBot.define do
  factory :book_loan do
    association :user
    association :book
    borrowed_at { Time.zone.yesterday }
    fee { book.fee }
    returned_at { nil }
  end
end
