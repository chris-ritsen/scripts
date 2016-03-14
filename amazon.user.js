// ==UserScript==
// @match http://*.amazon.com/*
// ==/UserScript==

window.scrollTo = function() {};
window.scroll = function() {};

window.addEventListener("scroll", function(event) {
  event.preventDefault();
  event.stopPropagation();
})

