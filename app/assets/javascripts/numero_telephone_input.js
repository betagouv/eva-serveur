/**
 * Champs numéro de téléphone (data-numero-telephone-input="true") :
 * - Accepte les chiffres, +, espaces, parenthèses à la saisie
 * - Affiche au format (+33) X XX XX XX XX
 * - À l'envoi du formulaire, normalise la valeur au format avec espaces
 */
(function() {
  const digitsOnly = (str) => (str || "").replace(/\D/g, "");

  function formatFrenchPhone(digits) {
    if (digits.length === 0) return "";
    let national = digits;
    if (digits.length === 11 && digits.startsWith("33")) {
      national = digits.slice(2, 11);
    } else if (digits.length >= 10 && digits.startsWith("0")) {
      national = digits.slice(1, 10);
    } else if (digits.length === 9 && digits.startsWith("0")) {
      // Saisie incomplète (0 + 8 chiffres) : ne pas formater pour permettre d’ajouter le 10ᵉ chiffre
      return digits;
    } else if (digits.startsWith("33")) {
      return digits;
    } else if (digits.length > 9) {
      national = digits.slice(0, 9);
    }
    if (national.length < 9) return digits;
    return [
      "(+33)",
      national[0],
      national.slice(1, 3),
      national.slice(3, 5),
      national.slice(5, 7),
      national.slice(7, 9)
    ].join(" ");
  }

  function onInput(e) {
    const input = e.target;
    const digits = digitsOnly(input.value).slice(0, 11);
    const formatted = formatFrenchPhone(digits);
    if (formatted !== input.value) input.value = formatted;
  }

  function onPaste(e) {
    const input = e.target;
    e.preventDefault();
    const text = (e.clipboardData || window.clipboardData).getData("text");
    const digits = digitsOnly(text).slice(0, 11);
    input.value = formatFrenchPhone(digits);
  }

  document.addEventListener("submit", (e) => {
    const inputs = e.target.querySelectorAll('input[data-numero-telephone-input="true"]');
    if (inputs.length === 0) return;
    inputs.forEach((input) => {
      const digits = digitsOnly(input.value).slice(0, 11);
      input.value = formatFrenchPhone(digits);
    });
  }, true);

  function initNumeroTelephoneInputs() {
    document
      .querySelectorAll('input[data-numero-telephone-input="true"]')
      .forEach((input) => {
        input.addEventListener("input", onInput);
        input.addEventListener("paste", onPaste);
        const digits = digitsOnly(input.value).slice(0, 11);
        if (digits.length > 0) input.value = formatFrenchPhone(digits);
      });
  }

  document.addEventListener("DOMContentLoaded", initNumeroTelephoneInputs);
})();
