document.addEventListener("DOMContentLoaded", () => {
  const form = document.getElementById("borrow-book-form");

  if (form) {
    form.addEventListener("submit", async (event) => {
      event.preventDefault();
      
      const bookId = document.getElementById("book-select").value;
      const submitButton = document.getElementById("borrow-button");
      submitButton.disabled = true;

      try {
        const response = await fetch("/book_loans", {
          method: "POST",
          body: JSON.stringify({ book_loan: { book_id: bookId } }),
          headers: {
            "Content-Type": "application/json",
            "X-CSRF-Token": document.querySelector("meta[name='csrf-token']").content,
          },
        });

        const data = await response.json();
        const messageBox = document.getElementById("book-loan-response");
        console.log(data)
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
