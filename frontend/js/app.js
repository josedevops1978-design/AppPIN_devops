document.addEventListener(
    "DOMContentLoaded",
    () => {


        const form =
            document.getElementById("loginForm");


        if(form){

            form.addEventListener(
                "submit",
                async(e)=>{


                    e.preventDefault();


                    const email =
                        document.getElementById("email").value;


                    const password =
                        document.getElementById("password").value;


                    const error =
                        document.getElementById(
                            "errorMessage"
                        );


                    try{


                        await login(
                            email,
                            password
                        );


                    }catch(err){


                        error.textContent =
                            err.message;


                        error.classList.remove(
                            "d-none"
                        );


                    }


                }
            );

        }


    }
);