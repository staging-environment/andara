<?php
use PHPMailer\PHPMailer\PHPMailer;
use PHPMailer\PHPMailer\Exception;

require 'vendor/autoload.php';
require 'includes/variables_configuracion.php';

if ($_SERVER["REQUEST_METHOD"] == "POST") {
    $nombre = $_POST['nombre'];
    $email = $_POST['email'];
    $ciudad = $_POST['ciudad'];
    $telefono = $_POST['telefono'];
    $comentario = $_POST['comentario'];

    $mail = new PHPMailer(true);

    try {
        // Configuración del servidor
        $mail->isSMTP();
        $mail->Host = $smtp_host;
        $mail->SMTPAuth = true;
        $mail->Username = $smtp_username;
        $mail->Password = $smtp_password;
        $mail->SMTPSecure = PHPMailer::ENCRYPTION_STARTTLS;
        $mail->Port = $smtp_port;

        // Remitente y destinatario
        $mail->setFrom($smtp_from_email, $smtp_from_name);
        $mail->addAddress($smtp_to_email);

        // Contenido
        $mail->isHTML(true);
        $mail->Subject = 'Nuevo mensaje de contacto - Andara';
        $mail->Body = "
            <h2>Nuevo mensaje de contacto</h2>
            <p><strong>Nombre:</strong> {$nombre}</p>
            <p><strong>Email:</strong> {$email}</p>
            <p><strong>Ciudad:</strong> {$ciudad}</p>
            <p><strong>Teléfono:</strong> {$telefono}</p>
            <p><strong>Comentario:</strong> {$comentario}</p>
        ";

        $mail->send();
        echo json_encode(['success' => true]);
    } catch (Exception $e) {
        echo json_encode(['success' => false, 'message' => $mail->ErrorInfo]);
    }
}