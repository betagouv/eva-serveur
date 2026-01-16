document.addEventListener('DOMContentLoaded', function() {
  const requiredFieldIds = [
    'compte_email',
    'compte_password',
    'compte_password_confirmation'
  ];
  const submitButton = document.getElementById('creer-compte-bouton');

  function champsObligatoiresRemplis() {
    return requiredFieldIds.every(function(id) {
      const el = document.getElementById(id);
      return el && el.value.trim().length > 0;
    });
  }

  function motsDePasseIdentiques() {
    const password = document.getElementById('compte_password');
    const confirmation = document.getElementById('compte_password_confirmation');
    return password && confirmation && password.value === confirmation.value;
  }

  function activeBoutonSiPret() {
    const enable = champsObligatoiresRemplis() && motsDePasseIdentiques();
    if (!submitButton) { return; }

    submitButton.disabled = !enable;
    submitButton.classList.toggle('disabled', !enable);
  }

  requiredFieldIds.forEach(function(id) {
    const el = document.getElementById(id);
    if (el) {
      el.addEventListener('input', activeBoutonSiPret);
    }
  });

  if (submitButton && submitButton.dataset.initialDisabled) {
    submitButton.disabled = true;
  }
  activeBoutonSiPret();
});
