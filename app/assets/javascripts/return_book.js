document.addEventListener("turbo:load", () => {
  const button = document.getElementById("return-book-button");

  if (button) {
    button.addEventListener("click", async (event) => {
      event.preventDefault();
      
      const bookLoanId = document.getElementById("book-loan-id").innerText;

      try {
        const response = await fetch("/return_books", {
          method: "POST",
          body: JSON.stringify({ return_book: { book_loan_id: bookLoanId } }),
          headers: {
            "Content-Type": "application/json",
            "X-CSRF-Token": document.querySelector("meta[name='csrf-token']").content,
          },
        });

        const data = await response.json();
        const messageBox = document.getElementById("return-book-response");
        if (data.success) {
          messageBox.innerHTML = `<p style="color: green;">${data.message}</p>`;
        } else {
          messageBox.innerHTML = `<p style="color: red;">${data.errors}</p>`;
        }
      } catch (error) {
        messageBox.innerHTML = `<p style="color: red;">${data.errors}</p>`;
      } finally {
        submitButton.disabled = false;
      }
    });
  }
});
