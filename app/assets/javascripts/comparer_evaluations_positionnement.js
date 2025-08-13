function estTestee(row, competence) {
    const donnees = row.querySelector(`div[data-${competence}]`);
    return donnees && donnees.getAttribute(`data-${competence}`) === 'true';
}

function activationCheckbox(checkboxes) {
    let litteratieCount = 0;
    let numeratieCount = 0;

    checkboxes
        .filter(checkbox => checkbox.checked)
        .forEach(checkbox => {
            const row = checkbox.closest('tr');
            if (estTestee(row, 'litteratie')) { litteratieCount++; }
            if (estTestee(row, 'numeratie')) { numeratieCount++; }
        });

    checkboxes.forEach(checkbox => {
        checkbox.disabled = false;
        checkbox.title = "";
        const row = checkbox.closest('tr');
        if (!checkbox.checked &&
            (estTestee(row, 'litteratie') && litteratieCount >= 2 ||
             estTestee(row, 'numeratie') && numeratieCount >= 2)){
            checkbox.disabled = true;
            checkbox.title = I18n.t("admin.beneficiaires.liste_evaluations_positionnement.indication");
        }
    });
}

function ajouteIdSelectionnesAuFormulaire(checkboxes, formElement) {
    // Supprime les champs cachés existants
    formElement.querySelectorAll('input[name="evaluation_ids[]"]').forEach(input => input.remove());

    // Crée de nouveaux champs cachés pour chaque évaluation sélectionnée
    checkboxes.filter(checkbox => checkbox.checked)
        .forEach(checkbox => {
            const evaluationId = checkbox.closest('tr').getAttribute('data-id');
            const hiddenInput = document.createElement('input');
            hiddenInput.type = 'hidden';
            hiddenInput.name = 'evaluation_ids[]';
            hiddenInput.value = evaluationId;
            formElement.appendChild(hiddenInput);
        });
}

function activationBoutonCompare(checkboxes) {
    const compareButton = document.getElementById('comparer-evaluation');
    const nombreEvaluationsSelectionnees = checkboxes.filter(checkbox => checkbox.checked).length;
    compareButton.disabled = nombreEvaluationsSelectionnees === 0;

    const formElement = compareButton.closest('form');
    ajouteIdSelectionnesAuFormulaire(checkboxes, formElement);
}

function actualiseInformationSelection(checkboxes) {
    const nombreEvaluationsSelectionnees = checkboxes.filter(checkbox => checkbox.checked).length;
    const texte = (nombreEvaluationsSelectionnees <= 1) ?
        I18n.t("admin.beneficiaires.liste_evaluations_positionnement.1-evaluation-selectionnee") :
        I18n.t("admin.beneficiaires.liste_evaluations_positionnement.n-evaluations-selectionnees");
    const node = document.querySelector('.liste-evaluations-positionnement__nombre-element-selectionnes');
    node.textContent =`${nombreEvaluationsSelectionnees} ${texte}`
}

document.addEventListener('DOMContentLoaded', function () {
  const evaluationTable = document.querySelector('.liste-evaluations-positionnement__tableau');

  if (evaluationTable) {
    const checkboxes = Array.from(evaluationTable.querySelectorAll('.fr-checkbox-group input'));

    const cbCheckbox = () => {
        activationCheckbox(checkboxes);
        activationBoutonCompare(checkboxes);
        actualiseInformationSelection(checkboxes);
    }

    checkboxes.forEach(checkbox => {
      checkbox.addEventListener('change', cbCheckbox);
    });

    cbCheckbox();
  }
});
