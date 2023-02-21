function afficheModificationReponse(reponse, evaluationId) {
  $(`#${evaluationId} .mise-en-action`).removeClass('d-flex').addClass('hidden');
  $(`#${evaluationId} div[data-reponse='${reponse}']`).removeClass('hidden');
  $(`#${evaluationId} .card__banner--illettrisme`).addClass('card__banner--illettrisme-avec-reponse');
}

function reinitialiseFormulaire(evaluationId) {
  $(`#${evaluationId} input[name=dispositif_de_remediation]`).prop('checked',false);
  $(`#${evaluationId} .valide-dispositif-remediation`).addClass('bouton--desactive');
}

function ouvreDispositifsRemediation(evaluationId) {
  $(`#${evaluationId} .reponse-mise-en-action[data-reponse='false']`).addClass('bouton-outline--main');
  $(`#${evaluationId} .carte-liste`).addClass('carte--deroulante');
  $(`#${evaluationId} .carte__menu-deroulant`).removeClass('hidden');
}

function fermeDispositifsRemediation(evaluationId) {
  $(`#${evaluationId} .reponse-mise-en-action[data-reponse='false']`).removeClass('bouton-outline--main');
  $(`#${evaluationId} .carte-liste`).removeClass('carte--deroulante');
  $(`#${evaluationId} .carte__menu-deroulant`).addClass('hidden');
  reinitialiseFormulaire(evaluationId);
}

function modifieReponseMiseEnAction(evaluationId) {
  $(`#${evaluationId} .mise-en-action`).addClass('hidden');
  $(`#${evaluationId} div[data-reponse='vide']`).removeClass('hidden').addClass('d-flex');
  $(`#${evaluationId} .card__banner--illettrisme`).removeClass('card__banner--illettrisme-avec-reponse');
}

function enregistreReponseMiseEnAction(evaluationId, bouton) {
  const reponse = bouton.data('reponse');
  const data = {
    mise_en_action_effectuee: reponse
  };
  const dashboard = (window.location.pathname == '/pro/admin/dashboard');
  $.ajax({
    method: 'PUT',
    url: `/pro/admin/evaluations/${evaluationId}/mise_en_action`,
    data: data,
    dataType: "json",
    success: function () {
      if(reponse && dashboard) {
        ouvreDispositifsRemediation(evaluationId);
      } else {
        fermeDispositifsRemediation(evaluationId);
        afficheModificationReponse(reponse, evaluationId);
      }
    }
  });
}

function activeBoutonValider() {
  const radios = $('input[name=dispositif_de_remediation]');

  for(radio in radios) {
    radios[radio].onclick = function(event) {
      const evaluationId = event.currentTarget.closest('.carte__conteneur').getAttribute('id')
      $(`#${evaluationId} .valide-dispositif-remediation`).removeClass('bouton--desactive');
    }
  }
}
function enregistreDispositifRemediation(evaluationId, reponse) {
  const data = {
    dispositif_de_remediation: reponse
  };
  $.ajax({
    method: 'PATCH',
    url: `/pro/admin/evaluations/${evaluationId}/renseigner_remediation`,
    data: data,
    dataType: "json",
    success: function () {
      afficheModificationReponse(true, evaluationId);
      fermeDispositifsRemediation(evaluationId);
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
  ecouteBoutons($(".valide-dispositif-remediation"), function(evaluationId) {
    const reponse = $(`#${evaluationId} input[name=dispositif_de_remediation]:checked`).val();
    enregistreDispositifRemediation(evaluationId, reponse);
  });
  ecouteBoutons($(".ferme-dispositif-remediation"), function(evaluationId) {
    enregistreDispositifRemediation(evaluationId, 'indetermine')
  });
  activeBoutonValider();
});
