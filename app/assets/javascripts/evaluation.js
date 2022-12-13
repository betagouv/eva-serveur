function afficheReponse(reponse, evaluationId) {
  $(`#${evaluationId} .mise-en-action`).removeClass('d-flex').addClass('hidden');
  $(`#${evaluationId} div[data-reponse='${reponse}']`).removeClass('hidden');
  $(`#${evaluationId} .card__banner--illettrisme`).addClass('card__banner--illettrisme-avec-reponse');
}

function modifieReponseAccompagnementIllettrisme(evaluationId) {
  $(`#${evaluationId} .mise-en-action`).addClass('hidden');
  $(`#${evaluationId} div[data-reponse='vide']`).removeClass('hidden').addClass('d-flex');
  $(`#${evaluationId} .card__banner--illettrisme`).removeClass('card__banner--illettrisme-avec-reponse');
}

function enregistreReponseAccompagnementIllettrisme(evaluationId, reponse) {
  const data = {
    mise_en_action_effectuee: reponse
  };
  $.ajax({
    method: 'PUT',
    url: `/pro/admin/evaluations/${evaluationId}/mise_en_action`,
    data: data,
    dataType: "json",
    success: function () {
      afficheReponse(reponse, evaluationId);
    }
  });
}

document.addEventListener('DOMContentLoaded', () => {
  $( ".reponse-mise-en-action" ).click(function(e) {
    e.preventDefault();
    const evaluationId = $(this).data('evaluation-id');
    const reponse = $(this).data('reponse');
    enregistreReponseAccompagnementIllettrisme(evaluationId, reponse)
  });

  $( ".modifier-mise-en-action" ).click(function(e) {
    e.preventDefault();
    const evaluationId = $(this).data('evaluation-id');
    modifieReponseAccompagnementIllettrisme(evaluationId)
  })
});
