let userId = null;

document.addEventListener("DOMContentLoaded", async () => {

    const form =
        document.getElementById("userForm");

    form.addEventListener(
        "submit",
        saveUser
    );

    const params =
        new URLSearchParams(
            window.location.search
        );

    userId = params.get("id");

    if (userId) {

        document.getElementById("formTitle").textContent =
            "Editar Usuario";

        await loadUser(userId);

    }

});

async function loadUser(id) {

    try {

        const response =
            await get(`/users/${id}`);

        const user = response.data;

        document.getElementById("nombre").value =
            user.nombre || "";

        document.getElementById("apellido").value =
            user.apellido || "";

        document.getElementById("fecha_nacimiento").value =
            user.fecha_nacimiento
                ? user.fecha_nacimiento.substring(0,10)
                : "";

        document.getElementById("sexo").value =
            user.sexo || "";

        document.getElementById("direccion").value =
            user.direccion || "";

        document.getElementById("telefono").value =
            user.telefono || "";

        document.getElementById("email").value =
            user.email || "";

        document.getElementById("provincia").value =
            user.provincia || "";

        document.getElementById("nivel_educacion").value =
            user.nivel_educacion || "";

        // Ocultar contraseña en modo edición		
	const passwordField = document.getElementById("password");

	passwordField.required = false;

	passwordField.value = "";

	passwordField.parentElement.style.display = "none";
		

    } catch (error) {

        alert(error.message);

    }

}

async function saveUser(event) {

    event.preventDefault();

    const user = {

        nombre:
            document.getElementById("nombre").value,

        apellido:
            document.getElementById("apellido").value,

        fecha_nacimiento:
            document.getElementById("fecha_nacimiento").value,

        sexo:
            document.getElementById("sexo").value,

        direccion:
            document.getElementById("direccion").value,

        telefono:
            document.getElementById("telefono").value,

        email:
            document.getElementById("email").value,

        provincia:
            document.getElementById("provincia").value,

        nivel_educacion:
            document.getElementById("nivel_educacion").value

    };

    try {

        if (userId) {

            await put(
                `/users/${userId}`,
                user
            );

            alert("Usuario actualizado correctamente");

        } else {

            user.password =
                document.getElementById("password").value;

            await post(
                "/users",
                user
            );

            alert("Usuario creado correctamente");

        }

        window.location.href =
            "dashboard.html";

    } catch (error) {

        alert(error.message);

    }

}