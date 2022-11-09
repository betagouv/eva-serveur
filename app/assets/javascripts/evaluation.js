function afficheReponse(reponse) {
  $('.mise-en-action').addClass('hidden');
  $(`div[data-reponse='${reponse}']`).removeClass('hidden');
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
});
