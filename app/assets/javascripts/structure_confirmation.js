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
  initStructureParametrageFormState();
  initStructureFormLinks();
}

function initStructureParametrageFormState() {
  const form = document.querySelector('form[action*="inscription/structure"]');
  if (!form) return;

  const requiredFields = [
    form.querySelector('input[name$="[nom]"]'),
    form.querySelector('select[name$="[type_structure]"]'),
    form.querySelector('select[name$="[opco_id]"]')
  ];

  const boutonCreer = document.getElementById('creer-structure-btn');
  const boutonConfirmer = document.getElementById('confirmer-creation-structure');

  function getModalFromButton(button) {
    if (!button) return null;
    const modalId = button.dataset.modalTarget || button.getAttribute('aria-controls');
    if (!modalId) return null;
    return document.getElementById(modalId);
  }

  function ouvrirModal(modal) {
    if (!modal) return;
    modal.classList.add('fr-modal--opened');
    modal.setAttribute('aria-hidden', 'false');
  }

  function fermerModal(modal) {
    if (!modal) return;
    modal.classList.remove('fr-modal--opened');
    modal.setAttribute('aria-hidden', 'true');
  }

  function initModalFallbackControls(modal, openerButton) {
    if (!modal || modal.dataset.fallbackBound === 'true') return;
    modal.dataset.fallbackBound = 'true';

    modal.addEventListener('click', function(event) {
      if (event.target === modal) {
        event.preventDefault();
        event.stopImmediatePropagation();
        fermerModal(modal);
      }
    }, true);

    modal.querySelectorAll('[aria-controls="' + modal.id + '"]').forEach(function(closeTrigger) {
      closeTrigger.addEventListener('click', function(event) {
        if (closeTrigger.type === 'submit') return;
        event.preventDefault();
        event.stopImmediatePropagation();
        fermerModal(modal);
        if (openerButton) openerButton.focus();
      }, true);
    });

    document.addEventListener('keydown', function(event) {
      if (event.key === 'Escape' && modal.classList.contains('fr-modal--opened')) {
        event.preventDefault();
        fermerModal(modal);
        if (openerButton) openerButton.focus();
      }
    });
  }

  function champRempli(element) {
    if (!element) return false;
    return element.value && element.value.trim().length > 0;
  }

  function formulaireComplet() {
    const champsOk = requiredFields.every(function(field) {
      return champRempli(field);
    });
    return champsOk;
  }

  function majBoutons() {
    const enable = formulaireComplet();
    [ boutonCreer, boutonConfirmer ].forEach(function(button) {
      if (!button) return;
      button.disabled = !enable;
      button.classList.toggle('disabled', !enable);
    });
  }

  requiredFields.forEach(function(field) {
    if (!field) return;
    field.addEventListener('input', majBoutons);
    field.addEventListener('change', majBoutons);
  });

  if (boutonCreer) {
    const modal = getModalFromButton(boutonCreer);
    initModalFallbackControls(modal, boutonCreer);

    boutonCreer.addEventListener('click', function(event) {
      if (boutonCreer.disabled) return;
      event.preventDefault();
      event.stopImmediatePropagation();
      ouvrirModal(modal);
    });
  }

  majBoutons();
}
