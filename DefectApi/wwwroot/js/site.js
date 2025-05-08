// Please see documentation at https://learn.microsoft.com/aspnet/core/client-side/bundling-and-minification
// for details on configuring this project to bundle and minify static web assets.

// Write your JavaScript code.
const wrapper = document.getElementById("wrapper");
const content = document.getElementById("page-content-wrapper");

document.getElementById("menu-toggle").addEventListener("click", function () {
    wrapper.classList.toggle("toggled");
    content.classList.toggle("content-shifted");
});
document.addEventListener('DOMContentLoaded', function () {
    const sidebar = document.querySelector('.sidebar');
    const overlay = document.getElementById('sidebarOverlay');
    const toggleButton = document.getElementById('sidebarToggle');

    toggleButton?.addEventListener('click', function () {
        sidebar.classList.toggle('show');
        overlay.classList.toggle('show');
    });

    overlay?.addEventListener('click', function () {
        sidebar.classList.remove('show');
        overlay.classList.remove('show');
    });
});
