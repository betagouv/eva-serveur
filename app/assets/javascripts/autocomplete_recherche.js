function extraitCodePostal(texte) {
  const match = texte.match(/(\d{5})/);
  return match ? match[1] : null;
}

function escapeHTML(str) {
  return str.replace(/[&<>'"]/g, tag => {
    const entityMap = {
      '&': '&amp;',
      '<': '&lt;',
      '>': '&gt;',
      "'": '&#39;',
      '"': '&quot;'
    };
    return entityMap[tag] || tag
  });
}

function construitReponse(item, codePostalSaisi) {
  const ville = item.nom;
  let codePostal = '';
  if (codePostalSaisi && item.codesPostaux.length > 1) {
    codePostal = codePostalSaisi
  } else {
    codePostal = item.codesPostaux[0];
  }
  const label = `${ville} (${codePostal})`;
  return { value: label, ville: ville, code_postal: codePostal };
}

function afficheRecherche(boutonAjout, formulaireRecherche, initAutocomplete) {
  boutonAjout.click(function () {
    boutonAjout.hide()
    formulaireRecherche.show()
    initAutocomplete();
  });
}

function requeteCommunes(requete, reponse, $) {
  $('#bouton-chercher')
    .prop("disabled", true)
    .addClass("disabled");
  if (!requete.match(/^\d{1,4}$/)) {
    let data = { limit: 6, type: 'commune-actuelle,arrondissement-municipal' };
    if (extraitCodePostal(requete)) {
      data.codePostal = extraitCodePostal(requete);
    } else {
      data.nom = requete;
      data.boost = 'population';
    }
    $.ajax({
      url: "https://geo.api.gouv.fr/communes",
      data: data,
      dataType: "json",
      success: function (datas) {
        reponse($.map(datas, function (item) {
          return construitReponse(item, data.codePostal);
        }))
      },
      error: function () {
        reponse([]);
      }
    });
  }
}

function getUrlParameter(name) {
  const urlParams = new URLSearchParams(window.location.search);
  return urlParams.get(name);
}

function initialiseAutocomplete(options) {
  const {
      focus,
      element,
      id,
      name,
      defaultValue,
      minLength,
      placeholder,
      source,
      templates,
      onConfirm
  } = options;

  const autocomplete = accessibleAutocomplete({
    element: element,
    id: id, // id de l'input créé a utiliser dans l'attribut for du label
    name: name,
    defaultValue: defaultValue || '',
    showAllValues: false,
    autoselect: false,
    displayMenu: 'overlay',
    minLength: minLength,
    placeholder: placeholder,
    source: source,
    templates: {
      inputValue: (reponse) => {
          if (typeof reponse == 'string') { // quand defaultValue contient une string non vide
              return reponse;
          }
          return templates.inputValue(reponse);
      },
      suggestion: (reponse) => {
        if (typeof reponse == 'string') { // quand defaultValue contient une string non vide
          return reponse;
        }
        else {
            return templates.suggestion(reponse);
        }
      }
    },

    onConfirm: onConfirm,
    tNoResults: () => "Aucun résultat trouvé",
    tStatusNoResults: () => "Aucun résultat trouvé",
    tStatusSelectedOption: (selectedOption, length, index) => `${selectedOption} ${index + 1} sur ${length} est selectionné`,
    tAssistiveHint: () => "Quand le résultat de l'autocomplétion est disponible, utilisez les flèches hautes et basses pour passer en revue et la touche entrer pour sélectionner.",
    tStatusQueryTooShort: (minQueryLength) => `Entrez au moins ${minQueryLength} characters pour avoir un résultat`,
    tStatusResults: (length, contentSelectedOption) => {
        const words = {
            result: (length === 1) ? 'resultat' : 'resultats',
            is: (length === 1) ? 'disponible' : 'disponibles'
        };

        return "<span>{length} {words.result} {words.is}. {contentSelectedOption}</span>";
    }
  });

  const input = element.querySelector("input");
  input.type = 'search';

  if (focus) {
    input.focus();
  }
}

document.addEventListener('DOMContentLoaded', () => {
  const container = document.querySelector('#recherche-structure-autocomplete-container');
  if(!container){ return; }

  initialiseAutocomplete({
    focus: !getUrlParameter('code_postal'),
    element: container,
    id: 'recherche-structure-autocomplete',
    name: 'ville_ou_code_postal',
    defaultValue: getUrlParameter('ville_ou_code_postal'),
    placeholder: I18n.t('recherche_structure_component.placeholder_recherche'),
    minLength: 3,
    source: (requete, reponse) => { requeteCommunes(requete, reponse, $); },
    templates: {
      inputValue: (reponse) => reponse ? reponse.value : '',
      suggestion: (reponse) => `
      <div class="commune-suggestion">
        <strong>${escapeHTML(reponse.ville)}</strong>
        (${escapeHTML(reponse.code_postal)})
      </div>
      `
    },
    onConfirm: (selectedItem) => {
      if (! selectedItem) return;

      $('#code_postal').val(selectedItem.code_postal);

      const disabled = selectedItem.value == '';
      $('#bouton-chercher')
        .prop("disabled", disabled)
        .toggleClass('disabled', disabled);
    },
  });
});
