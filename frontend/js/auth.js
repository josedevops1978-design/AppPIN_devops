async function login(email, password){

    const response = await post(
        "/auth/login",
        {
            email,
            password
        }
    );


    if(response.token){

        localStorage.setItem(
            "token",
            response.token
        );


        localStorage.setItem(
            "usuario",
            JSON.stringify(response.usuario)
        );


        window.location.href =
            "dashboard.html";

    }else{

        throw new Error(
            response.message || "Error de login"
        );

    }

  }   
 
  function logout(){

    	localStorage.removeItem("token");

    	localStorage.removeItem("usuario");


    	window.location.href = "login.html";

  }
