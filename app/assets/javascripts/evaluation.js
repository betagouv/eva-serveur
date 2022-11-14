function afficheReponse(reponse) {
  $('.mise-en-action').removeClass('d-flex').addClass('hidden');
  $(`div[data-reponse='${reponse}']`).removeClass('hidden');
  $('.card__banner--illettrisme').addClass('card__banner--illettrisme-avec-reponse');
}

function modifieReponseAccompagnementIllettrisme() {
  $('.mise-en-action').addClass('hidden');
  $("div[data-reponse='vide']").removeClass('hidden').addClass('d-flex');
  $('.card__banner--illettrisme').removeClass('card__banner--illettrisme-avec-reponse');
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
      afficheReponse(reponse);
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
    modifieReponseAccompagnementIllettrisme()
  })
});
