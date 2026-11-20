/**
 * @jest-environment jsdom
 */

const { init } = require("../../app/assets/javascripts/filtre_recherche.js");

let options;

function champCache() {
  return document.getElementById("q_campagne_id_eq");
}

beforeEach(() => {
  options = null;
  global.initialiseAutocomplete = jest.fn((opts) => {
    options = opts;
    opts.element.innerHTML = `<input id="${opts.id}" />`;
  });
  global.fetch = jest.fn(() => Promise.resolve({
    json: () => Promise.resolve([ { id: 7, display_name: "Paris 2019" } ])
  }));
  document.body.innerHTML = `
    <form id="formulaire">
    <div class="filtres__panneau" id="menu-campagne" data-application-immediate>
    <div data-filtre-recherche data-url="/admin/campagnes.json"
         data-predicat="libelle_or_code_cont" data-libelle-valeur="Lyon">
      <div data-filtre-recherche-saisie data-identifiant="q_campagne_id_eq_recherche"></div>
      <input type="hidden" id="q_campagne_id_eq" name="q[campagne_id_eq]" value="3" />
    </div>
    </div>
    </form>
  `;
  HTMLFormElement.prototype.requestSubmit = jest.fn();
  init();
});

test("affiche le libellé de la valeur déjà choisie dans un champ non transmis", () => {
  expect(options.id).toBe("q_campagne_id_eq_recherche");
  expect(options.name).toBe("");
  expect(options.defaultValue).toBe("Lyon");
});

test("cherche les propositions avec le prédicat ransack", async () => {
  const populate = jest.fn();

  await options.source("par is", populate);

  expect(fetch).toHaveBeenCalledWith(
    "/admin/campagnes.json?q%5Blibelle_or_code_cont%5D=par+is",
    { headers: { Accept: "application/json" } }
  );
  expect(populate).toHaveBeenCalledWith([ { id: 7, display_name: "Paris 2019" } ]);
});

test("ajoute la recherche aux paramètres déjà présents dans l'adresse", async () => {
  document.querySelector("[data-filtre-recherche]").dataset.url = "/admin/campagnes.json?order=libelle_asc";

  await options.source("par", jest.fn());

  expect(fetch.mock.calls[0][0]).toBe(
    "/admin/campagnes.json?order=libelle_asc&q%5Blibelle_or_code_cont%5D=par"
  );
});

test("affiche le nom d'affichage des propositions", () => {
  const proposition = { id: 7, display_name: "Paris 2019" };

  expect(options.templates.suggestion(proposition)).toBe("Paris 2019");
  expect(options.templates.inputValue(proposition)).toBe("Paris 2019");
});

test("applique le filtre dès qu'une proposition est choisie", () => {
  options.onConfirm({ id: 7, display_name: "Paris 2019" });

  expect(champCache().value).toBe("7");
  expect(HTMLFormElement.prototype.requestSubmit).toHaveBeenCalledTimes(1);
});

test("retient le choix sans soumettre dans un menu qui s'applique avec un bouton", () => {
  document.getElementById("menu-campagne").removeAttribute("data-application-immediate");

  options.onConfirm({ id: 7, display_name: "Paris 2019" });

  expect(champCache().value).toBe("7");
  expect(HTMLFormElement.prototype.requestSubmit).not.toHaveBeenCalled();
});

test("ne soumet rien quand la saisie est quittée sans choix", () => {
  options.onConfirm(undefined);

  expect(champCache().value).toBe("3");
  expect(HTMLFormElement.prototype.requestSubmit).not.toHaveBeenCalled();
});

test("place le curseur dans la saisie à l'ouverture du menu", () => {
  document.getElementById("menu-campagne").dispatchEvent(new Event("dsfr.disclose"));

  expect(document.activeElement.id).toBe("q_campagne_id_eq_recherche");
});

test("oublie la valeur quand la saisie est vidée", () => {
  const saisie = document.getElementById("q_campagne_id_eq_recherche");
  saisie.value = " ";
  saisie.dispatchEvent(new Event("input", { bubbles: true }));

  expect(champCache().value).toBe("");
});
