function telechargePdf(contenuBase64, nomFichier) {
  const octets = atob(contenuBase64);
  const tableau = new Uint8Array(octets.length);
  for (let i = 0; i < octets.length; i++) {
    tableau[i] = octets.charCodeAt(i);
  }
  const blob = new Blob([tableau], { type: 'application/pdf' });
  const url = URL.createObjectURL(blob);
  const lien = document.createElement('a');
  lien.href = url;
  lien.download = nomFichier;
  document.body.appendChild(lien);
  lien.click();
  document.body.removeChild(lien);
  setTimeout(() => URL.revokeObjectURL(url), 4000);
}

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
