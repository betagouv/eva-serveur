function afficheModificationReponse(reponseMiseEnAction, evaluationId) {
  $(`#${evaluationId} .mise-en-action`).removeClass('d-flex').addClass('hidden');
  $(`#${evaluationId} div[data-reponse='${reponseMiseEnAction}']`).removeClass('hidden').addClass('d-flex');
  $(`#${evaluationId} .card__banner--illettrisme`).removeClass('card__banner--en-attente');
  $(`#${evaluationId} .card__banner--illettrisme`).addClass('card__banner--succes');
}

function reinitialiseFormulaire(evaluationId) {
  $(`#${evaluationId} input[name=reponse_qcm]`).prop('checked', false);
  $(`#${evaluationId} .valide-qcm`).addClass('bouton--desactive');
}

function ouvreQcm(evaluationId, qcm, effectuee) {
  $(`#${evaluationId} .reponse-mise-en-action`).removeClass('bouton--actif');
  $(`#${evaluationId} .reponse-mise-en-action[data-reponse='${effectuee}']`).addClass('bouton--actif');
  $(`#${evaluationId} .carte-liste`).addClass('carte--deroulee');
  $(`#${evaluationId} .qcm`).addClass('hidden');
  $(`#${evaluationId} .questions-${qcm}`).removeClass('hidden');
}

function fermeQcm(evaluationId) {
  $(`#${evaluationId} .reponse-mise-en-action`).removeClass('bouton--actif');
  $(`#${evaluationId} .carte-liste`).removeClass('carte--deroulee');
  $(`#${evaluationId} .qcm`).addClass('hidden');
  reinitialiseFormulaire(evaluationId);
}

function modifieReponseMiseEnAction(evaluationId) {
  $(`#${evaluationId} .reponse-mise-en-action`).removeClass('bouton--actif');
  $(`#${evaluationId} .mise-en-action`).removeClass('d-flex').addClass('hidden');
  $(`#${evaluationId} div[data-reponse='vide']`).removeClass('hidden').addClass('d-flex');
  $(`#${evaluationId} .card__banner--illettrisme`).removeClass('card__banner--succes');
  $(`#${evaluationId} .card__banner--illettrisme`).addClass('card__banner--en-attente');
}

function enregistreReponseMiseEnAction(evaluationId, bouton) {
  const reponse = bouton.data('reponse');
  const data = {
    mise_en_action_effectuee: reponse
  };
  $.ajax({
    method: 'PUT',
    url: `/pro/admin/evaluations/${evaluationId}/mise_en_action`,
    data: data,
    dataType: "json",
    success: function () {
      const qcm = nomQcm(reponse)
      ouvreQcm(evaluationId, qcm, reponse);
    }
  });
}

function activeBoutonValider() {
  const radios = $('input[name=reponse_qcm]');

  radios.each(function() {
    const radio = $(this)
    radio.on("click", function(event) {
      radio.closest('.qcm').find('.valide-qcm').removeClass('bouton--desactive');
    })
  });
}

function enregistreQualificationMiseEnAction(evaluationId, $bouton, { ignorer }) {
  const effectuee = miseEnActionEffectuee($bouton)
  const qualification = ignorer ? 'indetermine' : reponseSelectionnee(evaluationId, nomQcm(effectuee));

  $.ajax({
    method: 'PATCH',
    url: `/pro/admin/evaluations/${evaluationId}/renseigner_qualification`,
    data: { effectuee, qualification },
    dataType: "json",
    success: function () {
      afficheModificationReponse(effectuee, evaluationId);
      fermeQcm(evaluationId);
    }
  });
}

function nomQcm(miseEnActionEffectuee) {
  return miseEnActionEffectuee ? 'remediation' : 'difficulte';
};

function reponseSelectionnee(evaluationId, qcm) {
  return $(`#${evaluationId} .questions-${qcm} input[name=reponse_qcm]:checked`).val();
};

function miseEnActionEffectuee($bouton) {
  return $bouton.closest('.qcm')[0].classList.contains('questions-remediation')
}

function ecouteBoutons(boutons, callback) {
  boutons.on('click', function(event) {
    event.preventDefault();
    const evaluationId = event.currentTarget.closest('.carte__conteneur').getAttribute('id')
    callback(evaluationId, $(this));
  });
};

document.addEventListener('DOMContentLoaded', () => {
  ecouteBoutons($(".reponse-mise-en-action"), enregistreReponseMiseEnAction);
  ecouteBoutons($(".modifier-mise-en-action"), modifieReponseMiseEnAction);
  ecouteBoutons($(".valide-qcm"), function(evaluationId, $bouton) {
    enregistreQualificationMiseEnAction(evaluationId, $bouton, { ignorer: false });
  });
  ecouteBoutons($(".bouton-fermer"), function(evaluationId, $bouton) {
    enregistreQualificationMiseEnAction(evaluationId, $bouton, { ignorer: true })
  });
  activeBoutonValider();
});
