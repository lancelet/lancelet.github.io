/**
 * Show and hide the hamburger menu.
 */

const hamburger_icon = document.querySelector('.hamburger');
const hamburger_dropdown = document.querySelector('#hamburger-dropdown');

if (hamburger_icon === null) {
    console.error("Could not find hamburger icon!");
}
if (hamburger_dropdown === null) {
    console.error("Could not find hamburger dropdown!");
}

function disableScroll() {
    scrollTop = document.documentElement.scrollTop;
    scrollLeft = document.documentElement.scrollLeft;
    window.onscroll = function () {
        window.scrollTo(scrollLeft, scrollTop);
    };
}

function enableScroll() {
    window.onscroll = function () { };
}

function showMenu() {
    const rect = hamburger_icon.getBoundingClientRect();
    hamburger_dropdown.style.display = 'flex';
    hamburger_dropdown.style.top = rect.bottom;
    disableScroll();
}

function hideMenu() {
    hamburger_dropdown.style.display = 'none';
    enableScroll();
}

function toggleMenu() {
    console.log(hamburger_dropdown.style.display);
    if (hamburger_dropdown.style.display != 'flex') {
        showMenu();
    } else {
        hideMenu();
    }
}

hamburger_icon.addEventListener('click', toggleMenu);