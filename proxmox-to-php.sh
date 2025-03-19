#!/bin/bash
# Author: A. Kerem Gök
# Description: Proxmox sunucusundaki tüm VM'leri JSON formatında listeler ve PHP script'e gönderir

# PHP script'in URL'si (bu adresi kendi ortamınıza göre değiştirin)
PHP_URL="http://localhost/show_vms.php"

# Geçici JSON dosyası oluştur
json_output=$(mktemp)

# JSON başlangıcı
echo "{" > "$json_output"
echo "  \"virtual_machines\": [" >> "$json_output"

# Tüm VM'leri al (sadece QEMU/KVM makineleri)
vms=$(pvesh get /cluster/resources --type vm)

# VM listesini işle
first=true
echo "$vms" | jq -c '.[]' | while read -r vm; do
    vmid=$(echo "$vm" | jq -r '.vmid')
    name=$(echo "$vm" | jq -r '.name')
    status=$(echo "$vm" | jq -r '.status')
    maxmem=$(echo "$vm" | jq -r '.maxmem')
    maxcpu=$(echo "$vm" | jq -r '.maxcpu')
    
    # VM'in detaylı bilgilerini al
    config=$(qm config "$vmid")
    
    # İşletim sistemi tipini al
    guest_os=$(echo "$config" | grep "^ostype:" | cut -d' ' -f2)
    
    # Toplam disk boyutunu hesapla
    total_disk_size_gb=0
    while read -r disk; do
        if [[ $disk =~ ^(virtio|scsi|ide|sata)[0-9]+:.*size=([0-9]+[GMT]).*$ ]]; then
            size=${BASH_REMATCH[2]}
            # Boyutu GB'a çevir
            if [[ $size =~ ([0-9]+)T$ ]]; then
                size_gb=$((${BASH_REMATCH[1]} * 1024))
            elif [[ $size =~ ([0-9]+)G$ ]]; then
                size_gb=${BASH_REMATCH[1]}
            elif [[ $size =~ ([0-9]+)M$ ]]; then
                size_gb=$((${BASH_REMATCH[1]} / 1024))
            fi
            total_disk_size_gb=$((total_disk_size_gb + size_gb))
        fi
    done <<< "$(echo "$config" | grep -E '^(virtio|scsi|ide|sata)[0-9]+:')"
    
    # IP adreslerini al (eğer makine çalışıyorsa)
    ip_addresses=""
    if [ "$status" = "running" ]; then
        # QEMU agent üzerinden IP bilgilerini al
        agent_info=$(qm agent "$vmid" network-get-interfaces 2>/dev/null)
        if [ $? -eq 0 ]; then
            ip_addresses=$(echo "$agent_info" | jq -r '.[] | select(.["ip-addresses"]) | .["ip-addresses"][].ip-address' | grep -v '^fe80::' | grep -v '^127\.' | tr '\n' ',' | sed 's/,$//')
        fi
    fi
    
    # Belleği GB'a çevir
    memory_gb=$(echo "scale=2; $maxmem / 1024 / 1024 / 1024" | bc)
    
    # JSON formatında çıktı ver
    if [ "$first" = true ]; then
        first=false
    else
        echo "    ," >> "$json_output"
    fi
    
    echo "    {" >> "$json_output"
    echo "      \"id\": \"$vmid\"," >> "$json_output"
    echo "      \"name\": \"$name\"," >> "$json_output"
    echo "      \"guest_os\": \"$guest_os\"," >> "$json_output"
    echo "      \"power_state\": \"$status\"," >> "$json_output"
    echo "      \"memory_mb\": $(printf "%.0f" "$(echo "$memory_gb * 1024" | bc)")," >> "$json_output"
    echo "      \"num_cpu\": $maxcpu," >> "$json_output"
    echo "      \"total_disk_size_gb\": $total_disk_size_gb," >> "$json_output"
    echo "      \"ip_addresses\": \"$ip_addresses\"" >> "$json_output"
    echo -n "    }" >> "$json_output"
done

# JSON sonlandırma
echo "" >> "$json_output"
echo "  ]" >> "$json_output"
echo "}" >> "$json_output"

# JSON verisini PHP script'e gönder
curl -X POST -H "Content-Type: application/json" --data-binary "@$json_output" "$PHP_URL"

# Geçici dosyayı sil
rm "$json_output" 