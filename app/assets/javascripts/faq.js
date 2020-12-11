document.addEventListener("DOMContentLoaded", () => {
  const questions = document.querySelectorAll('.faq .question');

  document.querySelector('.faq .question').classList.add('active');
  document.querySelector('.faq .reponse').classList.add('active');

  questions.forEach(question => {
    question.addEventListener('click', e => {
      const id = e.currentTarget.dataset.id;

      document.querySelectorAll('.faq [data-id]').forEach(el => {
        el.classList.remove('active');
      });
      document.querySelectorAll(`.faq [data-id="${id}"]`).forEach(el => {
        el.classList.add('active');
      });
    });
  })
});
