function activation_bouton_recherche_structure() {
  const siretInput = document.getElementById('siret');
  const submitButton = document.getElementById('recherche-structure-submit');

  if (!siretInput || !submitButton) {
    return;
  }

  function updateSubmitButton() {
    const siretValue = siretInput.value.replace(/\s/g, ''); // Enlever les espaces
    const isValid = siretValue.length >= 14 && /^\d+$/.test(siretValue);
    
    if (isValid) {
      submitButton.classList.remove('disabled');
      submitButton.removeAttribute('disabled');
      submitButton.removeAttribute('title');
    } else {
      submitButton.classList.add('disabled');
      submitButton.setAttribute('disabled', 'disabled');
    }
  }

  // Vérifier au chargement de la page
  updateSubmitButton();

  // Vérifier à chaque modification du champ
  siretInput.addEventListener('input', updateSubmitButton);
  siretInput.addEventListener('keyup', updateSubmitButton);
}

document.addEventListener('DOMContentLoaded', activation_bouton_recherche_structure);

