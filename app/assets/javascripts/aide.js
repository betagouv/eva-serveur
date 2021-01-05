var sections = []

function isInViewport(elm) {
  var rect = elm.getBoundingClientRect();
  var viewHeight = Math.max(document.documentElement.clientHeight, window.innerHeight);
  return !(rect.bottom < 0 || rect.top - viewHeight >= 0);
}


const onIntersection = (entries) => {
  var sections_visibles = sections.filter(s => {
    return isInViewport(document.querySelector(s))
  });
  document.querySelectorAll('.menu_aide ul li a').forEach(el => {
    if(el.hash === sections_visibles[0]) {
      el.classList.add('active');
    } else {
      el.classList.remove('active');
    }
  });
};

document.addEventListener("DOMContentLoaded", () => {
  const observer = new IntersectionObserver(onIntersection);
  document.querySelectorAll('.menu_aide ul li a').forEach(el => {
    observer.observe(document.querySelector(el.hash));
    sections.push(el.hash);
  });
});
