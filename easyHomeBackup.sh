#!/bin/bash
# Verificar si el script se está ejecutando con privilegios de root.
if [ "$EUID" -ne 0 ]; then
  echo -e "\e[1;33mEste script debe ejecutarse con sudo.\e[0m"
  exit 1
fi

# Obtener el usuario.
if [ -n "$SUDO_USER" ]; then
    REAL_USER="$SUDO_USER"
else
    REAL_USER="$(whoami)"
fi
HOME_DIR=$(eval echo "~$REAL_USER")

# Nombre del fichero con fecha y hora.
TIMESTAMP=$(date +%Y%m%d-%H%M%S)
ZIP_NAME="${REAL_USER}Backup-${TIMESTAMP}.zip"

clear
echo -e "\e[1mSeleccione la ubicación de destino para el backup:\e[0m"
echo "1. En el directorio /backups del disco duro local"
echo "2. En otro disco duro"
read -p "Seleccione una opción (1/2): " opcion

if [ "$opcion" -eq 1 ]; then
    DESTINO="/backups"
    # Crea el directorio si no existe.
    if [ ! -d "$DESTINO" ]; then
        echo -e "\e[1;32mCreando directorio $DESTINO...\e[0m"
        mkdir -p "$DESTINO"
    fi

elif [ "$opcion" -eq 2 ]; then
    clear
    echo -e "\e[1mListando dispositivos montados:\e[0m"
    declare -A listado
    i=1

    # Usamos lsblk para listar los discos duros:
    # - NAME, SIZE, MOUNTPOINT, LABEL, MODEL, TYPE
    # - Excluimos los de tipo loop con grep -v 'TYPE="loop"'
    # - Nos interesan solo aquellos discos duros que tengan un MOUNTPOINT que no sea vacío.
    while read -r line; do
        eval "$line"  # Crea variables: $NAME, $SIZE, $MOUNTPOINT, $LABEL, $MODEL, $TYPE
        # Nos aseguramos de que exista MOUNTPOINT y que no sea vacío.
        if [ -n "$MOUNTPOINT" ]; then
            echo "$i. $NAME - Montado en: $MOUNTPOINT - Tamaño: $SIZE - Label: ${LABEL:-Sin etiqueta} - Modelo: ${MODEL:-Sin modelo}"
            listado[$i]="$MOUNTPOINT"
            i=$((i+1))
        fi
    done < <(lsblk -p -o NAME,SIZE,MOUNTPOINT,LABEL,MODEL,TYPE -P | grep -v 'TYPE="loop"')

    if [ ${#listado[@]} -eq 0 ]; then
	echo -e "\e[1;33mNo se encontraron dispositivos montados (o todos son loop).\e[0m"
        exit 1
    fi

    read -p "Seleccione el número del dispositivo que desea usar: " devnum
    DESTINO="${listado[$devnum]}"

    if [ -z "$DESTINO" ]; then
        echo -e "\e[1;31mOpción inválida.\e[0m"
        exit 1
    fi

    # Crear la carpeta 'backup' en el punto de montaje seleccionado.
    DESTINO="${DESTINO}/backup"
    mkdir -p "$DESTINO"

else
    echo "Opción inválida."
    exit 1
fi

# Ruta completa del archivo zip del backup.
ZIP_PATH="${DESTINO}/${ZIP_NAME}"
clear
echo -e "\e[1;32mCreando backup en $ZIP_PATH ...\e[0m"
sleep 3

# Cambiar al directorio home del usuario real.
cd "$HOME_DIR" || { echo -e "\e[1;31mNo se pudo acceder a $HOME_DIR\e[0m"; exit 1; }

# Seleccionar solo los directorios visibles (excluyendo los que comienzan con ".")
visible_dirs=$(find . -maxdepth 1 -mindepth 1 -type d -not -name ".*")
if [ -z "$visible_dirs" ]; then
    echo -e "\e[1;33mNo se encontraron directorios visibles en $HOME_DIR.\e[0m"
    exit 1
fi

# Crear el backup en formato .zip
zip -r "$ZIP_PATH" $visible_dirs
zip_status=$?

# Verificar que el archivo de backup se haya creado y tenga contenido.
if [ -f "$ZIP_PATH" ] && [ -s "$ZIP_PATH" ]; then
    if [ $zip_status -eq 0 ]; then
        echo -e "\e[1;32mBackup completado exitosamente.\e[0m"
	sleep 1
    else
        echo -e "\e[1;33mBackup completado con algunas advertencias. Verifique el contenido del archivo.\e[0m"
	sleep 1
    fi
else
    echo -e "\e[1;31mOcurrió un error durante el backup.\e[0m"
    exit 1
fi