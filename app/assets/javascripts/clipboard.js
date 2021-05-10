document.addEventListener("DOMContentLoaded", () => {
  const boutonsCopierColler = document.querySelectorAll('.copier-coller');

  boutonsCopierColler.forEach(bouton => {
    bouton.addEventListener('click', e => {
      let inputCopierColler = e.currentTarget.previousElementSibling;
      inputCopierColler.select();
      document.execCommand('copy');
    });
  });
});
