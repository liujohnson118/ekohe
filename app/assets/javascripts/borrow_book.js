document.addEventListener("DOMContentLoaded", () => {
  const form = document.getElementById("borrow-book-form");

  if (form) {
    form.addEventListener("submit", async (event) => {
      event.preventDefault();
      
      const bookId = document.getElementById("book-select").value;
      const submitButton = document.getElementById("borrow-button");
      submitButton.disabled = true;

      try {
        const response = await fetch("/borrow_books", {
          method: "POST",
          body: JSON.stringify({ borrow_book: { book_id: bookId } }),
          headers: {
            "Content-Type": "application/json",
            "X-CSRF-Token": document.querySelector("meta[name='csrf-token']").content,
          },
        });

        const data = await response.json();
        const messageBox = document.getElementById("borrow-book-response");
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
