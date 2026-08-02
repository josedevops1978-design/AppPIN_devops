document.addEventListener("DOMContentLoaded", () => {

    const token = localStorage.getItem("token");

    if (!token) {

        window.location.href = "login.html";
        return;

    }

    const usuario = JSON.parse(
        localStorage.getItem("usuario")
    );

    if (usuario) {

        document.getElementById("userName").textContent =
            `${usuario.nombre} ${usuario.apellido}`;

    }

    const logoutButton =
        document.getElementById("logoutBtn");

    if (logoutButton) {

        logoutButton.addEventListener(
            "click",
            logout
        );

    }

    const newUserButton =
        document.getElementById("newUser");

    if (newUserButton) {

        newUserButton.addEventListener(
            "click",
            () => {

                window.location.href = "user-form.html";

            }
        );

    }

    loadUsers();

});