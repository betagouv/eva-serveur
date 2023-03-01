function afficheModificationReponse(reponse, evaluationId) {
  $(`#${evaluationId} .mise-en-action`).removeClass('d-flex').addClass('hidden');
  $(`#${evaluationId} div[data-reponse='${reponse}']`).removeClass('hidden');
  $(`#${evaluationId} .card__banner--illettrisme`).removeClass('card__banner--en-attente');
  $(`#${evaluationId} .card__banner--illettrisme`).addClass('card__banner--succes');
}

function reinitialiseFormulaire(evaluationId) {
  $(`#${evaluationId} input[name=reponse_qcm]`).prop('checked', false);
  $(`#${evaluationId} .valide-qcm`).addClass('bouton--desactive');
}

function ouvreQcm(evaluationId, qcm, effectuee) {
  $(`#${evaluationId} .reponse-mise-en-action`).removeClass('bouton-outline--main');
  $(`#${evaluationId} .reponse-mise-en-action[data-reponse='${effectuee}']`).addClass('bouton-outline--main');
  $(`#${evaluationId} .carte-liste`).addClass('carte--deroulee');
  $(`#${evaluationId} .qcm`).addClass('hidden');
  $(`#${evaluationId} .questions-${qcm}`).removeClass('hidden');
}

function fermeQcm(evaluationId) {
  $(`#${evaluationId} .reponse-mise-en-action`).removeClass('bouton-outline--main');
  $(`#${evaluationId} .carte-liste`).removeClass('carte--deroulee');
  $(`#${evaluationId} .qcm`).addClass('hidden');
  reinitialiseFormulaire(evaluationId);
}

function modifieReponseMiseEnAction(evaluationId) {
  $(`#${evaluationId} .mise-en-action`).addClass('hidden');
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
      const qcm = reponse ? 'remediation' : 'difficultes';
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

function enregistreQualificationMiseEnAction(evaluationId, reponse, $bouton) {
  const effectuee = $bouton.closest('.qcm')[0].classList.contains('questions-remediation');
  const action = effectuee ? 'renseigner_remediation' : 'renseigner_difficulte'
  $.ajax({
    method: 'PATCH',
    url: `/pro/admin/evaluations/${evaluationId}/${action}`,
    data: { reponse },
    dataType: "json",
    success: function () {
      afficheModificationReponse(effectuee, evaluationId);
      fermeQcm(evaluationId);
    }
  });
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
    const reponse = $(`#${evaluationId} input[name=reponse_qcm]:checked`).val();
    enregistreQualificationMiseEnAction(evaluationId, reponse, $bouton);
  });
  ecouteBoutons($(".bouton-fermer"), function(evaluationId, $bouton) {
    enregistreQualificationMiseEnAction(evaluationId, 'indetermine', $bouton)
  });
  activeBoutonValider();
});
