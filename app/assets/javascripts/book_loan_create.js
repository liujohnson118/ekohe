document.addEventListener("DOMContentLoaded", () => {
  const form = document.getElementById("borrow-book-form");

  if (form) {
    form.addEventListener("submit", async (event) => {
      event.preventDefault();
      
      const bookId = document.getElementById("book_id").value;
      const submitButton = document.getElementById("borrow-button");
      submitButton.disabled = true;

      try {
        const response = await fetch(form.action, {
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
          messageBox.innerHTML = `<p style="color: red;">${data.error}</p>`;
        }
      } catch (error) {
        console.error("Error:", JSON.parse(error));
      } finally {
        submitButton.disabled = false;
      }
    });
  }
});
