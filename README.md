# README

* Assumptions Made
1. The user is only charged a fee at the time of returning the book to library and NOT at the time of taking out a book from library. 
2. Because of condition 1, we only allow users to take out a book (i.e. create a book loan) when the 3 condtions are met: 
  - A) No existing books that have not been returned to the libary. This is to prevent the user from taking out a potentially large number of books in any one setting resulting in increased risk of not returning the books. 
  - B) The user's balance must be greater than or equal to the fee of the book. This is to ensure the user has enough money to cover the fee at the time of returning the book. 
  - C) The book's available copies must be greater than or equal to 1.  

* DB Initialization
1. Go to root directory of the project and run `bin/rails db:setup`. This should set up the development and test databases. The development DB should also be seeded.
2. At the end of step 1, you should see a summary of the users, books, and the associated book loans. 
3. Explanation of output of seed operation: 
  - A) Users jane@smith.com and and john@doe.com both started with $10 in their accounts. User adam@lee.com was offered $5 only. 
  - B) Each of the 5 books was given 5 copies. 
  - C) john@doe.com has borrowed and returned a copy of Rich Dad Poor Dad. The number of copies of Rich Dad Poor Dad is 5 at the end of the seed operation. john@doe.com has $1.25 deducted from his account, making it $8.75 remaining. 
  - D) adam@lee.com has borrowed a copy of Frankenstein but not returned yet. So his balance remains at $5. Frankenstein has 4 copies at the end of the seed operation. 

* Design Principles Considered
SOLID engineering principles were considered and implemented as much as possible in order to achieve separation of concerns and inverse dependability. A dedicated service for borrowing a book and returning a book were made. 

* API Endpoints

## Steps To Test Endpints

1. Go to root directory of the project and run `rails server` to start the server. 
2. Use an API app of your choice (e.g. Postman). 

## Endpoint Testing

1. User endpoint to set the initial amount and returning user ID: 
URL: PATCH `http://localhost:3000/users/2` with headers `Content-Type: "application/json"`
Example body: 
```
{
    "user": {
        "balance": 3.69
    }
}
```
Example response: 
```
{
    "balance": "3.69",
    "email": "jane@smith.com",
    "id": 2,
    "created_at": "2025-03-06T14:49:17.750Z",
    "updated_at": "2025-03-06T15:05:56.846Z"
}
```
At the end of the API call, you may check in rails console that the jane@smith.com's balance has been set to $3.69. 

2. Endpoint to borrow a book: 
URL: POST `http://localhost:3000/borrow_books` with headers `Content-Type: "application/json"`
Example body: 
```
{
    "borrow_book": {
        "book_id": 2,
        "user_id": 2
    }
}
```
Example response: 
```
{
    "success": true,
    "message": "Book borrowed successfully!",
    "book_loan": {
        "id": 3,
        "user_id": 2,
        "book_id": 2,
        "borrowed_at": "2025-03-06T15:11:29.767Z",
        "returned_at": null,
        "fee": "1.25",
        "created_at": "2025-03-06T15:11:29.775Z",
        "updated_at": "2025-03-06T15:11:29.775Z"
    }
}
```
At the end of the operation, check the user's balance is still $3.69 (book not returned yet so no money taken from account) and the `available_copies` of the book (ID 2, Rich Dad Poor Dad) has decremented from 5 to 4. 

You may now try sending the exact same request again, the response will be 422 with body
```
{
    "success": false,
    "errors": "Failed to save the record"
}
```
This is because the user has an active, not-returned book loan. 

