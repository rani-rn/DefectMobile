
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
