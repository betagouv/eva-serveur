function cree_le_bouton_menu_mobile() {
  const bouton = document.createElement('button');
  bouton.id = 'bouton-menu-mobile';
  bouton.className = 'bouton-menu-mobile';
  bouton.setAttribute('aria-label', I18n.t('label-menu-mobile'));
  for (let i = 0; i < 3; i++) {
    const span = document.createElement('span');
    bouton.appendChild(span);
  }

  bouton.addEventListener('click', function() {
    document.querySelector('body').classList.toggle('menu-mobile-ouvert');
    bouton.classList.toggle('active');
  });

  document.addEventListener('click', function(e) {
    const body = document.querySelector('body');
    if (body.classList.contains('menu-mobile-ouvert') &&
        !e.target.closest('#bouton-menu-mobile') &&
        !e.target.closest('#tabs')) {
      body.classList.remove('menu-mobile-ouvert');
      bouton.classList.remove('active');
    }
  });
  return bouton;
}

document.addEventListener('DOMContentLoaded', () => {
  const tabs = document.querySelector('.header #tabs');
  if (tabs != null) {
    const bouton = cree_le_bouton_menu_mobile();
    document.querySelector('.header #site_title').after(bouton);
  }
});