3. Endpoint to return a book:
## Happy Path
URL: POST `http://localhost:3000/return_books` with headers `Content-Type: "application/json"`
Example body to return the book borrowed earlier: 
```
{
    "return_book": {
        "user_id": 2,
        "book_id": 2
    }
}
```
Example response: 
```
{
    "success": true,
    "message": "Book returned successfully!",
    "book_loan": {
        "returned_at": "2025-03-06T15:16:22.540Z",
        "user_id": 2,
        "book_id": 2,
        "fee": "1.25",
        "id": 3,
        "borrowed_at": "2025-03-06T15:11:29.767Z",
        "created_at": "2025-03-06T15:11:29.775Z",
        "updated_at": "2025-03-06T15:16:22.541Z"
    }
}
```
Now in rails console check user 2's balance has decreased from $3.69 to $2.44 after a $1.25 charge. The `available_copies` of book 2 has incremented from 4 to 5. 

## Additional Testing of Borrowing/Returning A book. 
Test user having insufficient fund to cover the book. Let's jack up book 3 (The Great Gatsby) to have a fee of $8.00. You can do so on rails console. 
```
Book.find(3).update(fee: 8)
```
Call POST `http://localhost:3000/borrow_books` with body
```
{
    "borrow_book": {
        "book_id": 3,
        "user_id": 2
    }
}
```
You'll get 422. Nothing should change to User 2's balance and the available copies of Book 3. 
Test book having insufficient available copies. 
```
Book.find(3).update(fee: 1.25, available_copies: 0)
```
Repeat the API call, again 422 response. 
Put everything back to normal: 
```
Book.find(3).update(fee: 1.25, available_copies: 1)
```
Repeat the API call and it will be successful. 

4. Endpoint For User Account Status and Borrowed Books:
URL: GET `http://localhost:3000/users/2/account_status.json`
Sample response: 
```
{
    "balance": "2.44",
    "book_loans": [
        {
            "id": 3,
            "book_id": 2,
            "book_title": "Rich Dad Poor Dad",
            "borrowed_at": "2025-03-06T15:11:29.767Z",
            "returned_at": "2025-03-06T15:16:22.540Z"
        },
        {
            "id": 4,
            "book_id": 3,
            "book_title": "The Great Gatsby",
            "borrowed_at": "2025-03-06T15:23:36.152Z",
            "returned_at": null
        }
    ]
}
```

5. Endpoint For Incomes of Book:

URL: GET `http://localhost:3000/books/2/book_incomes.json?start_date=2025-03-01&end_date=2025-03-07`
Example Response:
```
{
    "book_loans": [
        {
            "id": 1,
            "user_id": 1,
            "book_id": 2,
            "borrowed_at": "2025-03-06T14:49:17.967Z",
            "returned_at": "2025-03-06T14:49:17.986Z",
            "fee": "1.25",
            "created_at": "2025-03-06T14:49:17.976Z",
            "updated_at": "2025-03-06T14:49:17.986Z"
        },
        {
            "id": 3,
            "user_id": 2,
            "book_id": 2,
            "borrowed_at": "2025-03-06T15:11:29.767Z",
            "returned_at": "2025-03-06T15:16:22.540Z",
            "fee": "1.25",
            "created_at": "2025-03-06T15:11:29.775Z",
            "updated_at": "2025-03-06T15:16:22.541Z"
        }
    ],
    "total_revenue": "2.5"
}
```

6. Monthly and annual reports for a user. This one I made an endpoint that takes the start and end dates and returns the book loans along with summary data for the user during the date range. In the summary, you shall see how many times in total the user has borrowed and how many unique books the user has borrowed, as well as the total fees paid (for books that have been returned). 
URL: GET `http://localhost:3000/users/1/book_loans.json?start_date=2025-03-01&end_date=2025-03-07`
Example Reponse: 
```
{
    "book_loans": [
        {
            "id": 1,
            "user_id": 1,
            "book_id": 2,
            "borrowed_at": "2025-03-06T14:49:17.967Z",
            "returned_at": "2025-03-06T14:49:17.986Z",
            "fee": "1.25",
            "created_at": "2025-03-06T14:49:17.976Z",
            "updated_at": "2025-03-06T14:49:17.986Z"
        }
    ],
    "summary": {
        "times_borrowed": 1,
        "unique_books_borrowed": 1,
        "total_fees": "1.25"
    }
}
```