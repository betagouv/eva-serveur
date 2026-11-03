// Mise en action sur le tableau de bord : questionnaire à boutons radio, « Valider » et « Ignorer ».
// Utilise les chemins et fonctions communes de mise_en_action.js.erb.
// Différences avec la fiche évaluation : docs/mise_en_action_ecrans.md

function activeBoutonValider() {
  const radios = $('input[name=reponse_qcm]');

  radios.each(function() {
    const radio = $(this)
    radio.on("click", function(event) {
      radio.closest('.qcm').find('.valide-qcm').prop('disabled', false);
    })
  });
}

function enregistreQualificationMiseEnAction(evaluationId, $bouton, { ignorer }) {
  const effectuee = miseEnActionEffectuee($bouton)
  const qualification = ignorer ? 'indetermine' : reponseSelectionnee(evaluationId, nomQcm(effectuee));

  $.ajax({
    method: 'PATCH',
    url: chemin_renseigner_qualification.replace('ID_EVALUATION', evaluationId),
    data: { effectuee, qualification },
    dataType: "json",
    success: function () {
      afficheModificationReponse(effectuee, evaluationId);
      fermeQcm(evaluationId);
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
});
