/**
 * @jest-environment jsdom
 */

global.ClipboardJS = jest.fn(() => ({ on: jest.fn() }));
const { afficheInfobulleCopie } = require("../../app/assets/javascripts/bouton_copier.js");

describe("afficheInfobulleCopie", () => {
  let show;
  let hide;
  let bouton;
  let infobulle;

  beforeEach(() => {
    jest.useFakeTimers();
    show = jest.fn();
    hide = jest.fn();
    window.dsfr = jest.fn(() => ({ tooltip: { show, hide } }));
    document.body.innerHTML = `
      <button aria-describedby="infobulle">Copier</button>
      <span id="infobulle" class="fr-tooltip" hidden></span>`;
    bouton = document.querySelector("button");
    infobulle = document.getElementById("infobulle");
  });

  afterEach(() => jest.useRealTimers());

  it("retrouve l'infobulle quand le bouton est aussi décrit par un autre élément", () => {
    document.body.innerHTML = `
      <a id="campagne">Campagne</a>
      <button aria-describedby="campagne infobulle">Copier</button>
      <span id="infobulle" class="fr-tooltip" hidden></span>`;

    afficheInfobulleCopie(document.querySelector("button"));

    expect(window.dsfr).toHaveBeenCalledWith(document.getElementById("infobulle"));
    expect(document.getElementById("infobulle").hidden).toBe(false);
  });

  it("affiche l'infobulle puis la masque après quelques secondes", () => {
    afficheInfobulleCopie(bouton);

    expect(infobulle.hidden).toBe(false);
    expect(show).toHaveBeenCalled();
    expect(hide).not.toHaveBeenCalled();

    jest.advanceTimersByTime(2000);

    expect(hide).toHaveBeenCalled();
    expect(infobulle.hidden).toBe(true);
  });
});
