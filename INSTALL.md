# INSTALL

Guía de instalación de `cryptosith`.

---

## 📋 Índice

1. [Requisitos](#1-requisitos)
2. [Instalación automática](#2-instalación-automática-recomendada)
3. [Instalación manual](#3-instalación-manual)
4. [Instalación multi-distro](#4-instalación-multi-distro)
5. [Verificación](#5-verificación)
6. [Desinstalación](#6-desinstalación)
7. [Troubleshooting](#7-troubleshooting)

---

## 1. Requisitos

### Dependencias

| Comando | Paquete | Uso | Obligatorio |
|---------|---------|-----|-------------|
| `age` | `age` | Cifrado moderno | ✅ |
| `script` | `util-linux` | Pseudo-TTY para age | ✅ |
| `systemd-creds` | `systemd` | Sellado TPM | Solo modos TPM |
| `gpg` | `gnupg` | Retrocompatibilidad v4 | Solo v4 |
| `7z` | `p7zip` | Contenedor por defecto | Si no `--tar` |
| `tar` | `tar` | Contenedor alternativo | Si `--tar` |
| `sha256sum` | `coreutils` | Verificación | ✅ |

### Verificar dependencias

```bash
which age script gpg 7z tar sha256sum
```

**Esperado**:

```
/usr/bin/age
/usr/bin/script
/usr/bin/gpg
/usr/bin/7z
/usr/bin/tar
/usr/bin/sha256sum
```

---

## 2. Instalación automática (recomendada)

### Una línea

```bash
bash <(curl -sSL https://codeberg.org/novum-humberto/cryptosith/raw/branch/main/install.sh)
```

**Qué hace**:

1. Detecta la distribución.
2. Verifica/instala dependencias.
3. Copia `cryptosith` y `_cryptosith` a `~/.config/zsh/functions/`.
4. Copia `manual.txt` a `~/.config/cryptosith/`.
5. Verifica el `autoload` en el `.zshrc`.
6. Verifica el `compdef` en `31-compdefs.zsh`.
7. Muestra los siguientes pasos.

### Instalación desde repo clonado

```bash
git clone https://codeberg.org/novum-humberto/cryptosith.git
cd cryptosith
./install.sh
```

**Nota**: si prefieres no interactivo, añade `--unattended`:

```bash
./install.sh --unattended
```

---

## 3. Instalación manual

### Paso 1: Clonar

```bash
git clone https://codeberg.org/novum-humberto/cryptosith.git
cd cryptosith
```

### Paso 2: Copiar la función y el autocompletado

```bash
# Función principal
cp cryptosith ~/.config/zsh/functions/cryptosith
chmod +x ~/.config/zsh/functions/cryptosith

# Autocompletado
cp _cryptosith ~/.config/zsh/functions/_cryptosith
chmod +x ~/.config/zsh/functions/_cryptosith
```

### Paso 3: Copiar el manual

```bash
mkdir -p ~/.config/cryptosith
cp manual.txt ~/.config/cryptosith/manual.txt
```

### Paso 4: Añadir al autoload del `.zshrc`

```bash
nvim ~/.config/zsh/.zshrc
```

Buscar el bloque `autoload -Uz` y añadir `cryptosith _cryptosith` al final:

```zsh
autoload -Uz \
    mantenimiento cryptosith bc-calc zellij-layout \
    ufw-manager clamav-virus menu-principal search-aliases \
    HistAI HistAI_Preview _histai_preview nano-script \
    _cryptosith
```

**Nota**: si no tienes `zsh-config` instalado, tendrás que crear el bloque `autoload -Uz` desde cero. Como mínimo:

```zsh
autoload -Uz cryptosith _cryptosith
```

### Paso 5: Registrar el compdef

```bash
nvim ~/.config/zsh/conf.d/31-compdefs.zsh
```

Añadir:

```zsh
compdef _cryptosith cryptosith
```

**Nota**: si no existe el archivo, créalo. Y asegúrate de que el `.zshrc` carga `conf.d/*.zsh` antes que el `autoload`.

### Paso 6: Recargar y verificar

```bash
exec zsh

# Verificar
type cryptosith
# → cryptosith is a shell function from ...

cryp help
# → Muestra la ayuda corta

cryp man
# → Abre el manual
```

---

## 4. Instalación multi-distro

### Arch Linux / Omarchy

```bash
sudo pacman -S age util-linux systemd p7zip tar coreutils
```

### Debian / Ubuntu / Linux Mint / Pop!_OS

```bash
sudo apt update
sudo apt install age util-linux systemd p7zip-full tar coreutils
```

**Nota**: usar `p7zip-full` (no `p7zip`). El paquete `p7zip` a secas no incluye el binario `7z` completo.

### Fedora / RHEL / CentOS Stream / Rocky / AlmaLinux

```bash
sudo dnf install age util-linux systemd p7zip p7zip-plugins tar coreutils
```

**Nota**: requiere **2 paquetes** para 7z (`p7zip` + `p7zip-plugins`).

### openSUSE Leap / Tumbleweed

```bash
sudo zypper install age util-linux systemd p7zip tar coreutils
```

### Alpine Linux

```bash
sudo apk add age util-linux systemd p7zip tar coreutils
```

### Void Linux

```bash
sudo xbps-install -S age util-linux systemd p7zip tar coreutils
```

### Gentoo

```bash
sudo emerge --ask app-crypt/age sys-apps/util-linux sys-apps/systemd \
    app-arch/p7zip app-arch/tar sys-apps/coreutils
```

---

## 5. Verificación

### 5.1. Verificar que está instalado

```bash
type cryptosith
# → cryptosith is a shell function from /home/tuuser/.config/zsh/functions/cryptosith

which _cryptosith
# → /home/tuuser/.config/zsh/functions/_cryptosith

compdef -p _cryptosith
# → cryptosith
```

### 5.2. Verificar la ayuda

```bash
cryp help
# → Muestra la ayuda corta con los 5 modos

cryp man
# → Abre el manual completo en less (sal con q)
```

### 5.3. Verificar el autocompletado

```bash
cryp <TAB><TAB>
# → encrypt  decrypt  key  man  help

cryp encrypt -<TAB>
# → -d  -t  -T  -a  -k  -e  -r  -s  -v
```

### 5.4. Test de cifrado

```bash
cd /tmp
echo "test de cifrado" > t.txt

# Cifrar en modo TPM + passphrase (recomendado)
cryp encrypt t.txt -t
# Passphrase: prueba123

# Descifrar
mv t.txt t.orig
cryp decrypt t.txt.sith
# → Usa el TPM, sin passphrase

# Verificar
diff t.txt t.orig && echo "OK"
# → OK

# Limpieza
/bin/rm -f t.txt* t.orig
```

### 5.5. Test de todos los modos

```bash
cd /tmp

# Modo single
echo "single" > t1.txt
cryp encrypt t1.txt
mv t1.txt t1.orig
cryp decrypt t1.txt.sith
diff t1.txt t1.orig && echo "✓ single"

# Modo dual
echo "dual" > t2.txt
cryp encrypt t2.txt -d
# PassA: passA / PassB: passB
mv t2.txt t2.orig
cryp decrypt t2.txt.sith
# PassA / PassB
diff t2.txt t2.orig && echo "✓ dual"

# Modo tpm-only
echo "tpm-only" > t3.txt
cryp encrypt t3.txt -T
mv t3.txt t3.orig
cryp decrypt t3.txt.sith
diff t3.txt t3.orig && echo "✓ tpm-only"

# Limpieza
/bin/rm -f t*.txt* t*.orig
```

---

## 6. Desinstalación

### Paso 1: Eliminar archivos

```bash
# Función y autocompletado
command rm -f ~/.config/zsh/functions/cryptosith
command rm -f ~/.config/zsh/functions/_cryptosith

# Manual
command rm -rf ~/.config/cryptosith
```

### Paso 2: Editar `.zshrc` y `31-compdefs.zsh`

Eliminar las líneas correspondientes:

```zsh
# En ~/.config/zsh/.zshrc
# Quitar "cryptosith _cryptosith" del autoload

# En ~/.config/zsh/conf.d/31-compdefs.zsh
# Quitar "compdef _cryptosith cryptosith"
```

### Paso 3: Recargar

```bash
exec zsh
```

---

## 7. Troubleshooting

### `cryp: command not found`

**Causa**: no está en el `autoload -Uz` del `.zshrc`, o no está en `fpath`.

**Solución**:

```bash
# Verificar autoload
grep cryptosith ~/.config/zsh/.zshrc

# Verificar fpath
echo $fpath | tr ' ' '\n' | grep functions

# Verificar que el archivo existe
ls -la ~/.config/zsh/functions/cryptosith
```

Si falta el `autoload`, añadirlo. Si falta el archivo, reinstalar.

### `Passphrase incorrecta`

**Causa**: typo al introducir la passphrase.

**Solución**: verificar que la passphrase es exacta. Las passphrases **no tienen recuperación**. Si la perdiste, el archivo es irrecuperable.

### `Fallo al sellar al TPM`

**Causa**: TPM no disponible o `systemd-creds` no instalado.

**Solución**:

```bash
# Verificar TPM
ls /dev/tpmrm0
# Si no existe: habilitar en BIOS

# Verificar systemd-creds
which systemd-creds
```

### `age: error: -p/--passphrase can't be used with -d`

**Causa**: bug de versiones antiguas de `age`.

**Solución**: actualizar `age`:

```bash
sudo pacman -Syu age
```

### El archivo `.sith.meta` no se encuentra

**Causa**: el `.meta` debe estar **junto** al `.sith`.

**Solución**: verificar que ambos archivos están en la misma carpeta.

### Los emojis de la salida se ven como basura

**Causa**: locale no es UTF-8.

**Solución**:

```bash
locale
# LANG debe tener .UTF-8
```

Si no:

```bash
sudo nvim /etc/locale.conf
```

Contenido:

```
LANG=en_US.UTF-8
```

Y regenerar:

```bash
sudo locale-gen
```

### `key.tpm ausente, intentando fallback a passphrase...`

**No es un error**. Es información: el archivo `.sith.key.tpm` no se encuentra (probablemente estás en otro PC). `cryptosith` hará fallback a la passphrase.

**Solución**: introducir la passphrase cuando la pida.

### El TPM funciona pero pide la passphrase

**Causa**: el `.sith.key.tpm` fue eliminado o renombrado.

**Solución**: restaurar el `.sith.key.tpm` desde el backup. Si no lo tienes, tendrás que usar la passphrase (si hay `.key.enc`).

---

## 📌 Siguiente paso

Lee el [README.md](README.md) para ver los 5 modos y el [LESSONS.md](LESSONS.md) para las lecciones aprendidas.

---

## 🎓 Créditos

Proyecto personal. Sin ánimo de lucro. Sin garantías.


---

**Última actualización**: 2026-10-07.
