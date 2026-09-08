(function() {
  function dsfrModal(modal) {
    if (!modal || !window.dsfr) return null;
    var instance = window.dsfr(modal);
    return instance && instance.modal ? instance.modal : null;
  }

  function ouvreModal(modal) {
    var instance = dsfrModal(modal);
    if (instance) instance.disclose();
  }

  function fermeModal(modal) {
    var instance = dsfrModal(modal);
    if (instance) instance.conceal();
  }

  function reinitialise(modal) {
    modal.querySelector('#modal-generation-pdf-attente').hidden = false;
    modal.querySelector('#modal-generation-pdf-erreur').hidden = true;
  }

  function afficheErreur(modal) {
    modal.querySelector('#modal-generation-pdf-attente').hidden = true;
    modal.querySelector('#modal-generation-pdf-erreur').hidden = false;
  }

  function ecouteGeneration(modal, token) {
    var consumer = ActionCable.createConsumer();
    consumer.subscriptions.create({ channel: 'Pdf::GenerationChannel', token: token }, {
      received: function(message) {
        if (message.statut === 'pret') {
          telechargePdf(message.contenu_base64, message.nom_fichier);
          fermeModal(modal);
        } else {
          afficheErreur(modal);
        }
      }
    });
  }

  function declencheExportPdf(lien, modal) {
    reinitialise(modal);
    ouvreModal(modal);

    $.ajax({
      url: lien.href,
      dataType: 'json',
      success: function(reponse) {
        ecouteGeneration(modal, reponse.token);
      },
      error: function() {
        afficheErreur(modal);
      }
    });
  }

  document.addEventListener('DOMContentLoaded', function() {
    var modal = document.getElementById('modal-generation-pdf');
    if (!modal) return;

    document.querySelectorAll('.lien-export-pdf').forEach(function(lien) {
      lien.addEventListener('click', function(event) {
        event.preventDefault();
        declencheExportPdf(lien, modal);
      });
    });
  });
})();
