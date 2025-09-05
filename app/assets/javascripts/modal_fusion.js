document.addEventListener('DOMContentLoaded', function() {
  const modal = document.getElementById('fr-modal-fusionner');
  if (!modal) return;

  document.querySelectorAll('.batch_action[data-action="fusionner"]').forEach(btn => {
    btn.addEventListener('click', function(e) {
      e.preventDefault();
      e.stopImmediatePropagation();

      const checkedBoxes = document.querySelectorAll('input.batch-actions-resource-selection:checked');
      if (checkedBoxes.length < 2) {
        alert("Sélectionnez au moins deux bénéficiaires pour les fusionner.");
        return;
      }

      const beneficiaires = Array.from(checkedBoxes).map(cb => {
        const row = cb.closest('tr');
        const nom = row ? row.querySelector('td:nth-child(2)')?.textContent.trim() || "Inconnu" : "Inconnu";
        const dateText = row ? row.querySelector('.col-created_at')?.textContent.trim() : '';
        
        return {
          id: cb.value,
          nom: nom,
          dateText: dateText
        };
      });

      beneficiaires.sort((a, b) => a.dateText.localeCompare(b.dateText));

      document.getElementById('liste-elements-a-fusionner').innerHTML = 
        beneficiaires.map(b => `<li>${b.nom}</li>`).join('');
      
      document.getElementById('beneficiaire-rattache').textContent = beneficiaires[0].nom;
      modal.dataset.ids = beneficiaires.map(b => b.id).join(',');

      if (typeof modal.showModal === 'function') {
        modal.showModal();
      }
      modal.classList.add('fr-modal--opened');
    });
  });

  document.getElementById('fusion-form').addEventListener('submit', function(e) {
    const ids = modal.dataset.ids.split(',');
    const container = document.getElementById('hidden-ids-container');
    container.innerHTML = '';
    
    ids.forEach(id => {
      const input = document.createElement('input');
      input.type = 'hidden';
      input.name = 'collection_selection[]';
      input.value = id;
      container.appendChild(input);
    });
  });
});
