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
  // Revocation différée : la libérer immédiatement peut interrompre le
  // téléchargement avant que le navigateur ait fini de lire le blob.
  setTimeout(() => URL.revokeObjectURL(url), 4000);
}
