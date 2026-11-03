// Mise en action sur le tableau de bord : questionnaire à boutons radio, « Valider » et « Ignorer ».
// Utilise les chemins et fonctions communes de mise_en_action.js.erb.
// Différences avec la fiche évaluation : docs/mise_en_action_ecrans.md

// Choisir « Autre » ouvre « Précisez », choisir une autre réponse le referme
function activeBoutonValider() {
  const radios = $('input[name=reponse_qcm]');

  radios.each(function() {
    const radio = $(this)
    radio.on("click", function(event) {
      const $qcm = radio.closest('.qcm');
      if (radio.val() === QUALIFICATION_AUTRE) {
        if (precisionAutreMasquee($qcm)) {
          ouvrePrecisionAutre($qcm);
        }
      } else {
        masquePrecisionAutre($qcm);
      }
      metAJourBoutonValider($qcm);
    })
  });
}

// « Valider » s'active dès qu'une réponse est cochée ; pour « Autre », une fois « Précisez » rempli
function metAJourBoutonValider($qcm) {
  const reponse = $qcm.find('input[name=reponse_qcm]:checked').val();
  const precisionManquante = reponse === QUALIFICATION_AUTRE && precisionSaisie($qcm).trim() === '';
  $qcm.find('.valide-qcm').prop('disabled', !reponse || precisionManquante);
}

function enregistreQualificationMiseEnAction(evaluationId, $bouton, { ignorer }) {
  const $qcm = $bouton.closest('.qcm');
  const effectuee = miseEnActionEffectuee($bouton)
  const qualification = ignorer ? 'indetermine' : reponseSelectionnee(evaluationId, nomQcm(effectuee));
  const donnees = { effectuee, qualification };
  if (qualification === QUALIFICATION_AUTRE) donnees.precision_autre = precisionSaisie($qcm);

  $.ajax({
    method: 'PATCH',
    url: chemin_renseigner_qualification.replace('ID_EVALUATION', evaluationId),
    data: donnees,
    dataType: "json",
    success: function () {
      if (qualification === QUALIFICATION_AUTRE) {
        $qcm.attr('data-precision-enregistree', donnees.precision_autre.trim());
      } else {
        fermePrecisionAutre($qcm);
      }
      afficheModificationReponse(effectuee, evaluationId);
      fermeQcm(evaluationId);
    },
    error: function (xhr) {
      affichePrecisionEnErreurDepuis(xhr, $qcm);
    }
  });
}

function reponseSelectionnee(evaluationId, qcm) {
  return $(`#${evaluationId} .questions-${qcm} input[name=reponse_qcm]:checked`).val();
}

document.addEventListener('DOMContentLoaded', () => {
  ecouteBoutons($(".valide-qcm"), function(evaluationId, $bouton) {
    enregistreQualificationMiseEnAction(evaluationId, $bouton, { ignorer: false });
  });
  ecouteBoutons($(".bouton-fermer"), function(evaluationId, $bouton) {
    enregistreQualificationMiseEnAction(evaluationId, $bouton, { ignorer: true })
  });
  ecouteBoutons($(".valide-qcm"), function(evaluationId, $bouton) {
    const effectuee = miseEnActionEffectuee($bouton)
    const qcm = nomQcm(effectuee)
    const reponse = reponseSelectionnee(evaluationId, qcm);
    const traduction = I18n.t(`activerecord.attributes.mise_en_action.${qcm}.${reponse}`)
    $(`div[data-reponse='${effectuee}'] .tag`).removeClass('hidden').text(traduction);
  });
  ecouteBoutons($(".bouton-fermer"), function(evaluationId, $bouton) {
    const effectuee = miseEnActionEffectuee($bouton)
    $(`div[data-reponse='${effectuee}'] .tag`).addClass('hidden')
  });
  activeBoutonValider();
  $("input[name=reponse_qcm]").on('focus', function(event) {
    $(event.currentTarget).click();
  });
  $(".qcm input[name=precision_autre]").on('input', function(event) {
    metAJourBoutonValider($(event.currentTarget).closest('.qcm'));
  });
  valideAvecEntree($(".contenu-avec-evaluations input[name=precision_autre]"),
                   '.valide-qcm:not(:disabled)');
});
