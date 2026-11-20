/**
 * @jest-environment jsdom
 */

const { init } = require("../../app/assets/javascripts/modal_suivi_groupe.js");

const MODAL_ID = "fr-modal-suivi-groupe";
const FORM_ID = "beneficiaires-selection";
const REPONSE_PAS_ENCORE = "pas_encore";

function creerModalHTML() {
  return `
    <form id="${FORM_ID}">
      <input type="checkbox" name="beneficiaire_ids[]" value="42" />
      <input type="checkbox" name="beneficiaire_ids[]" value="43" />
      <input type="checkbox" name="beneficiaire_ids[]" value="99" />
    </form>
    <div id="${MODAL_ID}"
         data-formulaire-selection="${FORM_ID}"
         class="fr-modal-suivi-groupe">
      <span class="fr-modal__title"></span>

      <div id="suivi-groupe-etape-question">
        <button class="suivi-groupe-btn-reponse" data-effectuee="true">Oui</button>
        <button class="suivi-groupe-btn-reponse" data-effectuee="${REPONSE_PAS_ENCORE}">Pas encore</button>
        <button class="suivi-groupe-btn-reponse" data-effectuee="false">Non</button>
      </div>

      <div id="suivi-groupe-etape-qualification" hidden>
        <span id="suivi-groupe-label-reponse"></span>
        <div id="suivi-groupe-titre-qualification">
          <p>De quelle aide s'agit-il ?</p>
        </div>
        <div id="suivi-groupe-titre-relance" hidden>
          <p>Quand voulez-vous refaire le point ?</p>
        </div>
        <div id="suivi-groupe-tags-remediation">
          <button class="suivi-groupe-tag" data-qualification="formation_metier" data-type="remediation">Formation métier</button>
          <button class="suivi-groupe-tag" data-qualification="autre" data-type="remediation">Autre</button>
        </div>
        <div id="suivi-groupe-tags-difficulte" hidden>
          <button class="suivi-groupe-tag" data-qualification="freins_peripheriques" data-type="difficulte">Freins périphériques</button>
        </div>
        <div id="suivi-groupe-tags-relance" hidden>
          <button class="suivi-groupe-tag" data-qualification="7_jours" data-type="relance">Dans 7 jours</button>
          <button class="suivi-groupe-tag" data-qualification="14_jours" data-type="relance">Dans 14 jours</button>
          <button class="suivi-groupe-tag" data-qualification="1_mois" data-type="relance">Dans 1 mois</button>
          <button class="suivi-groupe-tag" data-qualification="date_precise" data-type="relance">Choisir une date</button>
        </div>
        <div id="suivi-groupe-relance-date-precise" hidden>
          <input type="date" id="suivi-groupe-date-precise-input" />
          <button id="suivi-groupe-enregistrer-date">Enregistrer</button>
        </div>
        <div id="suivi-groupe-precision-autre" hidden>
          <textarea id="suivi-groupe-precision-autre-input"></textarea>
        </div>
        <button id="suivi-groupe-modifier-reponse">Modifier la réponse</button>
      </div>

      <div id="suivi-groupe-etape-recap" hidden>
        <span id="suivi-groupe-recap-texte"></span>
        <span id="suivi-groupe-recap-qualification"></span>
        <button id="suivi-groupe-modifier-recap">Modifier</button>
      </div>

      <button id="suivi-groupe-soumettre" hidden></button>

      <input id="suivi-groupe-effectuee" type="hidden" form="${FORM_ID}" value="" />
      <input id="suivi-groupe-qualification-champ" type="hidden" form="${FORM_ID}" value="" />
      <input id="suivi-groupe-precision-autre-champ" type="hidden" form="${FORM_ID}" value="" />
      <input id="suivi-groupe-choix-date-revue" type="hidden" form="${FORM_ID}" value="" />
      <input id="suivi-groupe-date-precise-champ" type="hidden" form="${FORM_ID}" value="" />
    </div>
  `;
}

function ouvrirModalAvecIds(ids) {
  document.querySelectorAll('input[name="beneficiaire_ids[]"]').forEach((caseACocher) => {
    caseACocher.checked = ids.includes(caseACocher.value);
  });
  document.getElementById(MODAL_ID).dispatchEvent(new Event("dsfr.disclose"));
}

function clicBouton(selector) {
  const btn = document.querySelector(selector);
  btn.dispatchEvent(new MouseEvent("click", { bubbles: true }));
}

const CLE_TITRE_SELECTION = "admin.beneficiaires.modal_suivi_groupe.titre_selection";

function traductionSimulee(cle, options) {
  if (options && options.count !== undefined) return `${cle} count=${options.count}`;
  return cle;
}

beforeEach(() => {
  global.I18n = { t: traductionSimulee };
  document.body.innerHTML = creerModalHTML();
  init();
  ouvrirModalAvecIds(["42", "43"]);
});

