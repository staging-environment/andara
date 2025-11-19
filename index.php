<?php

$base_url = rtrim(dirname($_SERVER['SCRIPT_NAME']), '/') . '/';

// Obtenemos la ruta solicitada por el usuario
$request = $_SERVER['REQUEST_URI'];

// Limpiamos barras
$request = trim($request, '/');

// Quitamos parámetros tipo ?nombre=xxx&email=yyy
if (strpos($request, '?') !== false) {
    $request = strstr($request, '?', true);
}

// Incluimos variables de configuración
include 'includes/variables_configuracion.php';

switch ($request) {
    case 'contacto':
        include 'contacto.php';
        break;
    case 'quienes-somos':
        include 'quienes-somos.php';
        break;
    case 'productos':
        include 'productos.php';
        break;
    case 'precios':
        include 'precios.php';
        break;
    case 'porque-andara':
        include 'porque-andara.php';
        break;
    default:
        include 'home.php';
        break;
}