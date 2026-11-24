/**
 * @jest-environment jsdom
 */

const { init, DELAI } = require("../../app/assets/javascripts/recherche_a_la_volee.js");

const REPONSE = `
  <html><body>
    <div id="resultats" data-actualise-a-la-volee><p>Nouveaux résultats</p></div>
    <div id="effacer" data-actualise-a-la-volee><a>Effacer</a></div>
  </body></html>`;

function saisir(texte) {
  const champ = document.getElementById("recherche");
  champ.value = texte;
  champ.dispatchEvent(new Event("input", { bubbles: true }));
}

async function attendreLaRequete() {
  jest.advanceTimersByTime(DELAI);
  await Promise.resolve();
  await Promise.resolve();
  await Promise.resolve();
}

beforeEach(() => {
  jest.useFakeTimers();
  global.fetch = jest.fn(() => Promise.resolve({ text: () => Promise.resolve(REPONSE) }));
  window.history.replaceState = jest.fn();
  document.body.innerHTML = `
    <form action="/admin/beneficiaires" method="get">
      <input type="hidden" name="order" value="nom_asc" />
      <input id="recherche" name="q[recherche]" data-recherche-a-la-volee />
    </form>
    <div id="resultats" data-actualise-a-la-volee><p>Anciens résultats</p></div>
    <div id="effacer" data-actualise-a-la-volee></div>
  `;
  init();
});

afterEach(() => {
  jest.useRealTimers();
});

test("attend la fin de la frappe avant de chercher", async () => {
  saisir("al");
  saisir("ali");
  await attendreLaRequete();

  expect(fetch).toHaveBeenCalledTimes(1);
  expect(fetch.mock.calls[0][0]).toBe(
    "http://localhost/admin/beneficiaires?order=nom_asc&q%5Brecherche%5D=ali"
  );
});

test("remplace les zones actualisées par celles de la réponse", async () => {
  saisir("ali");
  await attendreLaRequete();

  expect(document.getElementById("resultats").textContent).toContain("Nouveaux résultats");
  expect(document.getElementById("effacer").textContent).toContain("Effacer");
});

test("garde l'adresse de la page à jour", async () => {
  saisir("ali");
  await attendreLaRequete();

  expect(window.history.replaceState).toHaveBeenCalledWith(
    null, "", "http://localhost/admin/beneficiaires?order=nom_asc&q%5Brecherche%5D=ali"
  );
});

test("prévient les scripts de la page que les résultats ont changé", async () => {
  const ecouteur = jest.fn();
  document.addEventListener("resultats-actualises", ecouteur);

  saisir("ali");
  await attendreLaRequete();

  expect(ecouteur).toHaveBeenCalled();
});

test("abandonne la recherche précédente encore en cours", async () => {
  saisir("al");
  jest.advanceTimersByTime(DELAI);
  saisir("ali");
  jest.advanceTimersByTime(DELAI);

  expect(fetch.mock.calls[0][1].signal.aborted).toBe(true);
  expect(fetch.mock.calls[1][1].signal.aborted).toBe(false);
});
