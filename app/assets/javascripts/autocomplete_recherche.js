function afficheRecherche(boutonAjout, formulaireRecherche, initAutocomplete) {
  boutonAjout.click(function () {
    boutonAjout.hide()
    formulaireRecherche.show()
    initAutocomplete();
  });
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

  accessibleAutocomplete({
    element: element,
    id: id,
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
    tNoResults: () => I18n.t('recherche_compte.no_results'),
    tStatusNoResults: () => I18n.t('recherche_compte.no_results'),
    tStatusSelectedOption: (selectedOption, length, index) => `${selectedOption} ${index + 1} sur ${length} est sélectionné`,
    tAssistiveHint: () => I18n.t('recherche_compte.assistive_hint'),
    tStatusQueryTooShort: (minQueryLength) => `Entrez au moins ${minQueryLength} characters pour avoir un résultat`,
    tStatusResults: (length, contentSelectedOption) => {
        const words = {
            result: (length === 1) ? 'résultat' : 'résultats',
            is: (length === 1) ? 'disponible' : 'disponibles'
        };
        return `${length} ${words.result} ${words.is}. ${contentSelectedOption}`;
    }
  });

  const input = element.querySelector("input");
  input.type = 'search';

  if (focus) {
    input.focus();
  }
}
