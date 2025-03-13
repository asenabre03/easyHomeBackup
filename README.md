# 🔒 ¡El Script más sencillo de Backup para copiar tus Datos!

¿Te da pereza hacer copias y estás harto de perder información importante? Este script Bash es la solución ideal para ti. Con un funcionamiento simple, automatiza la creación de backups de tus directorios de usuario.

---

## ✨ Características Destacadas

- **Ejecución Segura:**  
  Comprueba si se ejecuta con privilegios de root (usando `sudo`), lo que garantiza que el script tenga los permisos necesarios para operar sin inconvenientes.

- **Detección Inteligente del Usuario:**  
  Identifica al usuario real (ya sea mediante `SUDO_USER` o `whoami`) y opera directamente en su directorio **home**, asegurando que respalde los datos de forma correcta.

- **Backups Organizados y Cronológicos:**  
  Genera un nombre único para cada backup utilizando un timestamp (formato `YYYYMMDD-HHMMSS`), lo que facilita el seguimiento y la restauración manual en el futuro.

- **Opciones de Destino Flexibles:**  
  Permite elegir entre guardar el backup en:
  - Un directorio local predefinido (`/backups`), o
  - Un dispositivo de almacenamiento externo, el Script te indicará los discos duros montados en tu sistema para ayudarte a elegir en cuál quieres hacer la copia.

- **Proceso Interactivo y Claro:**  
  Presenta mensajes y opciones en pantalla para guiarte paso a paso, lo que hace que el proceso sea intuitivo incluso para usuarios con poca experiencia en la terminal.

---

## 🚀 **Cómo ejecutar el Script**
1. Clona el repositorio con `git clone` o descárgalo a través de `wget`.
    ```sh
    git clone https://github.com/asenabre03/easyHomeBackup.git
    wget https://github.com/asenabre03/easyHomeBackup/archive/refs/heads/main.zip
    ```
2. Tendrás que tener **privilegios de superusuario** para poder ejecutar el script.
3. Utiliza los siguientes comandos para ejecutar el script:
    ```sh
    sudo chmod +x setup.sh
    sudo ./setup.sh
    ```
