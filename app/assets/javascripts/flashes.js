document.addEventListener("DOMContentLoaded", () => {
  const flashes = document.querySelector('.flashes');
  const titlebar_left = document.querySelector('#titlebar_left');
  titlebar_left.after(flashes);
});
