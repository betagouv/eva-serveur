// Carte « Suivi de l'accompagnement » de la fiche évaluation : le clic sur un tag enregistre
// directement la qualification, sauf « Autre » qui ouvre « Précisez » et s'enregistre avec
// « Enregistrer ». Utilise les chemins, constantes et fonctions communes de mise_en_action.js.erb.
// Différences avec le tableau de bord et pièges connus : docs/mise_en_action_ecrans.md

const CLASSE_PRECISION_MASQUEE = 'qualification-mise-en-action__precision--masquee';

function enregistreChoixQualification(evaluationId, $tag) {
  const $qcm = $tag.closest('.qcm');
  if ($tag.data('qualification') === QUALIFICATION_AUTRE) {
    basculePrecisionAutre($qcm);
    return;
  }
  fermePrecisionAutre($qcm);
  renseigneQualification(evaluationId, $tag, { qualification: $tag.data('qualification') });
}

function enregistrePrecisionAutre(evaluationId, $bouton) {
  const $qcm = $bouton.closest('.qcm');
  renseigneQualification(evaluationId, $bouton, {
    qualification: QUALIFICATION_AUTRE,
    precision_autre: $qcm.find('input[name=precision_autre]').val()
  });
}

function renseigneQualification(evaluationId, $element, donneesQualification) {
  const effectuee = miseEnActionEffectuee($element);

  $.ajax({
    method: 'PATCH',
    url: chemin_renseigner_qualification.replace('ID_EVALUATION', evaluationId),
    data: { effectuee, ...donneesQualification },
    dataType: "json",
    success: function (donnees) {
      const $reponse = $(`#${evaluationId} div[data-reponse='${effectuee}']`);
      $reponse.find('.tag').removeClass('hidden').text(donnees.qualification);
      $reponse.find('.mise-en-action-repondue__date').text(donnees.repondue_le);
      $reponse.find('.mise-en-action-repondue__date, .mise-en-action-repondue__separateur').removeClass('hidden');
      afficheModificationReponse(effectuee, evaluationId);
      fermeQcm(evaluationId);
    },
    error: function (xhr) {
      const erreur = xhr.responseJSON && xhr.responseJSON.erreur;
      if (erreur) affichePrecisionEnErreur($element.closest('.qcm'), erreur);
    }
  });
}

// Au clic sur « Autre », le DSFR bascule lui-même aria-pressed (tag sélectionnable)
function basculePrecisionAutre($qcm) {
  if ($qcm.find(`.${CLASSE_PRECISION_MASQUEE}`).length) {
    ouvrePrecisionAutre($qcm);
  } else {
    masquePrecisionAutre($qcm);
  }
}

function ouvrePrecisionAutre($qcm) {
  $qcm.find('.qualification-mise-en-action__precision').removeClass(CLASSE_PRECISION_MASQUEE);
  $qcm.find('input[name=precision_autre]').trigger('focus');
}

// Un autre choix referme « Précisez » : le tag « Autre » n'a pas été cliqué, on le désélectionne
function fermePrecisionAutre($qcm) {
  $qcm.find(`[data-qualification='${QUALIFICATION_AUTRE}']`).attr('aria-pressed', 'false');
  masquePrecisionAutre($qcm);
}

function masquePrecisionAutre($qcm) {
  $qcm.find('.qualification-mise-en-action__precision').addClass(CLASSE_PRECISION_MASQUEE);
  $qcm.find('input[name=precision_autre]').val('');
  effaceErreurPrecision($qcm);
}

function affichePrecisionEnErreur($qcm, message) {
  const $groupe = $qcm.find('.precision-autre');
  effaceErreurPrecision($qcm);
  $groupe.addClass('fr-input-group--error');
  $groupe.find('.fr-label').addClass('fr-label--error');
  $groupe.find('.fr-message--info').addClass('hidden');
  // En premier : le DSFR espace le champ de son premier message (.fr-message:first-child)
  $groupe.find('.fr-messages-group').prepend($('<p class="fr-message fr-message--error">').text(message));
  $groupe.find('.fr-input').addClass('fr-input--error').trigger('focus');
}

function effaceErreurPrecision($qcm) {
  const $groupe = $qcm.find('.precision-autre');
  $groupe.removeClass('fr-input-group--error');
  $groupe.find('.fr-label').removeClass('fr-label--error');
  $groupe.find('.fr-input').removeClass('fr-input--error');
  $groupe.find('.fr-message--error').remove();
  $groupe.find('.fr-message--info').removeClass('hidden');
}

document.addEventListener('DOMContentLoaded', () => {
  ecouteBoutons($(".suivi-accompagnement-illettrisme .reponse-mise-en-action"), function(evaluationId) {
    $(`#${evaluationId} div[data-reponse='vide']`).removeClass('d-flex').addClass('hidden');
  });
  ecouteBoutons($(".changer-reponse-mise-en-action"), function(evaluationId) {
    fermeQcm(evaluationId);
    modifieReponseMiseEnAction(evaluationId);
  });
  ecouteBoutons($(".choix-qualification-mise-en-action"), enregistreChoixQualification);
  ecouteBoutons($(".enregistre-precision-autre"), enregistrePrecisionAutre);
  $("input[name=precision_autre]").on('keydown', function(event) {
    if (event.key !== 'Enter') return;
    event.preventDefault();
    $(event.currentTarget).closest('.qcm').find('.enregistre-precision-autre').trigger('click');
  });
});
