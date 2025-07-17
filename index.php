<?php

// Muestra la URL solicitada
$request = $_SERVER['REQUEST_URI'];

// Puedes hacer un pequeño router aquí
echo "Has accedido a: " . htmlspecialchars($request);

// Aquí podrías incluir lógica de enrutamiento, carga de controladores, etc.
