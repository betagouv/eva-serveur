document.addEventListener('DOMContentLoaded', function () {
  if (document.querySelector('.liste-evaluations-positionnement__tableau')) {
    const checkboxes = document.querySelectorAll('.liste-evaluations-positionnement__tableau .fr-checkbox-group input');
    const compareButton = document.getElementById('comparer-evaluation');
    const evaluationSelectedText = document.querySelector('.liste-evaluations-positionnement__nombre-element-selectionnes');

    function updateButtonState() {
      let litteratieCount = 0;
      let numeratieCount = 0;

      // Comptabilise le nombre de checkboxes cochées pour chaque type
      checkboxes.forEach(checkbox => {
        const row = checkbox.closest('tr');
        const litteratieDiv = row.querySelector('div[data-litteratie]');
        const numeratieDiv = row.querySelector('div[data-numeratie]');

        if (checkbox.checked) {
          if (litteratieDiv && litteratieDiv.getAttribute('data-litteratie') === 'true') {
            litteratieCount++;
          }
          if (numeratieDiv && numeratieDiv.getAttribute('data-numeratie') === 'true') {
            numeratieCount++;
          }
        }
      });

      // Active ou désactive chaque checkbox en fonction des règles de sélection
      checkboxes.forEach(checkbox => {
        const row = checkbox.closest('tr');
        const litteratieDiv = row.querySelector('div[data-litteratie]');
        const numeratieDiv = row.querySelector('div[data-numeratie]');

        const isLitteratie = litteratieDiv && litteratieDiv.getAttribute('data-litteratie') === 'true';
        const isNumeratie = numeratieDiv && numeratieDiv.getAttribute('data-numeratie') === 'true';

        if (!checkbox.checked) {
          // Désactiver les checkbox si les limites sont atteintes
          checkbox.disabled = (isLitteratie && litteratieCount >= 2) || (isNumeratie && numeratieCount >= 2);
          checkbox.title = "Vous ne pouvez pas sélectionner plus de 2 fois une même compétence"
        } else {
          // Assurez-vous que les checkbox déjà cochées restent activées
          checkbox.disabled = false;
          checkbox.title = ""
        }
      });

      // Vérifie s'il y a des cases cochées pour activer/désactiver le bouton
      const isAnyChecked = litteratieCount > 0 || numeratieCount > 0;
      compareButton.disabled = !isAnyChecked;

      // Met à jour le texte affichant le nombre d'évaluations sélectionnées
      const checkedCount = Array.from(checkboxes).filter(checkbox => checkbox.checked).length;
      evaluationSelectedText.textContent = checkedCount > 0 ?
        `${checkedCount} évaluation${checkedCount > 1 ? 's' : ''} sélectionnée${checkedCount > 1 ? 's' : ''}` : '';
    }

    // Ajoute un écouteur d'événement à chaque checkbox
    checkboxes.forEach(checkbox => {
      checkbox.addEventListener('change', updateButtonState);
    });

    // Initialise l'état du bouton et du texte au chargement de la page
    updateButtonState();
  };
});
