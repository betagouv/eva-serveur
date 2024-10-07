function trouve_le_menu(bouton) {
  let parent_commun = bouton.closest('tr, .contenu');
  return parent_commun.querySelector('.table_actions')
}

document.addEventListener('DOMContentLoaded', () => {
  let boutons = document.getElementsByClassName('bouton-menu')
  Array.from(boutons).forEach((bouton_menu) => {
    let menu = trouve_le_menu(bouton_menu);
    bouton_menu.addEventListener('click', () => {
      menu.classList.toggle('montrer');
    });
    bouton_menu.parentElement.addEventListener("mouseleave", () => {
      menu.classList.remove('montrer');
    });
  });

});
