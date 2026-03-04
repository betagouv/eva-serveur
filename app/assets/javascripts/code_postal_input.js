/**
 * Champs code postal (data-code-postal-input="true") :
 * - Ne garde que les chiffres à la saisie, max 5
 * - À l'envoi du formulaire, envoie uniquement les 5 chiffres au serveur
 */
(function() {
  const CODE_POSTAL_LENGTH = 5;

  const digitsOnly = (str) => (str || "").replace(/\D/g, "");

  function onInput(e) {
    const input = e.target;
    input.value = digitsOnly(input.value).slice(0, CODE_POSTAL_LENGTH);
  }

  function onPaste(e) {
    const input = e.target;
    e.preventDefault();
    const text = (e.clipboardData || window.clipboardData).getData("text");
    input.value = digitsOnly(text).slice(0, CODE_POSTAL_LENGTH);
  }

  document.addEventListener("submit", (e) => {
    const inputs = e.target.querySelectorAll('input[data-code-postal-input="true"]');
    if (inputs.length === 0) return;
    inputs.forEach((input) => {
      input.value = digitsOnly(input.value).slice(0, CODE_POSTAL_LENGTH);
    });
  }, true);

  function initCodePostalInputs() {
    document.querySelectorAll('input[data-code-postal-input="true"]').forEach((input) => {
      input.addEventListener("input", onInput);
      input.addEventListener("paste", onPaste);
      input.value = digitsOnly(input.value).slice(0, CODE_POSTAL_LENGTH);
    });
  }

  document.addEventListener("DOMContentLoaded", initCodePostalInputs);
})();
