# cryptosith

Sistema de **cifrado por capas** para archivos y directorios, escrito en Zsh.

> **La seguridad está en la calidad de la clave, no en la cantidad de capas.**

---

## 📖 ¿Qué es esto?

`cryptosith` (alias `cryp`) cifra archivos o directorios completos aplicando:

1. **Compresión** (7z o tar.gz) con exclusiones opcionales.
2. **Cifrado** con `age` (ChaCha20-Poly1305) usando clave aleatoria.

La clave interna (`key1`) se protege de **5 formas posibles**, combinando passphrases y/o TPM.

**Contexto de uso**: realizar backups cifrados de archivos sensibles para subirlos a servicios no confiables (Google Drive, etc.).

---

## 🎯 Los 5 modos ortogonales

Diseño de **2 ejes independientes**:

- **Eje X**: nº de passphrases (0, 1, 2).
- **Eje Y**: TPM (sí / no).

| Modo | Flags | Seguridad | Portable | Uso típico |
|------|-------|-----------|----------|------------|
| **single** | (ninguno) | 8/10 | ✅ | Uso general |
| **dual** | `-d` | 9/10 | ✅ | Archivos importantes |
| **tpm-only** | `-T` | 9/10 | ❌ | Solo en este PC |
| **tpm** | `-t` | 9.5/10 | ✅ | Rápido + portable |
| **dual+tpm** | `-d -t` | 9.5/10 | ✅ | Máxima seguridad |

---

## 🚀 Instalación rápida

### Opción A: Instalador automático (recomendado)

```bash
bash <(curl -sSL https://codeberg.org/novum-humberto/cryptosith/raw/branch/main/install.sh)
```

### Opción B: Clonar e instalar manualmente

```bash
git clone https://codeberg.org/novum-humberto/cryptosith.git
cd cryptosith
./install.sh
```

### Opción C: Instalación manual paso a paso

Ver [`INSTALL.md`](INSTALL.md).

---

## 🎬 Ejemplos

```bash
# Modo simple (1 passphrase)
cryp encrypt documento.pdf

# Doble secreto (2 passphrases en canales separados)
cryp encrypt claves-ssh -d

# Solo TPM (rápido, no portable)
cryp encrypt proyecto-local -T

# TPM + passphrase (recomendado)
cryp encrypt backup.tar -t

# Máxima seguridad
cryp encrypt legado.tar -d -t

# Directorio con exclusiones
cryp encrypt ~/proyecto -t -e node_modules -e .git

# Descifrar
cryp decrypt documento.pdf.sith

# Generar passphrase
cryp key 128

# Manual completo
cryp man
```

---

## 📋 Requisitos

- **Sistema**: Linux (probado en Arch/Omarchy).
- **Shell**: Zsh.
- **Paquetes**:
  - `age`, `util-linux` (obligatorios).
  - `systemd` (solo modos TPM).
  - `gnupg` (retrocompatibilidad v4).
  - `p7zip`, `tar`, `coreutils`.

Ver [`INSTALL.md`](INSTALL.md) para instalación multi-distro.

---

## 🔐 Nivel de seguridad real

| Modo | Seguridad |
|------|-----------|
| single | 8/10 |
| dual | 9/10 |
| tpm-only | 9/10 |
| tpm | 9.5/10 |
| dual+tpm | 9.5/10 |

**Lo que NO protege** (en ningún modo):

- Keyloggers activos durante cifrado/descifrado.
- Coacción para dar TODAS las passphrases + acceso al TPM.
- Acceso físico a la máquina desbloqueada mientras descifras.

**Para subir de 9.5/10**: YubiKey, air-gap, Tails OS. Son **procedimientos**, no código.

---

## 🎓 Documentación

- **[INSTALL.md](INSTALL.md)** — guía de instalación detallada multi-distro.
- **[LESSONS.md](LESSONS.md)** — lecciones aprendidas.
- **Manual interno**: `cryp man` (una vez instalado).

---

## ⚖️ Licencia

MIT. Ver [LICENSE](LICENSE).

---

## 🙏 Relacionado

- **[zsh-config](https://codeberg.org/novum-humberto/zsh-config)** — mi configuración modular de Zsh.

---

**Estado**: funcional, documentado, en uso diario.
