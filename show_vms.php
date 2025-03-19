<!DOCTYPE html>
<html lang="tr">

<head>
    <meta charset="UTF-8">
    <!-- Title: ESXi/Proxmox Virtual Machines List -->
    <!-- Başlık: ESXi/Proxmox Sanal Makineler Listesi -->
    <title>ESXi/Proxmox Sanal Makineler</title>
    <style>
        /* Main styles for the page */
        /* Sayfa için ana stiller */
        body {
            font-family: Arial, sans-serif;
            margin: 20px;
            background-color: #f5f5f5;
        }

        /* Header styles */
        /* Başlık stilleri */
        h1 {
            color: #333;
            text-align: center;
        }

        /* Table styles */
        /* Tablo stilleri */
        table {
            width: 100%;
            border-collapse: collapse;
            background-color: white;
            box-shadow: 0 1px 3px rgba(0, 0, 0, 0.2);
            margin-top: 20px;
        }

        /* Table cell styles */
        /* Tablo hücre stilleri */
        th,
        td {
            padding: 12px;
            text-align: left;
            border-bottom: 1px solid #ddd;
        }

        /* Table header styles */
        /* Tablo başlık stilleri */
        th {
            background-color: #4CAF50;
            color: white;
        }

        /* Alternating row colors */
        /* Alternatif satır renkleri */
        tr:nth-child(even) {
            background-color: #f2f2f2;
        }

        /* Row hover effect */
        /* Satır üzerine gelme efekti */
        tr:hover {
            background-color: #ddd;
        }

        /* Power state styles */
        /* Güç durumu stilleri */
        .power-on {
            color: green;
            font-weight: bold;
        }

        .power-off {
            color: red;
            font-weight: bold;
        }

        /* Last update text styles */
        /* Son güncelleme metni stilleri */
        .last-update {
            text-align: right;
            margin-top: 10px;
            color: #666;
        }
    </style>
</head>

<body>
    <h1>ESXi/Proxmox Sanal Makineler</h1>
    <?php
    // Get JSON data from POST request
    // POST isteğinden JSON verisini al
    $json_data = file_get_contents('php://input');
    $data = json_decode($json_data, true);

    if ($data && isset($data['virtual_machines'])) {
        // Create table structure
        // Tablo yapısını oluştur
        echo '<table>';
        echo '<tr>';
        echo '<th>ID</th>';
        echo '<th>İsim</th>';
        echo '<th>Durum</th>';
        echo '<th>IP Adresleri</th>';
        echo '<th>İşletim Sistemi</th>';
        echo '<th>CPU</th>';
        echo '<th>Bellek (GB)</th>';
        echo '<th>Disk (GB)</th>';
        echo '</tr>';

        // Loop through each VM and display its information
        // Her VM için bilgileri göster
        foreach ($data['virtual_machines'] as $vm) {
            echo '<tr>';
            echo '<td>' . htmlspecialchars($vm['id']) . '</td>';
            echo '<td>' . htmlspecialchars($vm['name']) . '</td>';
            echo '<td class="power-' . strtolower($vm['power_state']) . '">' . htmlspecialchars($vm['power_state']) . '</td>';
            echo '<td>' . htmlspecialchars($vm['ip_addresses'] ?: 'N/A') . '</td>';
            echo '<td>' . htmlspecialchars($vm['guest_os']) . '</td>';
            echo '<td>' . htmlspecialchars($vm['num_cpu']) . '</td>';
            echo '<td>' . htmlspecialchars($vm['memory_mb'] / 1024) . '</td>';
            echo '<td>' . htmlspecialchars($vm['total_disk_size_gb']) . '</td>';
            echo '</tr>';
        }
        echo '</table>';
    } else {
        // Display error message if no data received
        // Veri alınamazsa hata mesajı göster
        echo '<p>Veri alınamadı veya hatalı format!</p>';
    }
    ?>
    <!-- Display last update time -->
    <!-- Son güncelleme zamanını göster -->
    <div class="last-update">
        Son Güncelleme: <?php echo date('d.m.Y H:i:s'); ?>
    </div>
</body>

</html>