
<!doctype html>
<html lang="en">
  <head>
    <!-- Required meta tags -->
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <link rel="stylesheet" href="css/estilos.css">
    <link rel="stylesheet" href="css/mediaquer.css">
    <!-- Bootstrap CSS -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.0.2/dist/css/bootstrap.min.css" rel="stylesheet" integrity="sha384-EVSTQN3/azprG1Anm3QDgpJLIm9Nao0Yz1ztcQTwFspd3yD65VohhpuuCOmLASjC" crossorigin="anonymous">
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
    <!-- <div class="cabecera">
                <img src="images/cabecera.jpg" />
                <h2>Nuestros precios</h2>
            </div> -->

    <div class="carousel-wrapper">
        <div id="carouselExampleControls" class="carousel slide" data-bs-ride="carousel">
          <div class="carousel-inner">
            <div class="carousel-item active">
              <div class="text-inner-slide">
                <h2>
                  <span> PARA</span>
                  PELUQUERÍAS,
                  <span> BARBERÍAS</span> Y
                  CENTROS DE
                  <span>  ESTÉTICA</span>
                </h2>
            
              </div>
              <img src="images/slide2.png" class="fondo-slide" alt="...">
            </div>

          </div>
          <button class="carousel-control-prev" type="button" data-bs-target="#carouselExampleControls" data-bs-slide="prev">
            <span class="carousel-control-prev-icon" aria-hidden="true"></span>
            <span class="visually-hidden">Previous</span>
          </button>
          <button class="carousel-control-next" type="button" data-bs-target="#carouselExampleControls" data-bs-slide="next">
            <span class="carousel-control-next-icon" aria-hidden="true"></span>
            <span class="visually-hidden">Next</span>
          </button>
        </div>
     
        <div class="curvatura">
          <svg viewBox="0 0 1440 120" xmlns="http://www.w3.org/2000/svg">
            <path fill="#ffce00" d="M0,0 C480,80 960,80 1440,0 L1440,120 L0,120 Z"></path>
          </svg>
        </div>
      </div>
</section>

<section class="business">
 <div class="wrapper">
  <h2>Gestiona <span>fácilmente
    las citas de</span> tu negocio</h2>
    <div class="flexR">
    <div class="left">
    <p>Si tienes una peluquería,
      barbería o centro de estética,
      SimplyTech te ayuda a
      organizar tus citas, horarios
      y clientes de manera sencilla
      y eficiente. Empieza a optimizar
      tu negocio hoy mismo.</p>
      <h4>¡Regístrate gratis
        y gestiona tus citas online!</h4>
        <a href="<?php echo SUX_SALON; ?>/registrar-negocio" class="button buttonR" target="_blank">Regístrate gratis</a>
    </div>
    <div class="right">
    <img src="images/peluquera.png" />
    </div>
  </div>
 </div>
 
</section>
<section>
    <div class="descubre">
        <div class="wrapper">
   
          <div class="text-box">
    
          <h2>
            ¿Eres dueño de una peluquería,
            barbería o centro de estética?
          </h2>
    <p>
      Gestiona tu negocio de forma integral: agenda citas online, controla
      cobros y pagos, administra clientes, empleados y horarios, genera
      informes, lanza promociones, gestiona productos y servicios, y atrae
      más clientes con tu propia web. ¡Todo en una sola plataforma!
    </p>
              <a href="<?php echo SUX_SALON; ?>/registrar-negocio" target="_blank"><button class="button buttonY">Descubre cómo</button></a>
</div>

