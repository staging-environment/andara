<!doctype html>
<html lang="en">

<head>
    <!-- Required meta tags -->
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <link rel="stylesheet" href="css/estilos.css">
    <link rel="stylesheet" href="css/mediaquer.css">
    <!-- Bootstrap CSS -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.0.2/dist/css/bootstrap.min.css" rel="stylesheet"
        integrity="sha384-EVSTQN3/azprG1Anm3QDgpJLIm9Nao0Yz1ztcQTwFspd3yD65VohhpuuCOmLASjC" crossorigin="anonymous">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.7.2/css/all.min.css">
    <title>Hello, world!</title>
</head>

<body>
    <div class="content wrapper-body">
        <div class="topNav">
            <ul>
                <li><a href="<?php echo SUX_SALON; ?>/registrar-negocio" target="_blank">Regístrate</a></li>
                <li><a href="<?php echo SUX_SALON; ?>/login" target="_blank">Haz login</a></li>
            </ul>
        </div>
        <?php include 'cabecera.php'; ?>
        <section>
            <div class="cabecera">
                <img src="images/cabecera.jpg" />
                <h2>Listado de productos</h2>
            </div>
            <!-- <div class="carousel-wrapper">
                <div id="carouselExampleControls" class="carousel slide" data-bs-ride="carousel">
                    <div class="carousel-inner">
                        <div class="carousel-item active">
                            <div class="text-inner-slide">
                                <h2>
                                    Empieza a <span>transformar</span> tu negocio hoy
                                </h2>
                                <p>
                                    Comienza una demo gratuita y descubre lo fácil que es digitalizar tu peluquería.
                                </p>
                                <button class="buttonY">Quiero una demo</button>
                            </div>
                            <img src="images/slide1.png" class="fondo-slide" alt="...">
                            <h3>NUESTROS SOFTWARE</h3>
                        </div>
                        <div class="carousel-item">
                            <div class="text-inner-slide">
                                <h2>
                                    Empieza a <span>transformar</span> tu negocio hoy
                                </h2>
                                <p>
                                    Comienza una demo gratuita y descubre lo fácil que es digitalizar tu peluquería.
                                </p>
                                <button class="buttonY">Quiero una demo</button>
                            </div>
                            <img src="images/slide2.png" class="fondo-slide" alt="...">
                        </div>
                        <div class="carousel-item">
                            <div class="text-inner-slide">
                                <h2>
                                    Empieza a <span>transformar</span> tu negocio hoy
                                </h2>
                                <p>
                                    Comienza una demo gratuita y descubre lo fácil que es digitalizar tu peluquería.
                                </p>
                                <button class="buttonY">Quiero una demo</button>
                            </div>
                            <img src="images/slide3.png" class="fondo-slide" alt="...">
                        </div>
                    </div>
                    <button class="carousel-control-prev" type="button" data-bs-target="#carouselExampleControls"
                        data-bs-slide="prev">
                        <span class="carousel-control-prev-icon" aria-hidden="true"></span>
                        <span class="visually-hidden">Previous</span>
                    </button>
                    <button class="carousel-control-next" type="button" data-bs-target="#carouselExampleControls"
                        data-bs-slide="next">
                        <span class="carousel-control-next-icon" aria-hidden="true"></span>
                        <span class="visually-hidden">Next</span>
                    </button>
                </div>

               
                <div class="curvatura">
                    <svg viewBox="0 0 1440 120" xmlns="http://www.w3.org/2000/svg">
                        <path fill="#ffce00" d="M0,0 C480,80 960,80 1440,0 L1440,120 L0,120 Z"></path>
                    </svg>
                </div>
            </div> -->
        </section>
        <section>
            <div class="listado bgYellow">
                <h1 class="text-red">Conoce <span>todos <br />nuestros</span> 
                </br>productos</h1>
                <div class="row">
                    
                      <div class="col-sm-6">
                        <div class="card">
                            <div class="card-body">
                                <div class="img">
                                    <img src="images/estetica3.jpg" />
                                </div>
                                <div class="content">
                                    <h5 class="card-title">Titulo 1</h5>
                                    <p class="card-text">Lorem ipsum dolor, sit amet consectetur adipisicing elit.
                                        Animi, cupiditate provident esse quod hic minus. </p>
                                    <a href="salon.html" class="buttonY">Más info</a>
                                </div>
                            </div>
                        </div>
                    </div>
                    
                      <div class="col-sm-6">
                        <div class="card">
                            <div class="card-body">
                                <div class="img">
                                    <img src="images/estetica2.jpg" />
                                </div>
                                <div class="content">
                                    <h5 class="card-title">Titulo 1</h5>
                                    <p class="card-text">Lorem ipsum dolor, sit amet consectetur adipisicing elit.
                                        Animi, cupiditate provident esse quod hic minus. </p>
                                    <a href="#" class="buttonY">Más info</a>
                                </div>
                            </div>
                        </div>
                    </div>
                      <div class="col-sm-6">
                        <div class="card">
                            <div class="card-body">
                                <div class="img">
                                    <img src="images/estetica3.jpg" />
                                </div>
                                <div class="content">
                                    <h5 class="card-title">Titulo 1</h5>
                                    <p class="card-text">Lorem ipsum dolor, sit amet consectetur adipisicing elit.
                                        Animi, cupiditate provident esse quod hic minus. </p>
                                    <a href="#" class="buttonY">Más info</a>
                                </div>
                            </div>
                        </div>
                    </div>
                      <div class="col-sm-6">
                        <div class="card">
                            <div class="card-body">
                                <div class="img">
                                    <img src="images/barber1.jpg" />
                                </div>
                                <div class="content">
                                    <h5 class="card-title">Titulo 1</h5>
                                    <p class="card-text">Lorem ipsum dolor, sit amet consectetur adipisicing elit.
                                        Animi, cupiditate provident esse quod hic minus. </p>
                                    <a href="#" class="buttonY">Más info</a>
                                </div>
                            </div>
                        </div>
                    </div>
                      <div class="col-sm-6">
                        <div class="card">
                            <div class="card-body">
                                <div class="img">
                                    <img src="images/barber2.jpg" />
                                </div>
                                <div class="content">
                                    <h5 class="card-title">Titulo 1</h5>
                                    <p class="card-text">Lorem ipsum dolor, sit amet consectetur adipisicing elit.
                                        Animi, cupiditate provident esse quod hic minus. </p>
                                    <a href="#" class="buttonY">Más info</a>
                                </div>
                            </div>
                        </div>
                    </div>
                      <div class="col-sm-6">
                     
                        <div class="card">
                       
                            <div class="card-body">
                                <div class="img">
                                    <img src="images/cafe1.jpg" />
                                </div>
                                <div class="content">
                                    <h5 class="card-title">Titulo 1</h5>
                                    <p class="card-text">Lorem ipsum dolor, sit amet consectetur adipisicing elit.
                                        Animi, cupiditate provident esse quod hic minus. </p>
                                    <a href="#" class="buttonY">Más info</a>
                                </div>
                            </div>
                           
                        </div>
                
                    </div>
                      <div class="col-sm-6">
                        <div class="card">
                            <div class="card-body">
                                <div class="img">
                                    <img src="images/cafe2.jpg" />
                                </div>
                                <div class="content">
                                    <h5 class="card-title">Titulo 1</h5>
                                    <p class="card-text">Lorem ipsum dolor, sit amet consectetur adipisicing elit.
                                        Animi, cupiditate provident esse quod hic minus. </p>
                                    <a href="#" class="buttonY">Más info</a>
                                </div>
                            </div>
                        </div>
                    </div>
                  
                </div>
                  <div class="pagination">
                    <nav aria-label="Page navigation">
  <ul class="pagination">
    <li class="page-item"><a class="page-link" href="#"><i class="fa-solid fa-chevron-left"></i></a></li>
    <li class="page-item"><a class="page-link" href="#">1</a></li>
    <li class="page-item"><a class="page-link" href="#">2</a></li>
    <li class="page-item"><a class="page-link" href="#"><i class="fa-solid fa-chevron-right"></i></a></li>
  </ul>
</nav>
                    </div>
            </div>
    </div>
    </section>


    <footer>
        <div class="footerTop">
            <div class="content">
                <div class="flexR inner">
                    <h3>Clientes:</h3>
                    <img src="images/clients.png" />
                </div>
                <div class="divider"></div>


                <div class="footerBottom">
                    <div class="content">
                        <p>There are many variations of passages </p>
                        <div class="flexR inner">

                            <div class="icons">
                                <i class="fab fa-facebook-f"></i>
                                <i class="fab fa-instagram"></i>
                                <i class="fab fa-linkedin"></i>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </footer>
    </div>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
    <script src="js/app.js"></script>
</body>

</html>