async function loadUsers() {

    try {

        const response = await get("/users");

        console.log(response);

        const users = response.data;

        const table =
            document.getElementById("usersTable");

        table.innerHTML = "";

        users.forEach(user => {

            table.innerHTML += `
                <tr>

                    <td>${user.id}</td>

                    <td>${user.nombre}</td>

                    <td>${user.apellido}</td>

                    <td>${user.email}</td>

                    <td>

                        <button
                            class="btn btn-warning btn-sm"
    			    onclick="editUser(${user.id})">

                            Editar

                        </button>

                        <button
                            class="btn btn-danger btn-sm ms-2"
    			    onclick="deleteUser(${user.id})">
                            
			    Eliminar

                        </button>

                    </td>

                </tr>
            `;

        });

    } catch (error) {

        console.error(error);

        alert(error.message);

    }
}

 function editUser(id) {

      window.location.href = `user-form.html?id=${id}`;

 }

async function deleteUser(id) {

    const confirmDelete =
        confirm(
            "¿Está seguro que desea eliminar este usuario?"
        );

    if (!confirmDelete) {

        return;

    }

    try {

        await del(`/users/${id}`);

        alert("Usuario eliminado correctamente");

        loadUsers();

    } catch (error) {

        alert(error.message);

    }

}