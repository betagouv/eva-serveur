(function() {
  var OPENED_CLASS = "fr-modal--opened";
  var DATA_ATTR = "data-ouvre-modal-verification";

  function openModal(modal) {
    if (!modal) return;
    if (modal.parentNode !== document.body) {
      document.body.appendChild(modal);
    }
    modal.classList.add(OPENED_CLASS);
    modal.setAttribute("aria-hidden", "false");
    if (modal.tagName === "DIALOG") {
      if (typeof modal.showModal === "function") {
        modal.showModal();
      } else if (!modal.hasAttribute("open")) {
        modal.setAttribute("open", "");
      }
    }
  }

  function closeModal(modal) {
    if (!modal) return;
    modal.classList.remove(OPENED_CLASS);
    modal.setAttribute("aria-hidden", "true");
    if (modal.tagName === "DIALOG") {
      if (typeof modal.close === "function") {
        modal.close();
      } else {
        modal.removeAttribute("open");
      }
    }
  }

  function bindCloseHandlers(modal) {
    if (!modal || modal.dataset.verificationModalBound === "true") return;
    modal.dataset.verificationModalBound = "true";

    modal.addEventListener("click", function(event) {
      if (event.target === modal) {
        event.preventDefault();
        closeModal(modal);
      }
    });

    var selectors = "[aria-controls=\"" + modal.id + "\"], .fr-link--close, .fr-btn--close";
    modal.querySelectorAll(selectors).forEach(function(trigger) {
      trigger.addEventListener("click", function(event) {
        if (trigger.type === "submit") return;
        event.preventDefault();
        closeModal(modal);
      });
    });
  }

  function bindEscapeHandler() {
    if (document.body.dataset.verificationEscapeBound === "true") return;
    document.body.dataset.verificationEscapeBound = "true";

    document.addEventListener("keydown", function(event) {
      if (event.key !== "Escape") return;
      document.querySelectorAll(".fr-modal." + OPENED_CLASS).forEach(function(modal) {
        if (modal.id && modal.id.indexOf("fr-modal-") === 0 && modal.id.indexOf("fr-modal-invitation-") !== 0) {
          closeModal(modal);
        }
      });
    });
  }

  function initVerificationModal() {
    bindEscapeHandler();

    document.addEventListener("click", function(event) {
      var node = event.target;
      var trigger = null;
      while (node && node !== document) {
        if (node.getAttribute && node.getAttribute(DATA_ATTR)) {
          trigger = node;
          break;
        }
        node = node.parentNode;
      }
      if (!trigger) return;

      var modalId = trigger.getAttribute(DATA_ATTR);
      if (!modalId) return;

      var modal = document.getElementById(modalId);
      if (!modal) return;

      event.preventDefault();
      event.stopPropagation();

      bindCloseHandlers(modal);
      openModal(modal);
    }, true);
  }

  document.addEventListener("DOMContentLoaded", initVerificationModal);
})();
