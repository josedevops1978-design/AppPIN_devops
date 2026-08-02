const API_URL = "http://localhost:3000/api";

async function request(endpoint, options = {}) {

    const token = localStorage.getItem("token");

    const response = await fetch(
        `${API_URL}${endpoint}`,
        {
            ...options,

            headers: {

                "Content-Type": "application/json",

                Authorization: `Bearer ${token}`,

                ...options.headers

            }

        }
    );

    const data = await response.json();

    if (!response.ok) {

        throw new Error(
            data.message || "Error del servidor"
        );

    }

    return data;

}

async function get(endpoint) {

    return request(endpoint);

}

async function post(endpoint, body) {

    return request(endpoint, {

        method: "POST",

        body: JSON.stringify(body)

    });

}

async function put(endpoint, body) {

    return request(endpoint, {

        method: "PUT",

        body: JSON.stringify(body)

    });

}

async function del(endpoint) {

    return request(endpoint, {

        method: "DELETE"

    });

}