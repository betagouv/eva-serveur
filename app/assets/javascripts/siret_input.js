/**
 * Formatage des champs SIRET (data-siret-input="true") :
 * - Ne garde que les chiffres à la saisie
 * - Affiche au format 123 456 789 01234 (3-3-3-5)
 * - À l'envoi du formulaire, envoie uniquement les 14 chiffres au serveur
 */
(function() {
  const SIRET_LENGTH = 14;
  const SIRET_CHUNKS = [3, 3, 3, 5];

  const digitsOnly = (str) => (str || "").replace(/\D/g, "");

  function formatSiretDisplay(str) {
    const digits = digitsOnly(str).slice(0, SIRET_LENGTH);
    if (digits.length === 0) return "";
    const parts = [];
    let pos = 0;
    for (let i = 0; i < SIRET_CHUNKS.length && pos < digits.length; i++) {
      parts.push(digits.slice(pos, pos + SIRET_CHUNKS[i]));
      pos += SIRET_CHUNKS[i];
    }
    return parts.join(" ");
  }

  function onInput(e) {
    const input = e.target;
    const cursor = input.selectionStart;
    const oldVal = input.value;
    const digitsBeforeCursor = digitsOnly(oldVal.slice(0, cursor)).length;
    const digits = digitsOnly(oldVal).slice(0, SIRET_LENGTH);
    const formatted = formatSiretDisplay(digits);
    if (formatted === oldVal) return;
    input.value = formatted;
    let newCursor = formatted.length;
    let digitCount = 0;
    for (let i = 0; i < formatted.length; i++) {
      if (formatted[i] !== " ") digitCount++;
      if (digitCount >= digitsBeforeCursor) {
        newCursor = i + 1;
        break;
      }
    }
    input.setSelectionRange(newCursor, newCursor);
  }

  function onPaste(e) {
    const input = e.target;
    e.preventDefault();
    const text = (e.clipboardData || window.clipboardData).getData("text");
    const digits = digitsOnly(text).slice(0, SIRET_LENGTH);
    input.value = formatSiretDisplay(digits);
  }

  document.addEventListener("submit", (e) => {
    const inputs = e.target.querySelectorAll('input[data-siret-input="true"]');
    if (inputs.length === 0) return;
    inputs.forEach((input) => {
      input.value = digitsOnly(input.value).slice(0, SIRET_LENGTH);
    });
  }, true);

  function initSiretInputs() {
    document.querySelectorAll('input[data-siret-input="true"]').forEach((input) => {
      input.addEventListener("input", onInput);
      input.addEventListener("paste", onPaste);
      input.value = formatSiretDisplay(input.value);
    });
  }

  document.addEventListener("DOMContentLoaded", initSiretInputs);
})();
