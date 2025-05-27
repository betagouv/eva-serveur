document.addEventListener("DOMContentLoaded", () => {
  const toggleElements = document.querySelectorAll(".toggle-auto-soumission input");

  toggleElements.forEach(toggleElement => {
    toggleElement.addEventListener("change", function () {
      this.closest("form").submit();
    });
  });
});
