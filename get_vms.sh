#!/bin/bash
# Author: A. Kerem Gök
# Description: ESXi sunucusundaki tüm VM'leri JSON formatında listeler

# JSON başlangıcı
echo "{"
echo "  \"virtual_machines\": ["

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
    
    # JSON formatında çıktı ver
    echo "    {"
    echo "      \"id\": \"$vmid\","
    echo "      \"name\": \"$name\","
    echo "      \"datastore_path\": \"$file\","
    echo "      \"guest_os\": \"$guest_os\","
    echo "      \"version\": \"$version\","
    echo "      \"power_state\": \"$power_state\","
    echo "      \"memory_mb\": $memory_mb,"
    echo "      \"num_cpu\": $num_cpu"
    echo -n "    }"
    
    # Son VM değilse virgül ekle
    if [ "$(echo "$vms" | tail -n +2 | tail -n1)" != "$line" ]; then
        echo ","
    else
        echo ""
    fi
done

# JSON sonlandırma
echo "  ]"
echo "}" 