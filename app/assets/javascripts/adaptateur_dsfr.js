document.addEventListener('DOMContentLoaded', function() {
  setTimeout(() => {
    document.querySelectorAll('.fr-modal').forEach(modal => {
      const closeModal = (e) => {
        if (e) e.stopImmediatePropagation();
        if (typeof modal.close === 'function') {
          modal.close();
        } else {
          modal.style.display = 'none';
        }
        modal.classList.remove('fr-modal--opened');
      };

      modal.querySelectorAll('[data-fr-js-modal-button]').forEach(btn => {
        btn.replaceWith(btn.cloneNode(true));
      });

      modal.querySelectorAll('[data-fr-js-modal-button]').forEach(btn => {
        btn.addEventListener('click', closeModal, true);
      });
      
      modal.querySelectorAll('[data-dismiss="modal"]').forEach(btn => {
        btn.addEventListener('click', closeModal, true);
      });

      modal.addEventListener('click', (e) => {
        if (e.target === modal) {
          e.stopImmediatePropagation();
          closeModal();
        }
      }, true);
    });
  }, 100);
});
