// Carte « Suivi de l'accompagnement » de la fiche évaluation : le clic sur un tag enregistre
// directement la qualification, sauf « Autre » qui ouvre « Précisez » et s'enregistre avec
// « Enregistrer ». Utilise les chemins, constantes et fonctions communes de mise_en_action.js.erb.
// Différences avec le tableau de bord et pièges connus : docs/mise_en_action_ecrans.md

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
  renseigneQualification(evaluationId, $bouton, {
    qualification: QUALIFICATION_AUTRE,
    precision_autre: precisionSaisie($bouton.closest('.qcm'))
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
      effaceErreurPrecision($element.closest('.qcm'));
      const $reponse = $(`#${evaluationId} div[data-reponse='${effectuee}']`);
      $reponse.find('.tag').removeClass('hidden').text(donnees.qualification);
      $reponse.find('.mise-en-action-repondue__date').text(donnees.repondue_le).removeClass('hidden');
      afficheModificationReponse(effectuee, evaluationId);
      fermeQcm(evaluationId);
    },
    error: function (xhr) {
      affichePrecisionEnErreurDepuis(xhr, $element.closest('.qcm'));
    }
  });
}

// Au clic sur « Autre », le DSFR bascule lui-même aria-pressed (tag sélectionnable)
function basculePrecisionAutre($qcm) {
  if (precisionAutreMasquee($qcm)) {
    ouvrePrecisionAutre($qcm);
  } else {
    masquePrecisionAutre($qcm);
  }
}

document.addEventListener('DOMContentLoaded', () => {
  ecouteBoutons($(".suivi-accompagnement-illettrisme .reponse-mise-en-action"), function(evaluationId) {
    $(`#${evaluationId} div[data-reponse='vide']`).removeClass('d-flex').addClass('hidden');
  });
  ecouteBoutons($(".modifier-reponse-mise-en-action"), function(evaluationId) {
    fermeQcm(evaluationId);
    modifieReponseMiseEnAction(evaluationId);
  });
  ecouteBoutons($(".choix-qualification-mise-en-action"), enregistreChoixQualification);
  ecouteBoutons($(".enregistre-precision-autre"), enregistrePrecisionAutre);
  valideAvecEntree($(".suivi-accompagnement-illettrisme input[name=precision_autre]"),
                   '.enregistre-precision-autre');
});
