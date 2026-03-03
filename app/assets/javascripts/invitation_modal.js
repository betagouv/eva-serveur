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

    document.addEventListener("click", function(event) {
      var btn = event.target && event.target.closest(".copier-lien-invitation");
      if (!btn || !btn.dataset.copierLienUrl) return;

      event.preventDefault();
      event.stopPropagation();

      var url = btn.dataset.copierLienUrl;
      var meta = document.querySelector('meta[name="csrf-token"]');
      var csrfToken = meta ? meta.getAttribute("content") : null;
      if (!csrfToken) {
        var form = document.querySelector('form[id^="invitation-form-"]');
        var input = form && form.querySelector('input[name="authenticity_token"]');
        csrfToken = input ? input.value : null;
      }
      var headers = { "Accept": "application/json", "X-Requested-With": "XMLHttpRequest" };
      if (csrfToken) headers["X-CSRF-Token"] = csrfToken;

      fetch(url, { method: "POST", headers: headers, credentials: "same-origin" })
        .then(function(r) {
          if (!r.ok) {
            return r.text().then(function(text) {
              try { return { _error: JSON.parse(text).error || text }; } catch (e) { return { _error: text }; }
            });
          }
          return r.json();
        })
        .then(function(data) {
          if (data._error) return;
          if (data.url) {
            if (navigator.clipboard && navigator.clipboard.writeText) {
              navigator.clipboard.writeText(data.url).then(function() {
                var label = btn.querySelector(".copier-lien-invitation__label") || btn;
                var originalText = label.textContent;
                label.textContent = "Lien copié !";
                setTimeout(function() { label.textContent = originalText; }, 2000);
              });
            } else {
              var ta = document.createElement("textarea");
              ta.value = data.url;
              ta.setAttribute("readonly", "");
              ta.style.position = "absolute";
              ta.style.left = "-9999px";
              document.body.appendChild(ta);
              ta.select();
              try {
                document.execCommand("copy");
                var label = btn.querySelector(".copier-lien-invitation__label") || btn;
                var originalText = label.textContent;
                label.textContent = "Lien copié !";
                setTimeout(function() { label.textContent = originalText; }, 2000);
              } finally {
                document.body.removeChild(ta);
              }
            }
          }
        });
    }, true);
  }

  document.addEventListener("DOMContentLoaded", initInvitationModal);
})();