</div>
</div>
</section>
<section>
  <div class="container py-5 prices">
    <div class="row justify-content-center">
        <div class="col-lg-3 col-md-6 mb-4">
            <div class="card pricing-card h-100 border-0 shadow-lg rounded-lg overflow-hidden">
                <div class="card-header text-center py-4">
                    <h4 class="mb-0">PLAN
                      BÁSICO</h4>
                      <p>Ideal para quienes
                        solo necesitan una
                        presencia digital</p>
                </div>
                <div class="card-body">
                    <h2 class="display-4 text-center mb-4 bgRed text-white">GRATIS</h2>
                    <div class="inside-body">
                    <ul class="list-unstyled mb-4">
                        <li class="mb-3"><i class="fa fa-check"></i>Gestión de citas en tiempo real</li>
                        <li class="mb-3"><i class="fa fa-check"></i>Gestión de cobros</li>
                        <li class="mb-3"><i class="fa fa-check"></i>Control de horarios y disponibilidad</li>
                        <li class="mb-3"><i class="fa fa-check"></i>Generación de plataforma web para clientes</li>
                        <li class="mb-3"><i class="fa fa-check"></i>Gestión de un salón</li>
                        <li class="mb-3"><img src="images/uncheck.png" />Multi gestión de salones (hasta 3)</li>
                        <li class="mb-3"><img src="images/uncheck.png" />Acceso a informes y estadísticas.</li>
                        <li class="mb-3"><img src="images/uncheck.png" />Creación de promociones</li>
                        <li class="mb-3"><img src="images/uncheck.png" /></i>Calendario</li>
                        <li class="mb-3"><img src="images/uncheck.png" /></i>Gestión de empleados y clientes</li>
                        <li class="mb-3"><img src="images/uncheck.png" /></i>Productos y servicios</li>
                        <li class="mb-3"><img src="images/uncheck.png" /></i>Gestión de caja</li>
                        <li class="mb-3"><img src="images/uncheck.png" /></i>Hoja de gastos</li>
                    </ul>
                    <div class="buttons">
                        <a href="#" class="button btn-red bgRed text-white">ACTIVAR AHORA</a>
                    </div>
                  </div>
                </div>
            </div>
        </div>
        <div class="col-lg-3 col-md-6 mb-4">
          <div class="card pricing-card h-100 border-0 shadow-lg rounded-lg overflow-hidden">
              <div class="card-header text-center py-4">
                  <h4 class="mb-0">PLAN 1
                    SUCURSAL</h4>
                    <p>Gestión completa
                      para una única
                      sucursal con hasta
                      5 empleados</p>
              </div>
              <div class="card-body">

                  <h2 class="display-4 text-center mb-4 bgRed text-white">40 USD
                    MES</h2>
                    <div class="inside-body">
                  <ul class="list-unstyled mb-4">
                      <li class="mb-3"><i class="fa fa-check"></i>Gestión de citas en tiempo real</li>
                      <li class="mb-3"><i class="fa fa-check"></i>Gestión de cobros</li>
                      <li class="mb-3"><i class="fa fa-check"></i>Control de horarios y disponibilidad</li>
                      <li class="mb-3"><i class="fa fa-check"></i>Generación de plataforma web para clientes</li>
                      <li class="mb-3"><i class="fa fa-check"></i>Gestión de un salón</li>
                      <li class="mb-3"><i class="fa fa-check"></i>Multi gestión de salones (hasta 3)</li>
                      <li class="mb-3"><i class="fa fa-check"></i>Acceso a informes y estadísticas.</li>
                      <li class="mb-3"><i class="fa fa-check"></i>Creación de promociones</li>
                      <li class="mb-3"><i class="fa fa-check"></i>Calendario</li>
                      <li class="mb-3"><i class="fa fa-check"></i>Gestión de empleados y clientes</li>
                      <li class="mb-3"><i class="fa fa-check"></i>Productos y servicios</li>
                      <li class="mb-3"><i class="fa fa-check"></i>Gestión de caja</li>
                      <li class="mb-3"><i class="fa fa-check"></i>Hoja de gastos</li>
                  </ul>
                  <div class="buttons">
                      <a href="#" class="button btn-red bgRed text-white">CONTRATAR</a>
                  </div>
                  </div>
              </div>
          </div>
      </div>
      <div class="col-lg-3 col-md-6 mb-4">
        <div class="card pricing-card h-100 border-0 shadow-lg rounded-lg overflow-hidden">
            <div class="card-header text-center py-4">
                <h4 class="mb-0">PLAN 3
                  SUCURSAL</h4>
                  <p>Gestión de hasta 3
                    sucursales y hasta
                    15 empleados desde
                    una única cuenta.</p>
            </div>
            <div class="card-body">
              <h2 class="display-4 text-center mb-4 bgRed text-white">100 USD
                MES</h2>
                <div class="inside-body">
              <ul class="list-unstyled mb-4">
                  <li class="mb-3"><i class="fa fa-check"></i>Todas las funciones
                    del plan básico</li>
                  <li class="mb-3"><i class="fa fa-check"></i>Informes y
                    estadísticas detallada</li>
                  <li class="mb-3"><i class="fa fa-check"></i>Gestión avanzada
                    de clientes</li>
                  <li class="mb-3"><i class="fa fa-check"></i>Gestión de cobros</li>
                  <li class="mb-3"><i class="fa fa-check"></i>Calendario</li>
                  <li class="mb-3"><i class="fa fa-check"></i>Citas y eventos</li>
                  <li class="mb-3"><i class="fa fa-check"></i>Gestion de empleado
                    y clientes</li>
                  <li class="mb-3"><i class="fa fa-check"></i>Productos y servicios</li>
              </ul>
              <div class="buttons">
                  <a href="#" class="button btn-red bgRed text-white">CONTRATAR</a>
              </div>
              </div>
          </div>
        </div>
    </div>
    <div class="col-lg-3 col-md-6 mb-4">
      <div class="card pricing-card h-100 border-0 shadow-lg rounded-lg overflow-hidden">
          <div class="card-header text-center py-4">
              <h4 class="mb-0">PLAN
                PREMIUM</h4>
                <p>Sin límites de
                  sucursales ni
                  empleados</p>
          </div>
          <div class="card-body">
            <h2 class="display-4 text-center mb-4 bgYellow text-red">SOLICITAR
              PRESUPUESTO</h2>
              <div class="inside-body">
            <ul class="list-unstyled mb-4">
                <li class="mb-3"><i class="fa fa-check"></i>Todas las funciones
                  del plan básico</li>
                <li class="mb-3"><i class="fa fa-check"></i>Informes y
                  estadísticas detallada</li>
                <li class="mb-3"><i class="fa fa-check"></i>Gestión avanzada
                  de clientes</li>
                <li class="mb-3"><i class="fa fa-check"></i>Gestión de cobros</li>
                <li class="mb-3"><i class="fa fa-check"></i>Calendario</li>
                <li class="mb-3"><i class="fa fa-check"></i>Citas y eventos</li>
                <li class="mb-3"><i class="fa fa-check"></i>Gestion de empleado
                  y clientes</li>
                <li class="mb-3"><i class="fa fa-check"></i>Productos y servicios</li>
            </ul>
            <div class="buttons">
                <a href="#" class="button btn-red bgRed text-white">CONTRATAR</a>
            </div>
            </div>
        </div>
      </div>
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
