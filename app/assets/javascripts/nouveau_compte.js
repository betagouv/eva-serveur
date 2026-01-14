document.addEventListener('DOMContentLoaded', function() {
  const requiredFieldIds = [
    'compte_email',
    'compte_password',
    'compte_password_confirmation'
  ];
  const submitButton = document.getElementById('creer-compte-bouton');
  const cguCheckbox = document.getElementById('compte_cgu_acceptees');

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
    const enable = champsObligatoiresRemplis() && motsDePasseIdentiques() && cguCheckbox && cguCheckbox.checked;
    if (!submitButton) { return; }

    submitButton.disabled = !enable;
    submitButton.classList.toggle('disabled', !enable);
    if (!enable) {
      submitButton.title = I18n.t('creation_compte.cgu_tool_tip');
    } else {
      submitButton.removeAttribute('title');
    }
  }

  requiredFieldIds.forEach(function(id) {
    const el = document.getElementById(id);
    if (el) {
      el.addEventListener('input', activeBoutonSiPret);
    }
  });

  if (cguCheckbox) {
    cguCheckbox.addEventListener('change', activeBoutonSiPret);
  }

  if (submitButton && submitButton.dataset.initialDisabled) {
    submitButton.disabled = true;
  }
  activeBoutonSiPret();
});
