#!/bin/bash

echo "${INFO} Checking if /mnt is a separate mounted device..." | tee -a "$LOG_FILE"

# Verificar si /mnt es una unidad montada y no solo una carpeta
if ! findmnt -n /mnt > /dev/null; then
    echo "${ERROR} /mnt is not a mounted filesystem. Aborting..." | tee -a "$LOG_FILE"
    return 1
fi

# Verificar si /mnt está en un dispositivo distinto del disco raíz
mnt_device=$(findmnt -n -o SOURCE /mnt)
root_device=$(findmnt -n -o SOURCE /)

if [ "$mnt_device" = "$root_device" ]; then
    echo "${ERROR} /mnt is on the same device as root. Aborting..." | tee -a "$LOG_FILE"
    return 1
fi

# Verificar si la unidad montada en /mnt tiene más de 10GB de espacio total
mnt_size=$(df -BG --output=size /mnt | tail -n1 | tr -dc '0-9')

if [ "$mnt_size" -lt 10 ]; then
    echo "${ERROR} /mnt is mounted but has less than 10GB. Aborting..." | tee -a "$LOG_FILE"
    return 1
fi

echo "${OK} /mnt is a separate mounted device with more than 10GB." | tee -a "$LOG_FILE"
