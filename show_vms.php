<!DOCTYPE html>
<html lang="tr">
<head>
    <meta charset="UTF-8">
    <title>ESXi Sanal Makineler</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            margin: 20px;
            background-color: #f5f5f5;
        }
        h1 {
            color: #333;
            text-align: center;
        }
        table {
            width: 100%;
            border-collapse: collapse;
            background-color: white;
            box-shadow: 0 1px 3px rgba(0,0,0,0.2);
            margin-top: 20px;
        }
        th, td {
            padding: 12px;
            text-align: left;
            border-bottom: 1px solid #ddd;
        }
        th {
            background-color: #4CAF50;
            color: white;
        }
        tr:nth-child(even) {
            background-color: #f2f2f2;
        }
        tr:hover {
            background-color: #ddd;
        }
        .power-on {
            color: green;
            font-weight: bold;
        }
        .power-off {
            color: red;
            font-weight: bold;
        }
        .last-update {
            text-align: right;
            margin-top: 10px;
            color: #666;
        }
    </style>
</head>
<body>
    <h1>ESXi Sanal Makineler</h1>
    <?php
    // JSON verisini al
    $json_data = file_get_contents('php://input');
    $data = json_decode($json_data, true);

    if ($data && isset($data['virtual_machines'])) {
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
        echo '<p>Veri alınamadı veya hatalı format!</p>';
    }
    ?>
    <div class="last-update">
        Son Güncelleme: <?php echo date('d.m.Y H:i:s'); ?>
    </div>
</body>
</html> 