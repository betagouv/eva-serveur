document.addEventListener('DOMContentLoaded', () => {
  const conteneur = document.getElementById('generation-pdf');
  if (!conteneur) return;

  const token = conteneur.dataset.token;
  const consumer = ActionCable.createConsumer();

  consumer.subscriptions.create({ channel: 'Pdf::GenerationChannel', token: token }, {
    received(data) {
      if (data.statut === 'pret') {
        telechargePdf(data.contenu_base64, data.nom_fichier);
      } else {
        document.getElementById('generation-pdf-attente').hidden = true;
        document.getElementById('generation-pdf-erreur').hidden = false;
      }
    }
  });
});