describe("navigation entre les étapes", () => {
  test("cliquer Oui affiche l'étape qualification", () => {
    clicBouton('[data-effectuee="true"]');

    expect(document.getElementById("suivi-groupe-etape-question").hasAttribute("hidden")).toBe(true);
    expect(document.getElementById("suivi-groupe-etape-qualification").hasAttribute("hidden")).toBe(false);
    expect(document.getElementById("suivi-groupe-etape-recap").hasAttribute("hidden")).toBe(true);
  });

  test("cliquer Non affiche l'étape qualification", () => {
    clicBouton('[data-effectuee="false"]');

    expect(document.getElementById("suivi-groupe-etape-qualification").hasAttribute("hidden")).toBe(false);
  });

  test("cliquer Pas encore affiche l'étape qualification avec les tags relance", () => {
    clicBouton(`[data-effectuee="${REPONSE_PAS_ENCORE}"]`);

    expect(document.getElementById("suivi-groupe-etape-question").hasAttribute("hidden")).toBe(true);
    expect(document.getElementById("suivi-groupe-etape-qualification").hasAttribute("hidden")).toBe(false);
    expect(document.getElementById("suivi-groupe-tags-relance").hasAttribute("hidden")).toBe(false);
    expect(document.getElementById("suivi-groupe-tags-remediation").hasAttribute("hidden")).toBe(true);
    expect(document.getElementById("suivi-groupe-etape-recap").hasAttribute("hidden")).toBe(true);
  });

  test("cliquer un tag relance affiche l'étape récap", () => {
    clicBouton(`[data-effectuee="${REPONSE_PAS_ENCORE}"]`);
    clicBouton('[data-qualification="7_jours"]');

    expect(document.getElementById("suivi-groupe-etape-recap").hasAttribute("hidden")).toBe(false);
    expect(document.getElementById("suivi-groupe-soumettre").hasAttribute("hidden")).toBe(false);
  });

  test("cliquer 'Choisir une date' affiche le champ date sans aller au récap", () => {
    clicBouton(`[data-effectuee="${REPONSE_PAS_ENCORE}"]`);
    clicBouton('[data-qualification="date_precise"]');

    expect(document.getElementById("suivi-groupe-relance-date-precise").hasAttribute("hidden")).toBe(false);
    expect(document.getElementById("suivi-groupe-etape-recap").hasAttribute("hidden")).toBe(true);
  });

  test("cliquer un tag de remédiation affiche l'étape récap", () => {
    clicBouton('[data-effectuee="true"]');
    clicBouton('[data-qualification="formation_metier"]');

    expect(document.getElementById("suivi-groupe-etape-recap").hasAttribute("hidden")).toBe(false);
    expect(document.getElementById("suivi-groupe-soumettre").hasAttribute("hidden")).toBe(false);
  });

  test("Modifier la réponse revient à l'étape question", () => {
    clicBouton('[data-effectuee="true"]');
    clicBouton("#suivi-groupe-modifier-reponse");

    expect(document.getElementById("suivi-groupe-etape-question").hasAttribute("hidden")).toBe(false);
    expect(document.getElementById("suivi-groupe-etape-qualification").hasAttribute("hidden")).toBe(true);
  });

  test("Modifier le récap depuis pas_encore revient à l'étape qualification", () => {
    clicBouton(`[data-effectuee="${REPONSE_PAS_ENCORE}"]`);
    clicBouton('[data-qualification="7_jours"]');
    clicBouton("#suivi-groupe-modifier-recap");

    expect(document.getElementById("suivi-groupe-etape-qualification").hasAttribute("hidden")).toBe(false);
    expect(document.getElementById("suivi-groupe-tags-relance").hasAttribute("hidden")).toBe(false);
  });

  test("Modifier le récap depuis une qualification revient à l'étape qualification", () => {
    clicBouton('[data-effectuee="true"]');
    clicBouton('[data-qualification="formation_metier"]');
    clicBouton("#suivi-groupe-modifier-recap");

    expect(document.getElementById("suivi-groupe-etape-qualification").hasAttribute("hidden")).toBe(false);
  });
});

