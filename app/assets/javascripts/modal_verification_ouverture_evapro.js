/**
 * Ouverture de la modale de vérification de compte (Autoriser/Refuser).
 * Le lien « Vérifier » (aria-controls) et le rendu `<dialog class="fr-modal">` ne sont pas
 * reliés automatiquement par le bundle DSFR chargé dans ActiveAdmin : même logique que
 * invitation_modal.js (déplacement au body à l’ouverture, classe fr-modal--opened, etc.).
 */
(function() {
  var OPENED_CLASS = "fr-modal--opened";
  var DATA_ATTR = "data-ouvre-modal-verification";
  var VERIFICATION_MODAL_ID_PREFIX = "fr-modal-";
  var INVITATION_MODAL_ID_PREFIX = "fr-modal-invitation-";
  var VERIFIER_LINK_REGEX = /\/comptes\/(\d+)\/verifier/;

  function isVerificationModalId(id) {
    return id && id.indexOf(VERIFICATION_MODAL_ID_PREFIX) === 0 &&
      id.indexOf(INVITATION_MODAL_ID_PREFIX) !== 0;
  }

  function getCompteIdFromVerifierLink(node) {
    var link = node && node.nodeType === 1 ? node : null;
    while (link && link !== document) {
      if (link.tagName === "A" && link.getAttribute("href")) {
        var m = link.getAttribute("href").match(VERIFIER_LINK_REGEX);
        if (m) return { link: link, compteId: m[1] };
      }
      link = link.parentNode;
    }
    return null;
  }

  function findTriggerAndModalId(node) {
    while (node && node !== document) {
      if (node.getAttribute) {
        var dataId = node.getAttribute(DATA_ATTR);
        if (dataId) return { trigger: node, modalId: dataId };
        var controls = node.getAttribute("aria-controls");
        if (isVerificationModalId(controls)) return { trigger: node, modalId: controls };
      }
      node = node.parentNode;
    }
    return null;
  }

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
    if (!modal || modal.dataset.verificationModalEvaproBound === "true") return;
    modal.dataset.verificationModalEvaproBound = "true";

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
    if (document.body.dataset.verificationEvaproEscapeBound === "true") return;
    document.body.dataset.verificationEvaproEscapeBound = "true";

    document.addEventListener("keydown", function(event) {
      if (event.key !== "Escape") return;
      document.querySelectorAll(".fr-modal." + OPENED_CLASS).forEach(function(modal) {
        if (isVerificationModalId(modal.id)) {
          closeModal(modal);
        }
      });
    });
  }

  function initVerificationModal() {
    bindEscapeHandler();

    document.addEventListener("click", function(event) {
      var modalId = null;
      var modal = null;

      var verifierMatch = getCompteIdFromVerifierLink(event.target);
      if (verifierMatch) {
        modalId = VERIFICATION_MODAL_ID_PREFIX + verifierMatch.compteId;
        modal = document.getElementById(modalId);
        if (modal) {
          event.preventDefault();
          event.stopImmediatePropagation();
          bindCloseHandlers(modal);
          openModal(modal);
          return;
        }
      }

      var found = findTriggerAndModalId(event.target);
      if (!found) return;

      modalId = found.modalId;
      modal = document.getElementById(modalId);
      if (!modal) return;

      event.preventDefault();
      event.stopImmediatePropagation();
      bindCloseHandlers(modal);
      openModal(modal);
    }, true);
  }

  document.addEventListener("DOMContentLoaded", initVerificationModal);
})();
