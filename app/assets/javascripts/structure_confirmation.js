function activation_bouton_rejoindre(structure_confirmee) {
  let bouton_rejoindre = document.getElementById('rejoindre-structure-btn');
  if (!bouton_rejoindre) return;
  
  if (structure_confirmee) {
    bouton_rejoindre.classList.remove('disabled');
    bouton_rejoindre.removeAttribute('disabled');
  } else {
    bouton_rejoindre.classList.add('disabled');
    bouton_rejoindre.setAttribute('disabled', 'disabled');
  }
}

function structure_confirmation_submit() {
  let checkbox = document.getElementById('compte_structure_confirmee');
  if (!checkbox) return;
  
  let structure_confirmee = checkbox.checked;
  activation_bouton_rejoindre(structure_confirmee);
  
  checkbox.addEventListener('change', function() {
    activation_bouton_rejoindre(this.checked);
  });

  initStructureFormLinks();
}

function activation_bouton_creer(structure_confirmee) {
  let bouton_creer = document.getElementById('creer-structure-btn');
  if (!bouton_creer) return;
  
  if (structure_confirmee) {
    bouton_creer.classList.remove('disabled');
    bouton_creer.removeAttribute('disabled');
  } else {
    bouton_creer.classList.add('disabled');
    bouton_creer.setAttribute('disabled', 'disabled');
  }
}

function activation_bouton_confirmer(structure_confirmee) {
  let bouton_confirmer = document.getElementById('confirmer-infos-btn');
  if (!bouton_confirmer) return;
  
  if (structure_confirmee) {
    bouton_confirmer.classList.remove('disabled');
    bouton_confirmer.removeAttribute('disabled');
  } else {
    bouton_confirmer.classList.add('disabled');
    bouton_confirmer.setAttribute('disabled', 'disabled');
  }
}

// Gérer la soumission du formulaire via les liens avec data-submit-form
function initStructureFormLinks() {
  document.querySelectorAll('a[data-submit-form]').forEach(function(link) {
    link.addEventListener('click', function(e) {
      e.preventDefault();
      var form = this.closest('form');
      if (form) {
        // Créer un input hidden pour le commit
        var commitInput = document.createElement('input');
        commitInput.type = 'hidden';
        commitInput.name = 'commit';
        commitInput.value = this.dataset.commit;
        form.appendChild(commitInput);

        // Changer l'action du formulaire si nécessaire
        if (this.dataset.formaction) {
          form.action = this.dataset.formaction;
        }

        form.submit();
      }
    });
  });
}

function structure_creation_confirmation_submit() {
  // Chercher la checkbox dans le formulaire de structure
  // Le name peut être structure[structure_confirmee] ou structure_locale[structure_confirmee]
  let form = document.querySelector('form[action*="inscription/structure"]');
  if (!form) {
    console.error('Formulaire de structure non trouvé');
    return;
  }
  
  // Chercher toutes les checkboxes dans le formulaire et trouver celle avec structure_confirmee
  let checkboxes = form.querySelectorAll('input[type="checkbox"]');
  let checkbox = null;
  
  for (let cb of checkboxes) {
    if (cb.name && cb.name.includes('structure_confirmee')) {
      checkbox = cb;
      break;
    }
  }
  
  if (!checkbox) {
    console.error('Checkbox structure_confirmee non trouvée dans le formulaire');
    return;
  }
  
  let structure_confirmee = checkbox.checked;
  activation_bouton_confirmer(structure_confirmee);
  
  checkbox.addEventListener('change', function() {
    activation_bouton_confirmer(this.checked);
  });

  initStructureFormLinks();
}

function structure_creation_parametrage_submit() {
  initStructureFormLinks();
}
