(function() {
  var OPENED_CLASS = "fr-modal--opened";

  function isInvitationTrigger(element) {
    if (!element) return false;
    if (!element.hasAttribute("data-fr-opened")) return false;
    var controls = element.getAttribute("aria-controls");
    return controls && controls.indexOf("fr-modal-invitation-") === 0;
  }

  function findTrigger(event) {
    var node = event.target;
    while (node && node !== document) {
      if (isInvitationTrigger(node)) return node;
      node = node.parentNode;
    }
    return null;
  }

  function openWithFallback(modal) {
    modal.classList.add(OPENED_CLASS);
    modal.setAttribute("aria-hidden", "false");
  }

  function closeWithFallback(modal) {
    modal.classList.remove(OPENED_CLASS);
    modal.setAttribute("aria-hidden", "true");
  }

  function openModal(modal) {
    openWithFallback(modal);
  }

  function closeModal(modal) {
    closeWithFallback(modal);
  }

  function bindCloseHandlers(modal) {
    if (!modal || modal.dataset.invitationModalBound === "true") return;
    modal.dataset.invitationModalBound = "true";

    modal.addEventListener("click", function(event) {
      if (event.target === modal) {
        event.preventDefault();
        closeModal(modal);
      }
    });

    modal.querySelectorAll('[aria-controls="' + modal.id + '"], .fr-btn--close, .fr-link--close').forEach(function(closeTrigger) {
      closeTrigger.addEventListener("click", function(event) {
        if (closeTrigger.type === "submit") return;
        event.preventDefault();
        closeModal(modal);
      });
    });
  }

  function bindEscapeHandler() {
    if (document.body.dataset.invitationEscapeBound === "true") return;
    document.body.dataset.invitationEscapeBound = "true";

    document.addEventListener("keydown", function(event) {
      if (event.key !== "Escape") return;

      document.querySelectorAll('.fr-modal[id^="fr-modal-invitation-"].' + OPENED_CLASS).forEach(function(modal) {
        closeModal(modal);
      });
    });
  }

  function initInvitationModal() {
    bindEscapeHandler();

    document.querySelectorAll('.fr-modal[id^="fr-modal-invitation-"]').forEach(function(modal) {
      // Place modal at document root to avoid stacking/overflow issues.
      document.body.appendChild(modal);
      modal.setAttribute("aria-hidden", "true");
      bindCloseHandlers(modal);
    });

    document.addEventListener("click", function(event) {
      var trigger = findTrigger(event);
      if (!trigger) return;

      var modalId = trigger.getAttribute("aria-controls");
      if (!modalId) return;

      var modal = document.getElementById(modalId);
      if (!modal) return;

      event.preventDefault();
      event.stopImmediatePropagation();
      openModal(modal);
    }, true);
  }

  document.addEventListener("DOMContentLoaded", initInvitationModal);
})();
