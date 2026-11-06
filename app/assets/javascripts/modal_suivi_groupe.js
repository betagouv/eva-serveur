(function() {
  var MODAL_ID = "fr-modal-suivi-groupe";
  var FORM_ID = "suivi-groupe-form";

  var etat = { effectuee: null, qualification: null, precisionAutre: null };

  function dsfrModal(modal) {
    if (!modal || !window.dsfr) return null;
    var instance = window.dsfr(modal);
    return instance && instance.modal ? instance.modal : null;
  }

  function discloseModal(modal) {
    var modalInstance = dsfrModal(modal);
    if (modalInstance) modalInstance.disclose();
  }

  /** Batch ActiveAdmin englobe la page : un second formulaire dans le HTML serait ignoré ; #suivi-groupe-form est créé ici sur body, champs reliés via attribut form. */
  function ensureSuiviGroupeFormDom(modal) {
    if (document.getElementById(FORM_ID)) return;

    var action = modal.dataset.suiviGroupeBatchAction;
    if (!action) return;

    var form = document.createElement("form");
    form.id = FORM_ID;
    form.method = "post";
    form.action = action;
    form.setAttribute("data-turbo", "false");
    form.style.display = "none";

    var meta = document.querySelector('meta[name="csrf-token"]');
    if (meta) {
      var tok = document.createElement("input");
      tok.type = "hidden";
      tok.name = "authenticity_token";
      tok.value = meta.getAttribute("content") || "";
      form.appendChild(tok);
    }

    document.body.appendChild(form);
  }

  function elementFromEventTarget(target) {
    if (!target) return null;
    if (target.nodeType === Node.TEXT_NODE) return target.parentElement;
    return target;
  }

  function findSuiviGroupeBatchLink(target) {
    var el = elementFromEventTarget(target);
    if (!el || !el.closest) return null;
    return el.closest("a.batch_action[data-action=\"renseigner_suivi_groupe\"]");
  }

  function handleSuiviGroupeClick(event) {
    var link = findSuiviGroupeBatchLink(event.target);
    if (!link) return;

    event.preventDefault();
    event.stopPropagation();
    event.stopImmediatePropagation();

    var modal = document.getElementById(MODAL_ID);
    if (!modal) return;

    var checkedBoxes = document.querySelectorAll(
      "input.batch-actions-resource-selection:checked"
    );

    if (checkedBoxes.length < 1) return;

    modal.dataset.ids = Array.from(checkedBoxes).map(function(cb) {
      return cb.value;
    }).join(",");

    updateTitre(modal, checkedBoxes.length);
    reinitialiser(modal);
    discloseModal(modal);
  }

  function updateTitre(modal, count) {
    var titleEl = modal.querySelector(".fr-modal__title");
    if (!titleEl) return;
    var suffixe = count > 1 ? "s" : "";
    titleEl.innerHTML = "<span class=\"fr-icon-arrow-right-line\" aria-hidden=\"true\"></span> Où en sont ces " + count + " bénéficiaire" + suffixe + " ?";
  }

  function reinitialiser(modal) {
    etat.effectuee = null;
    etat.qualification = null;
    etat.precisionAutre = null;
    afficherEtapeQuestion(modal);
  }

  function afficherEtapeQuestion(modal) {
    afficher(modal, "suivi-groupe-etape-question");
    cacher(modal, "suivi-groupe-etape-qualification");
    cacher(modal, "suivi-groupe-etape-recap");
    cacher(modal, "suivi-groupe-soumettre");
    reinitialiserTagsSelection(modal);
  }

  function afficherEtapeQualification(modal) {
    cacher(modal, "suivi-groupe-etape-question");
    afficher(modal, "suivi-groupe-etape-qualification");
    cacher(modal, "suivi-groupe-etape-recap");
    cacher(modal, "suivi-groupe-soumettre");

    var labelEl = modal.querySelector("#suivi-groupe-label-reponse");
    if (labelEl) labelEl.textContent = labelPourReponse(etat.effectuee);

    var tagsRemediation = modal.querySelector("#suivi-groupe-tags-remediation");
    var tagsDifficulte = modal.querySelector("#suivi-groupe-tags-difficulte");
    if (etat.effectuee === "true") {
      if (tagsRemediation) tagsRemediation.removeAttribute("hidden");
      if (tagsDifficulte) tagsDifficulte.setAttribute("hidden", "");
    } else {
      if (tagsRemediation) tagsRemediation.setAttribute("hidden", "");
      if (tagsDifficulte) tagsDifficulte.removeAttribute("hidden");
    }
  }

  function afficherEtapeRecap(modal) {
    cacher(modal, "suivi-groupe-etape-question");
    cacher(modal, "suivi-groupe-etape-qualification");
    afficher(modal, "suivi-groupe-etape-recap");
    afficher(modal, "suivi-groupe-soumettre");

    var recapEl = modal.querySelector("#suivi-groupe-recap-texte");
    if (recapEl) recapEl.textContent = labelRecapReponse(etat.effectuee);

    var qualifEl = modal.querySelector("#suivi-groupe-recap-qualification");
    if (qualifEl) qualifEl.textContent = texteRecapQualification();
  }

  function labelPourReponse(effectuee) {
    if (effectuee === "true") return "Une suite est engagée";
    if (effectuee === "false") return "Aucune action à ce stade";
    return "Une action est prévue";
  }

  function labelRecapReponse(effectuee) {
    if (effectuee === "true") return "Oui, une aide a commencé";
    if (effectuee === "false") return "Non, pas d'aide engagée";
    return "Pas encore — Une action est prévue";
  }

  function texteRecapQualification() {
    if (etat.effectuee === REPONSE_PAS_ENCORE || !etat.qualification) return "";
    var labelTag = labelPourQualification(etat.effectuee, etat.qualification);
    var precisionText = etat.precisionAutre ? " (« " + etat.precisionAutre + " »)" : "";
    return labelTag + precisionText;
  }

  function texteRecap() {
    var base = labelRecapReponse(etat.effectuee);
    var qualif = texteRecapQualification();
    if (qualif) return base + " — " + qualif;
    return base;
  }

  function labelPourQualification(effectuee, qualification) {
    var tags = document.querySelectorAll(".suivi-groupe-tag[data-qualification=\"" + qualification + "\"]");
    for (var i = 0; i < tags.length; i++) {
      var tag = tags[i];
      var type = tag.dataset.type;
      if (effectuee === "true" && type === "remediation") return tag.textContent.trim();
      if (effectuee === "false" && type === "difficulte") return tag.textContent.trim();
    }
    return qualification;
  }

  function reinitialiserTagsSelection(modal) {
    modal.querySelectorAll(".suivi-groupe-tag--actif").forEach(function(tag) {
      tag.classList.remove("suivi-groupe-tag--actif");
    });
    var precisionDiv = modal.querySelector("#suivi-groupe-precision-autre");
    if (precisionDiv) precisionDiv.setAttribute("hidden", "");
  }

  function afficher(modal, id) {
    var el = modal.querySelector ? modal.querySelector("#" + id) : document.getElementById(id);
    if (el) el.removeAttribute("hidden");
  }

  function cacher(modal, id) {
    var el = modal.querySelector ? modal.querySelector("#" + id) : document.getElementById(id);
    if (el) el.setAttribute("hidden", "");
  }

  /* Valeur de la constante Ruby MiseEnAction::REPONSE_PAS_ENCORE */
  var REPONSE_PAS_ENCORE = "pas_encore";

  function handleBtnReponseClick(modal, btn) {
    etat.effectuee = btn.dataset.effectuee;
    etat.qualification = null;
    etat.precisionAutre = null;

    if (etat.effectuee === REPONSE_PAS_ENCORE) {
      afficherEtapeRecap(modal);
    } else {
      afficherEtapeQualification(modal);
    }
  }

  function handleTagClick(modal, tag) {
    reinitialiserTagsSelection(modal);
    tag.classList.add("suivi-groupe-tag--actif");

    etat.qualification = tag.dataset.qualification;
    etat.precisionAutre = null;

    var precisionDiv = modal.querySelector("#suivi-groupe-precision-autre");
    if (etat.qualification === "autre") {
      if (precisionDiv) precisionDiv.removeAttribute("hidden");
      var textarea = document.getElementById("suivi-groupe-precision-autre-input");
      if (textarea) {
        etat.precisionAutre = textarea.value.trim() || null;
        textarea.addEventListener("input", function() {
          etat.precisionAutre = textarea.value.trim() || null;
        }, { once: false });
      }
    } else {
      if (precisionDiv) precisionDiv.setAttribute("hidden", "");
      afficherEtapeRecap(modal);
    }
  }

  function handleModalClick(event, modal) {
    var el = elementFromEventTarget(event.target);
    if (!el) return;

    var btnReponse = el.closest(".suivi-groupe-btn-reponse");
    if (btnReponse) { handleBtnReponseClick(modal, btnReponse); return; }

    var tag = el.closest(".suivi-groupe-tag");
    if (tag) { handleTagClick(modal, tag); return; }

    if (el.id === "suivi-groupe-modifier-reponse" || el.closest("#suivi-groupe-modifier-reponse")) {
      event.preventDefault();
      afficherEtapeQuestion(modal);
      return;
    }

    if (el.id === "suivi-groupe-modifier-recap" || el.closest("#suivi-groupe-modifier-recap")) {
      event.preventDefault();
      if (etat.effectuee === REPONSE_PAS_ENCORE) {
        afficherEtapeQuestion(modal);
      } else {
        afficherEtapeQualification(modal);
      }
      return;
    }
  }

  function prepareHiddenInputs(modal) {
    var ids = (modal.dataset.ids || "").split(",").filter(function(id) {
      return id.length > 0;
    });
    var container = document.getElementById("hidden-ids-suivi-container");
    if (!container) return;

    container.innerHTML = "";

    ids.forEach(function(id) {
      var input = document.createElement("input");
      input.type = "hidden";
      input.name = "collection_selection[]";
      input.value = id;
      input.setAttribute("form", FORM_ID);
      container.appendChild(input);
    });

    var effectueeChamp = document.getElementById("suivi-groupe-effectuee");
    if (effectueeChamp) effectueeChamp.value = etat.effectuee || "";

    var qualificationChamp = document.getElementById("suivi-groupe-qualification-champ");
    if (qualificationChamp) qualificationChamp.value = etat.qualification || "";

    var precisionAutreChamp = document.getElementById("suivi-groupe-precision-autre-champ");
    if (precisionAutreChamp) {
      var textarea = document.getElementById("suivi-groupe-precision-autre-input");
      precisionAutreChamp.value = (textarea && etat.qualification === "autre")
        ? textarea.value.trim()
        : "";
    }
  }

  function init() {
    var modal = document.getElementById(MODAL_ID);
    if (!modal) return;

    ensureSuiviGroupeFormDom(modal);

    document.addEventListener("click", handleSuiviGroupeClick, true);

    modal.addEventListener("click", function(event) {
      handleModalClick(event, modal);
    });

    var form = document.getElementById(FORM_ID);
    if (form) {
      form.addEventListener("submit", function() {
        prepareHiddenInputs(modal);
      });
    }
  }

  if (typeof module !== "undefined") { module.exports = { init }; }
  else { document.addEventListener("DOMContentLoaded", init); }
})();
