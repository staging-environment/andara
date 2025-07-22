<?php

$base_url = rtrim(dirname($_SERVER['SCRIPT_NAME']), '/') . '/';

// Obtenemos la ruta solicitada por el usuario
$request = $_SERVER['REQUEST_URI'];

// Limpiamos la ruta de posibles parámetros
$request = trim($request, '/');

// En función de la ruta, decidimos qué contenido cargar

switch ($request) {
    case 'contacto':
        include 'contacto.html';
        break;
    case 'quienes-somos':
        include 'quienes-somos.html';
        break;
    case 'productos':
        include 'productos.html';
        break;
    case 'precios':
        include 'precios.html';
        break;
    case 'porque-andara':
        include 'porque-andara.html';
        break;
    default:
        include 'index.html';
        break;
}

// Puedes hacer un pequeño router aquí
echo "Has accedido a: " . htmlspecialchars($request);

// Aquí podrías incluir lógica de enrutamiento, carga de controladores, etc.
