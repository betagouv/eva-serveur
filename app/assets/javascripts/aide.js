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
  document.querySelectorAll('.menu-transverse ul li a').forEach(el => {
    if(el.hash === sections_visibles[0]) {
      el.classList.add('active');
    } else {
      el.classList.remove('active');
    }
  });
};

document.addEventListener("DOMContentLoaded", () => {
  const observer = new IntersectionObserver(onIntersection);
  document.querySelectorAll('.menu-transverse ul li a').forEach(el => {
    const section = document.querySelector(el.hash);
    if(section) {
      observer.observe(section);
      sections.push(el.hash);
    }
    else {
      el.parentNode.removeChild(el);
    }
  });
});
