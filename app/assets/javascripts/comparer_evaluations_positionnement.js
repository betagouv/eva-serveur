function updateHiddenInputs(checkboxes, formElement) {
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

function updateButtonState(checkboxes, compareButton) {
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

    const formElement = compareButton.closest('form');
    updateHiddenInputs(checkboxes, formElement); // Update hidden input fields with selected IDs

    const evaluationSelectedText = document.querySelector('.liste-evaluations-positionnement__nombre-element-selectionnes');
    if (selectedEvaluationIds.length > 0) {
        evaluationSelectedText.textContent =`${selectedEvaluationIds.length} ${evaluationSelectedText.dataset['1EvaluationSelectionnee']}`
    } else {
        evaluationSelectedText.textContent =`${selectedEvaluationIds.length} ${evaluationSelectedText.dataset['nEvaluationsSelectionnees']}`
    }

    checkboxes.forEach(checkbox => {
        if (checkbox.checked) {
            checkbox.disabled = false;
            checkbox.title = "";
        } else {
            const row = checkbox.closest('tr');
            const litteratieDiv = row.querySelector('div[data-litteratie]');
            const numeratieDiv = row.querySelector('div[data-numeratie]');

            const isLitteratie = litteratieDiv && litteratieDiv.getAttribute('data-litteratie') === 'true';
            const isNumeratie = numeratieDiv && numeratieDiv.getAttribute('data-numeratie') === 'true';

            checkbox.disabled = (isLitteratie && litteratieCount >= 2) || (isNumeratie && numeratieCount >= 2);
            checkbox.title = checkbox.disabled ? "Vous ne pouvez pas sélectionner plus de 2 fois une même compétence" : "";
        }
    });
}

document.addEventListener('DOMContentLoaded', function () {
  const evaluationTable = document.querySelector('.liste-evaluations-positionnement__tableau');

  if (evaluationTable) {
    const checkboxes = evaluationTable.querySelectorAll('.fr-checkbox-group input');
    const compareButton = document.getElementById('comparer-evaluation');

    checkboxes.forEach(checkbox => {
      checkbox.addEventListener('change', () => { updateButtonState(checkboxes, compareButton) });
    });

    updateButtonState(checkboxes, compareButton);
  }
});
