document.addEventListener("DOMContentLoaded", function () {
  const form = document.getElementById("user-update-form");

  if (form) {
    form.addEventListener("submit", function (event) {
      event.preventDefault(); // Prevent default form submission

      const userId = form.getAttribute("data-user-id");
      const balance = document.getElementById("balance").value;

      fetch(`/users/${userId}`, {
        method: "PATCH",
        headers: {
          "Content-Type": "application/json",
          "X-CSRF-Token": document.querySelector("meta[name='csrf-token']").content,
        },
        body: JSON.stringify({ user: { balance: balance } }),
      })
        .then((response) => response.json())
        .then((data) => {
          const responseDiv = document.getElementById("update-response");
          if (data.errors) {
            responseDiv.innerHTML = `<p style="color: red;">${data.errors.join(", ")}</p>`;
          } else {
            responseDiv.innerHTML = `<p style="color: green;">User ${data.id} updated successfully!</p>
                                     <p>New Balance: ${data.balance}</p>`;
          }
        })
        .catch((error) => {
          console.error("Error:", error);
        });
    });
  }
});