describe("texte récapitulatif", () => {
  test("utilise la traduction titre_pas_encore pour effectuee=pas_encore après tag relance", () => {
    clicBouton(`[data-effectuee="${REPONSE_PAS_ENCORE}"]`);
    clicBouton('[data-qualification="7_jours"]');

    const texte = document.getElementById("suivi-groupe-recap-texte").textContent;
    expect(texte).toBe("reponse_mise_en_action.titre_pas_encore");
  });

  test("affiche le label du délai dans la qualification récap pour pas_encore", () => {
    clicBouton(`[data-effectuee="${REPONSE_PAS_ENCORE}"]`);
    clicBouton('[data-qualification="7_jours"]');

    const qualif = document.getElementById("suivi-groupe-recap-qualification").textContent;
    expect(qualif).toBe("Dans 7 jours");
  });

  test("utilise la traduction titre_true et affiche la qualification pour effectuee=true", () => {
    clicBouton('[data-effectuee="true"]');
    clicBouton('[data-qualification="formation_metier"]');

    const texte = document.getElementById("suivi-groupe-recap-texte").textContent;
    const qualif = document.getElementById("suivi-groupe-recap-qualification").textContent;
    expect(texte).toBe("reponse_mise_en_action.titre_true");
    expect(qualif).toContain("Formation métier");
  });

  test("utilise la traduction titre_false pour effectuee=false", () => {
    clicBouton('[data-effectuee="false"]');
    clicBouton('[data-qualification="freins_peripheriques"]');

    const texte = document.getElementById("suivi-groupe-recap-texte").textContent;
    expect(texte).toBe("reponse_mise_en_action.titre_false");
  });
});

describe("label de réponse à l'étape qualification", () => {
  test("utilise la traduction titre_remediation pour Oui", () => {
    clicBouton('[data-effectuee="true"]');

    const label = document.getElementById("suivi-groupe-label-reponse").textContent;
    expect(label).toBe("qualification_mise_en_action.titre_remediation");
  });

  test("utilise la traduction titre_difficulte pour Non", () => {
    clicBouton('[data-effectuee="false"]');

    const label = document.getElementById("suivi-groupe-label-reponse").textContent;
    expect(label).toBe("qualification_mise_en_action.titre_difficulte");
  });

  test("utilise la traduction du titre de date de revue pour Pas encore", () => {
    clicBouton(`[data-effectuee="${REPONSE_PAS_ENCORE}"]`);

    const label = document.getElementById("suivi-groupe-label-reponse").textContent;
    expect(label).toBe("date_revue_mise_en_action.titre");
  });

  test("affiche les tags remédiation pour Oui et cache les tags difficulté", () => {
    clicBouton('[data-effectuee="true"]');

    expect(document.getElementById("suivi-groupe-tags-remediation").hasAttribute("hidden")).toBe(false);
    expect(document.getElementById("suivi-groupe-tags-difficulte").hasAttribute("hidden")).toBe(true);
  });

  test("affiche les tags difficulté pour Non et cache les tags remédiation", () => {
    clicBouton('[data-effectuee="false"]');

    expect(document.getElementById("suivi-groupe-tags-difficulte").hasAttribute("hidden")).toBe(false);
    expect(document.getElementById("suivi-groupe-tags-remediation").hasAttribute("hidden")).toBe(true);
  });
});

describe("titre à l'ouverture", () => {
  test("utilise la traduction du titre avec count=1 pour 1 bénéficiaire", () => {
    ouvrirModalAvecIds(["42"]);

    const titre = document.querySelector(".fr-modal__title").textContent;
    expect(titre.trim()).toBe(`${CLE_TITRE_SELECTION} count=1`);
  });

  test("utilise la traduction du titre avec le nombre de bénéficiaires sélectionnés", () => {
    const titre = document.querySelector(".fr-modal__title").textContent;
    expect(titre.trim()).toBe(`${CLE_TITRE_SELECTION} count=2`);
  });
});

describe("remplissage des champs cachés avant soumission", () => {
  test("remplit effectuee et qualification", () => {
    clicBouton('[data-effectuee="true"]');
    clicBouton('[data-qualification="formation_metier"]');

    const form = document.getElementById(FORM_ID);
    form.dispatchEvent(new Event("submit"));

    expect(document.getElementById("suivi-groupe-effectuee").value).toBe("true");
    expect(document.getElementById("suivi-groupe-qualification-champ").value).toBe("formation_metier");
  });

  test("effectuee=pas_encore et choix_date_revue sont transmis après tag relance", () => {
    clicBouton(`[data-effectuee="${REPONSE_PAS_ENCORE}"]`);
    clicBouton('[data-qualification="7_jours"]');

    const form = document.getElementById(FORM_ID);
    form.dispatchEvent(new Event("submit"));

    expect(document.getElementById("suivi-groupe-effectuee").value).toBe(REPONSE_PAS_ENCORE);
    expect(document.getElementById("suivi-groupe-qualification-champ").value).toBe("");
    expect(document.getElementById("suivi-groupe-choix-date-revue").value).toBe("7_jours");
  });
});

describe("réinitialisation à l'ouverture", () => {
  test("revient à l'étape question après navigation", () => {
    clicBouton('[data-effectuee="true"]');
    clicBouton('[data-qualification="formation_metier"]');

    ouvrirModalAvecIds(["99"]);

    expect(document.getElementById("suivi-groupe-etape-question").hasAttribute("hidden")).toBe(false);
    expect(document.getElementById("suivi-groupe-etape-recap").hasAttribute("hidden")).toBe(true);
  });
});
