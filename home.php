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
    <div class="carousel-wrapper">
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
                  <a href="/precios" class buttonY>Quiero una demo</a>
              </div>
              <img src="images/slide1.png" class="fondo-slide" alt="...">
              <h3>NUESTROS SOFTWARE</h3>
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
      
        <!-- Curva SVG inferior -->
        <div class="curvatura">
          <svg viewBox="0 0 1440 120" xmlns="http://www.w3.org/2000/svg">
            <path fill="#e4e3df" d="M0,0 C480,80 960,80 1440,0 L1440,120 L0,120 Z"></path>
          </svg>
        </div>
      </div>
</section>

<section class="team">
<div class="tab-wrap">
  
    <input type="radio" name="tabs" id="tab1" checked>
    <div class="tab-label-content" id="tab1-content">
      <label for="tab1">Estética</label>
    
      <div class="tab-content">
          <div class="group-left">          
                <img src="images/team2.jpg" />
                    
        </div>
         <div class="group-right">  
          <h3 class="text-red">Descubre la revolución digital en la gestión de peluquerías y centros de estética</h3>
       <p> Con nuestra plataforma, tendrás el control total de tu negocio: gestiona cobros, clientes, reservas y la caja diaria con unos cuantos clics. Ofrece a tus clientes una experiencia moderna y sencilla para reservar sus citas a través de una página web atractiva y fácil de usar.

           Con nuestra herramienta, optimizas tus procesos y ahorras tiempo, permitiéndote enfocarte en lo que realmente importa: la belleza y el bienestar de tus clientes. ¡Es hora de llevar tu negocio al siguiente nivel con una solución que entiende tus necesidades!</p>
       <button class="buttonY">Ver más</button>         
      </div>
      </div>
     
      </div>

     
    <input type="radio" name="tabs" id="tab2">
    
        <div class="tab-label-content" id="tab2-content">
      <label for="tab2">Resturantes</label>
    
      <div class="tab-content">
          <div class="group-left">          
                <img src="images/team1.jpg" />
                  
        </div>
         <div class="group-right">  
          <h3 class="text-red">Resturantes</h3>
       <p> Digitaliza la gestión de tu restaurante con una plataforma que te permite organizar reservas, pedidos y turnos de trabajo. Aumenta la eficiencia, reduce errores y ofrece una mejor experiencia a tus clientes con herramientas pensadas para el día a día de la hostelería.</p>
        <button class="buttonY">Ver más</button>         
      </div>
      </div>
     
      </div>
    
    <input type="radio" name="tabs" id="tab3">
   
        <div class="tab-label-content" id="tab3-content">
      <label for="tab3">Barbería</label>
    
      <div class="tab-content">
          <div class="group-left">          
                <img src="images/team3.jpg" />
                   
        </div>
         <div class="group-right">  
          <h3 class="text-red">Barbería</h3>
       <p> Lleva tu barbería al siguiente nivel con un sistema que te ayuda a gestionar horarios, clientes y cobros desde cualquier dispositivo. Mejora la atención al cliente y ahorra tiempo con una solución ágil, moderna y pensada para negocios como el tuyo.</p>
        <button class="buttonY">Ver más</button>         
      </div>
      </div>
     
      </div>
  
     <input type="radio" name="tabs" id="tab4">
       <div class="tab-label-content" id="tab4-content">
      <label for="tab4">Cafetería</label>
    
      <div class="tab-content">
          <div class="group-left">          
                <img src="images/team4.jpg" />
                       
        </div>
         <div class="group-right">  
          <h3 class="text-red">Cafetería</h3>
       <p> Lorem ipsum dolor sit amet, consectetur adipiscing elit. Duis laoreet eget lectus eu congue. Nam finibus urna eget nisl aliquam, 
        in dictum ligula feugiat. Donec mollis ligula purus, et interdum velit bibendum eget. Aliquam magna diam, tristique eu libero nec, 
        sagittis finibus sapien. Cras a ex ultricies, faucibus elit sagittis, maximus nisi. Donec quis arcu sapien. Aenean risus nibh, varius sed porttitor a, 
        ornare nec leo. Sed vitae lacus in ipsum varius sagittis. Ut in quam cursus, ullamcorper sapien posuere, laoreet elit. Suspendisse interdum, 
        risus ut ultricies scelerisque, nibh est commodo leo, sed tristique nisl odio et turpis. Fusce pellentesque nunc nec arcu feugiat accumsan. 
        Praesent mauris sem, eleifend sit amet tortor in, cursus vehicula arcu. Curabitur convallis sit amet nunc ac feugiat. 
        Sed at risus id diam porta pretium id vel felis. Donec nec dui id nisl hendrerit laoreet eu id odio.</p>
        <button class="buttonY">Ver más</button>         
      </div>
      </div>
     
      </div>
  
</div>
</section>

<section>
    <div class="weAre">
        <div class="wrapper">
        <div class="left">
<div class="text-box">
    
    <h2>
        NOSOTROS
    </h2>
    <p>
        There are many variations of passages of Lorem Ipsum available, but the majority have suffered alteration in form. 
        Duis aute irure dolor in reprehenderit in voluptate.
    </p>
    <div class="list">
        <div class="item1">
            <div class="circle"></div>
            <p>Lorem ipsum dolor <span>Lorem ipsum dolor sit amet consectetur adipisicing elit. </span></p>
        </div>
        <div class="item2">
            <div class="circle2"></div>
            <p>Lorem ipsum dolor <span>Lorem ipsum dolor sit amet consectetur adipisicing elit. </span></p>
        </div>
    </div>
</div>
</div>
<div class="right">
    <img src="images/team.png" />
</div>
</div>
</div>
</section>
<section>
    <div class="why">
        <div class="wrapper">
            <div class="left">
                <h2>
                    ¿Por qué elegir Andara?
                </h2>
                <p>
                    There are many variations of passages of Lorem Ipsum available, but the majority have suffered alteration in form. 
        Duis aute irure dolor in reprehenderit in voluptate.
                </p>
                </div>
                <div class="right">
                    <img src="images/template.jpg" />
                    <ul>
                        <li><img src="images/check.png" />Agenda digital con recordatorios automáticos</li>
                        <li><img src="images/check.png" />Gestión de clientes y fichas personalizadas</li>
                        <li><img src="images/check.png" />Control de caja y métodos de pago</li>
                        <li><img src="images/check.png" />Sistema multiusuario con roles</li>
                        <li><img src="images/check.png" />Compatible con móviles, tablets y Pc</li>
                    </ul>
                </div>
                </div> 
    </div>
</section>
<section>
    <div class="formulario">
        <div class="wrapper fullW">
            <div class="left">
                <img src="images/women.jpg" />
            </div>
            <div class="right">
                <h2>
                    Sé parte <span>de <br />nuestra</span> familia <br />Andara
                </h2>
                <p>
                    There are many variations of passages 
                </p>
                <div class="form">
                    <div class="mb-3">
                        
                        <input type="text" class="form-control" id="exampleFormControlInput1" placeholder="input">
                      </div>
                      <div class="mb-3">
                      
                        <input type="text" class="form-control" id="exampleFormControlInput1" placeholder="input">
                      </div>
                      <button>Button</button>
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