<?php

// Obtenemos la ruta solicitada por el usuario
$request = $_SERVER['REQUEST_URI'];

// Limpiamos la ruta de posibles parámetros
$request = trim($request, '/');

// En función de la ruta, decidimos qué contenido cargar
switch ($request) {
    case 'home':
        echo "Estás en la página de inicio.";
        break;
    case 'contacto':
        echo "Esta es la página de contacto.";
        break;
    default:
        echo "Página no encontrada.";
        break;
}

// Puedes hacer un pequeño router aquí
echo "Has accedido a: " . htmlspecialchars($request);

// Aquí podrías incluir lógica de enrutamiento, carga de controladores, etc.
