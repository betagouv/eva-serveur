document.addEventListener("DOMContentLoaded", () => {
  document.querySelectorAll(".fr-modal").forEach(modal => {
    const btnValider = modal.querySelector(".fr-btn[name='decision'][value='Autoriser']");
    if (!btnValider) return;

    const radios = modal.querySelectorAll('input[type="radio"][name="role"]');

    const toggleButton = () => {
      const isChecked = [...radios].some(radio => radio.checked);
      btnValider.disabled = !isChecked;
    };

    radios.forEach(radio => {
      radio.addEventListener("change", toggleButton);
    });

    toggleButton();
  });
});
