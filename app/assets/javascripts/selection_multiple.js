function met_a_jour_resume(liste) {
  const cochees = liste.querySelectorAll('input[type="checkbox"]:checked');
  const resume = liste.querySelector('.selection-multiple__resume');

  if (cochees.length === 0) {
    resume.textContent = '';
  } else if (cochees.length === 1) {
    resume.textContent = cochees[0].parentElement.textContent.trim();
  } else {
    resume.textContent = liste.dataset.modeleResume.replace('%{count}', cochees.length);
  }
}

document.addEventListener('DOMContentLoaded', () => {
  const listes = document.querySelectorAll('details.selection-multiple');

  listes.forEach(liste => {
    liste.addEventListener('change', () => met_a_jour_resume(liste));
  });

  document.addEventListener('click', evenement => {
    listes.forEach(liste => {
      if (!liste.contains(evenement.target)) liste.removeAttribute('open');
    });
  });
});
