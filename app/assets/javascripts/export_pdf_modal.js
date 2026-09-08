(function() {
  var generationActuelle = null;

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

  // Abandonne la génération en cours : annule la requête d'enqueue si elle
  // n'a pas encore répondu, et coupe la connexion ActionCable pour que le
  // téléchargement ne se déclenche pas si le message arrive après coup.
  function annuleGeneration() {
    if (!generationActuelle) return;

    generationActuelle.xhr.abort();
    if (generationActuelle.consumer) generationActuelle.consumer.disconnect();
    generationActuelle = null;
  }

  function ecouteGeneration(modal, token) {
    var consumer = ActionCable.createConsumer();
    generationActuelle.consumer = consumer;

    consumer.subscriptions.create({ channel: 'Pdf::GenerationChannel', token: token }, {
      received: function(message) {
        generationActuelle = null;
        consumer.disconnect();
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
    annuleGeneration();
    reinitialise(modal);
    ouvreModal(modal);

    generationActuelle = {
      xhr: $.ajax({
        url: lien.href,
        dataType: 'json',
        success: function(reponse) {
          ecouteGeneration(modal, reponse.token);
        },
        error: function(xhr) {
          if (xhr.statusText === 'abort') return;

          generationActuelle = null;
          afficheErreur(modal);
        }
      })
    };
  }

  document.addEventListener('DOMContentLoaded', function() {
    var modal = document.getElementById('modal-generation-pdf');
    if (!modal) return;

    modal.addEventListener('dsfr.conceal', annuleGeneration);

    document.querySelectorAll('.lien-export-pdf').forEach(function(lien) {
      lien.addEventListener('click', function(event) {
        event.preventDefault();
        declencheExportPdf(lien, modal);
      });
    });
  });
})();
