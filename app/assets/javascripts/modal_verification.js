document.addEventListener("DOMContentLoaded", () => {
  const btnValider = document.getElementById("valider-modal-verification");
  if (!btnValider) return;

  const radios = [...document.querySelectorAll('input[type="radio"][name="role"]')];

  const toggleButton = () => {
    btnValider.disabled = !radios.some(radio => radio.checked);
  };

  radios.forEach(radio => radio.addEventListener("change", toggleButton));

  toggleButton();
});
