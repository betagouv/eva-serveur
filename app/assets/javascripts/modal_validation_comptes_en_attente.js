(function() {
  var MODAL_ID = "fr-modal-validation-comptes-en-attente";
  var OPENED_CLASS = "fr-modal--opened";
  var SCROLL_LOCK_CLASS = "fr-modal-validation-comptes--scroll-locked";

  function lockPageScroll() {
    document.documentElement.classList.add(SCROLL_LOCK_CLASS);
  }

  function unlockPageScroll() {
    document.documentElement.classList.remove(SCROLL_LOCK_CLASS);
  }

  function moveModalToBody(modal) {
    if (!modal || modal.parentNode === document.body) return;
    document.body.appendChild(modal);
  }

  function forceValidationModalOpen(modal) {
    if (!modal) return;
    moveModalToBody(modal);
    modal.classList.add(OPENED_CLASS);
    modal.setAttribute("aria-hidden", "false");
    if (modal.tagName === "DIALOG") {
      modal.setAttribute("open", "");
    }
    lockPageScroll();
  }

  function closeModal(modal) {
    if (!modal) return;
    modal.classList.remove(OPENED_CLASS);
    modal.setAttribute("aria-hidden", "true");
    if (modal.tagName === "DIALOG") {
      modal.removeAttribute("open");
    }
    unlockPageScroll();
  }

  function bindCloseTriggers(modal) {
    if (!modal || modal.dataset.validationComptesModalBound === "true") return;
    modal.dataset.validationComptesModalBound = "true";

    var panel = modal.querySelector(".fr-modal__body");
    modal.addEventListener("click", function(event) {
      if (!panel || panel.contains(event.target)) return;
      event.preventDefault();
      closeModal(modal);
    });

    var selectors =
      '[aria-controls="' + modal.id + '"], .fr-link--close, .fr-btn--close';
    modal.querySelectorAll(selectors).forEach(function(trigger) {
      trigger.addEventListener("click", function(event) {
        if (trigger.type === "submit") return;
        event.preventDefault();
        closeModal(modal);
      });
    });
  }

  function scheduleReopenAfterDsfr(modal) {
    function bump() {
      forceValidationModalOpen(modal);
    }

    function afterPaint() {
      requestAnimationFrame(function() {
        requestAnimationFrame(bump);
      });
    }

    if (document.readyState === "complete") {
      bump();
      afterPaint();
    } else {
      window.addEventListener("load", function onLoad() {
        window.removeEventListener("load", onLoad);
        bump();
        afterPaint();
      });
    }
  }

  function init() {
    var modal = document.getElementById(MODAL_ID);
    if (!modal) return;

    bindCloseTriggers(modal);
    forceValidationModalOpen(modal);
    scheduleReopenAfterDsfr(modal);
  }

  document.addEventListener("DOMContentLoaded", init);
})();
