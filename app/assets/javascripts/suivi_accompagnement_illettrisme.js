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
      if (passeALaPersonneSuivante(evaluationId)) return;

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

// Choix de la date de revue après « Pas encore » : chaque puce porte son choix,
// le serveur en déduit la date (MiseEnAction#reporte_dans)
function enregistreChoixDateRevue(evaluationId, $tag) {
  // Un délai proposé referme « Choisir une date », comme un autre choix referme « Précisez »
  const $qcm = $tag.closest('.qcm');
  $qcm.find('.choisir-date-revue').attr('aria-pressed', 'false');
  masqueChampDateRevue($qcm.find('.zone-date-revue'));
  renseigneDateRevue(evaluationId, $tag.attr('data-choix-date-revue'));
}

// « Choisir une date » ouvre ou referme le champ date, comme « Autre » ouvre « Précisez »
function basculeChampDateRevue(evaluationId, $tag) {
  const $zone = $tag.closest('.qcm').find('.zone-date-revue');
  if ($zone.hasClass('zone-date-revue--masquee')) {
    $zone.removeClass('zone-date-revue--masquee');
    $zone.find('input[name=date_revue]').trigger('focus');
  } else {
    masqueChampDateRevue($zone);
  }
}

function masqueChampDateRevue($zone) {
  $zone.addClass('zone-date-revue--masquee');
  $zone.find('input[name=date_revue]').val('');
  effaceErreurChamp($zone.find('.champ-date-revue'));
}

function enregistreDateChoisie(evaluationId, $bouton) {
  renseigneDateRevue(evaluationId, CHOIX_DATE_PRECISE,
                     $bouton.closest('.qcm').find('input[name=date_revue]').val());
}

function renseigneDateRevue(evaluationId, choixDateRevue, dateRevue) {
  const $champ = $(`#${evaluationId} .champ-date-revue`);
  $.ajax({
    method: 'PATCH',
    url: chemin_renseigner_date_revue.replace('ID_EVALUATION', evaluationId),
    data: { choix_date_revue: choixDateRevue, date_revue: dateRevue },
    dataType: "json",
    success: function (donnees) {
      if (passeALaPersonneSuivante(evaluationId)) return;

      const $reponse = $(`#${evaluationId} div[data-reponse='${REPONSE_PAS_ENCORE}']`);
      $reponse.find('.tag').removeClass('hidden').text(donnees.relance_prevue);
      $reponse.find('.mise-en-action-repondue__date').text(donnees.repondue_le).removeClass('hidden');
      afficheModificationReponse(REPONSE_PAS_ENCORE, evaluationId);
      effaceErreurChamp($champ);
      fermeQcm(evaluationId);
    },
    error: function (xhr) {
      const erreur = xhr.responseJSON && xhr.responseJSON.erreur;
      if (erreur) afficheErreurChamp($champ, erreur);
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

// Répondre efface côté serveur la qualification des autres réponses : l'écran fait de même,
// comme le changement entre Oui et Non referme « Précisez » (enregistreReponseMiseEnAction)
function oublieAutresReponses(evaluationId, reponse) {
  if (reponse === REPONSE_PAS_ENCORE) {
    fermePrecisionAutre($(`#${evaluationId} .questions-remediation`));
    fermePrecisionAutre($(`#${evaluationId} .questions-difficulte`));
  } else {
    const $dateRevue = $(`#${evaluationId} .questions-date-revue`);
    $dateRevue.find('.choisir-date-revue').attr('aria-pressed', 'false');
    masqueChampDateRevue($dateRevue.find('.zone-date-revue'));
  }
}

document.addEventListener('DOMContentLoaded', () => {
  ecouteBoutons($(".suivi-accompagnement-illettrisme .reponse-mise-en-action"), function(evaluationId, $bouton) {
    $(`#${evaluationId} div[data-reponse='vide']`).removeClass('d-flex').addClass('hidden');
    oublieAutresReponses(evaluationId, $bouton.data('reponse'));
  });
  ecouteBoutons($(".modifier-reponse-mise-en-action"), function(evaluationId) {
    fermeQcm(evaluationId);
    modifieReponseMiseEnAction(evaluationId);
  });
  ecouteBoutons($(".choix-qualification-mise-en-action"), enregistreChoixQualification);
  ecouteBoutons($(".enregistre-precision-autre"), enregistrePrecisionAutre);
  ecouteBoutons($(".choix-date-revue"), enregistreChoixDateRevue);
  ecouteBoutons($(".choisir-date-revue"), basculeChampDateRevue);
  ecouteBoutons($(".enregistre-date-revue"), enregistreDateChoisie);
  valideAvecEntree($(".suivi-accompagnement-illettrisme input[name=precision_autre]"),
                   '.enregistre-precision-autre');
  valideAvecEntree($(".suivi-accompagnement-illettrisme input[name=date_revue]"),
                   '.enregistre-date-revue');
});
