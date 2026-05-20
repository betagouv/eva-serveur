(function() {
  function initCopierLienInvitation() {
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

  document.addEventListener("DOMContentLoaded", initCopierLienInvitation);
})();
