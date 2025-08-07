document.addEventListener('DOMContentLoaded', function () {
  const evaluationTable = document.querySelector('.liste-evaluations-positionnement__tableau');

  if (evaluationTable) {
    const checkboxes = evaluationTable.querySelectorAll('.fr-checkbox-group input');
    const compareButton = document.getElementById('comparer-evaluation');
    const evaluationSelectedText = document.querySelector('.liste-evaluations-positionnement__nombre-element-selectionnes');
    const formElement = compareButton.closest('form'); // Assuming the button is inside a form
    
    function updateHiddenInputs() {
      // Remove existing hidden inputs
      formElement.querySelectorAll('input[name="evaluation_ids[]"]').forEach(input => input.remove());

      // Create new hidden inputs for each selected evaluation
      Array.from(checkboxes).filter(checkbox => checkbox.checked)
        .forEach(checkbox => {
          const evaluationId = checkbox.closest('tr').getAttribute('data-id');
          const hiddenInput = document.createElement('input');
          hiddenInput.type = 'hidden';
          hiddenInput.name = 'evaluation_ids[]';
          hiddenInput.value = evaluationId;
          formElement.appendChild(hiddenInput);
        });
    }

    function updateButtonState() {
      let litteratieCount = 0;
      let numeratieCount = 0;
      const selectedEvaluationIds = [];

      checkboxes.forEach(checkbox => {
        const row = checkbox.closest('tr');
        const litteratieDiv = row.querySelector('div[data-litteratie]');
        const numeratieDiv = row.querySelector('div[data-numeratie]');
        const evaluationId = row.getAttribute('data-id');

        if (checkbox.checked) {
          if (litteratieDiv && litteratieDiv.getAttribute('data-litteratie') === 'true') {
            litteratieCount++;
          }
          if (numeratieDiv && numeratieDiv.getAttribute('data-numeratie') === 'true') {
            numeratieCount++;
          }
          selectedEvaluationIds.push(evaluationId);
        }
      });

      compareButton.disabled = selectedEvaluationIds.length === 0;

      updateHiddenInputs(); // Update hidden input fields with selected IDs

      evaluationSelectedText.textContent = selectedEvaluationIds.length > 0 ?
        `${selectedEvaluationIds.length} évaluation${selectedEvaluationIds.length > 1 ? 's' : ''} sélectionnée${selectedEvaluationIds.length > 1 ? 's' : ''}` : '';

      checkboxes.forEach(checkbox => {
        const row = checkbox.closest('tr');
        const litteratieDiv = row.querySelector('div[data-litteratie]');
        const numeratieDiv = row.querySelector('div[data-numeratie]');

        const isLitteratie = litteratieDiv && litteratieDiv.getAttribute('data-litteratie') === 'true';
        const isNumeratie = numeratieDiv && numeratieDiv.getAttribute('data-numeratie') === 'true';

        if (!checkbox.checked) {
          checkbox.disabled = (isLitteratie && litteratieCount >= 2) || (isNumeratie && numeratieCount >= 2);
          checkbox.title = checkbox.disabled ? "Vous ne pouvez pas sélectionner plus de 2 fois une même compétence" : "";
        } else {
          checkbox.disabled = false;
          checkbox.title = "";
        }
      });
    }

    checkboxes.forEach(checkbox => {
      checkbox.addEventListener('change', updateButtonState);
    });

    updateButtonState();
  }
});
