document.addEventListener('DOMContentLoaded', function() {
  const modal = document.getElementById('fr-modal-fusionner');
  if (!modal) return;

  initializeBatchActionFusion();
  initializeFormSubmission(modal);
});

function initializeBatchActionFusion() {
  const fusionButtons = document.querySelectorAll('.batch_action[data-action="fusionner"]');
  
  fusionButtons.forEach(button => {
    button.addEventListener('click', handleFusionButtonClick);
  });
}

function handleFusionButtonClick(event) {
  event.preventDefault();
  event.stopImmediatePropagation();

  const checkedBoxes = getSelectedBeneficiaires();
  
  if (!validateSelection(checkedBoxes)) return;

  const beneficiaires = extractBeneficiairesData(checkedBoxes);
  const sortedBeneficiaires = sortBeneficiairesByDate(beneficiaires);
  
  updateModalContent(sortedBeneficiaires);
  openModal();
}

function getSelectedBeneficiaires() {
  return document.querySelectorAll('input.batch-actions-resource-selection:checked');
}

function validateSelection(checkedBoxes) {
  if (checkedBoxes.length < 2) {
    alert("Sélectionnez au moins deux bénéficiaires pour les fusionner.");
    return false;
  }
  return true;
}

function extractBeneficiairesData(checkedBoxes) {
  return Array.from(checkedBoxes).map(checkbox => {
    const row = checkbox.closest('tr');
    return {
      id: checkbox.value,
      nom: extractNomFromRow(row),
      dateText: extractDateFromRow(row)
    };
  });
}

function extractNomFromRow(row) {
  if (!row) return "Inconnu";
  return row.querySelector('td:nth-child(2)')?.textContent.trim() || "Inconnu";
}

function extractDateFromRow(row) {
  if (!row) return '';
  return row.querySelector('.col-created_at')?.textContent.trim() || '';
}

function sortBeneficiairesByDate(beneficiaires) {
  return [...beneficiaires].sort((a, b) => a.dateText.localeCompare(b.dateText));
}

function updateModalContent(beneficiaires) {
  const modal = document.getElementById('fr-modal-fusionner');
  
  // Mettre à jour la liste
  const listeElements = document.getElementById('liste-elements-a-fusionner');
  listeElements.innerHTML = '';
  beneficiaires.forEach(b => {
    const li = document.createElement('li');
    li.textContent = b.nom;
    listeElements.appendChild(li);
  });
  
  // Mettre à jour le bénéficiaire de rattachement
  const rattacheElement = document.getElementById('beneficiaire-rattache');
  rattacheElement.textContent = beneficiaires[0].nom;
  
  // Stocker les IDs
  modal.dataset.ids = beneficiaires.map(b => b.id).join(',');
}

function openModal() {
  const modal = document.getElementById('fr-modal-fusionner');
  
  if (typeof modal.showModal === 'function') {
    modal.showModal();
  } else {
    modal.style.display = 'block';
  }
  
  modal.classList.add('fr-modal--opened');
}

function initializeFormSubmission(modal) {
  const form = document.getElementById('fusion-form');
  
  form.addEventListener('submit', function(event) {
    prepareHiddenInputs(modal);
  });
}

function prepareHiddenInputs(modal) {
  const ids = modal.dataset.ids.split(',');
  const container = document.getElementById('hidden-ids-container');
  
  container.innerHTML = '';
  
  ids.forEach(id => {
    const input = createHiddenInput('collection_selection[]', id);
    container.appendChild(input);
  });
}

function createHiddenInput(name, value) {
  const input = document.createElement('input');
  input.type = 'hidden';
  input.name = name;
  input.value = value;
  return input;
}
