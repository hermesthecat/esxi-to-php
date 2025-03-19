#!/bin/bash
# Author: A. Kerem Gök
# Description: ESXi sunucusundaki tüm VM'leri JSON formatında listeler ve PHP script'e gönderir

# PHP script'in URL'si (bu adresi kendi ortamınıza göre değiştirin)
PHP_URL="http://localhost/show_vms.php"

# Geçici JSON dosyası oluştur
json_output=$(mktemp)

# JSON başlangıcı
echo "{" > "$json_output"
echo "  \"virtual_machines\": [" >> "$json_output"

# Tüm VM'leri al
vms=$(vim-cmd vmsvc/getallvms)

# İlk satırı atla (başlık satırı)
echo "$vms" | tail -n +2 | while read -r line
do
    # VM bilgilerini parse et
    vmid=$(echo "$line" | awk '{print $1}')
    name=$(echo "$line" | awk '{print $2}')
    file=$(echo "$line" | awk '{print $3}')
    guest_os=$(echo "$line" | awk '{print $4}')
    version=$(echo "$line" | awk '{print $5}')
    
    # VM'in güç durumunu al
    power_state=$(vim-cmd vmsvc/power.getstate "$vmid" | grep -i "Powered" | awk '{print $2}')
    
    # VM'in bellek ve CPU bilgilerini al
    config_info=$(vim-cmd vmsvc/get.config "$vmid")
    memory_mb=$(echo "$config_info" | grep "memoryMB" | awk '{print $3}' | tr -d '",')
    num_cpu=$(echo "$config_info" | grep "numCPUs" | awk '{print $3}' | tr -d '",')
    
    # Toplam disk boyutunu hesapla
    total_disk_size_gb=0
    while IFS= read -r disk_line; do
        if [[ $disk_line =~ "diskPath" ]]; then
            disk_path=$(echo "$disk_line" | sed 's/.*"\(.*\)".*/\1/')
            disk_size=$(echo "$config_info" | grep -A 2 "$disk_path" | grep "capacityInKB" | awk '{print $3}' | tr -d '",')
            disk_size_gb=$((disk_size / 1024 / 1024))
            total_disk_size_gb=$((total_disk_size_gb + disk_size_gb))
        fi
    done <<< "$config_info"
    
    # IP adreslerini al
    guest_info=$(vim-cmd vmsvc/get.guest "$vmid")
    ip_addresses=$(echo "$guest_info" | grep "ipAddress" | awk -F'"' '{print $2}' | sort -u | tr '\n' ',' | sed 's/,$//')
    
    # JSON formatında çıktı ver
    echo "    {" >> "$json_output"
    echo "      \"id\": \"$vmid\"," >> "$json_output"
    echo "      \"name\": \"$name\"," >> "$json_output"
    echo "      \"datastore_path\": \"$file\"," >> "$json_output"
    echo "      \"guest_os\": \"$guest_os\"," >> "$json_output"
    echo "      \"version\": \"$version\"," >> "$json_output"
    echo "      \"power_state\": \"$power_state\"," >> "$json_output"
    echo "      \"memory_mb\": $memory_mb," >> "$json_output"
    echo "      \"num_cpu\": $num_cpu," >> "$json_output"
    echo "      \"total_disk_size_gb\": $total_disk_size_gb," >> "$json_output"
    echo "      \"ip_addresses\": \"$ip_addresses\"" >> "$json_output"
    
    # Son VM değilse virgül ekle
    if [ "$(echo "$vms" | tail -n +2 | tail -n1)" != "$line" ]; then
        echo "    }," >> "$json_output"
    else
        echo "    }" >> "$json_output"
    fi
done

# JSON sonlandırma
echo "  ]" >> "$json_output"
echo "}" >> "$json_output"

# JSON verisini PHP script'e gönder
curl -X POST -H "Content-Type: application/json" --data-binary "@$json_output" "$PHP_URL"

# Geçici dosyayı sil
rm "$json_output" 