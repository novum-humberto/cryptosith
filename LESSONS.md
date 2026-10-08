# LESSONS

Lecciones aprendidas durante el desarrollo de `cryptosith`.

---

## 🎯 Filosofía del proyecto

### 1. La seguridad está en la clave, no en las capas

**Error inicial**: pensar que 4 capas de cifrado = 4x seguridad.

**Realidad**: aplicar el mismo tipo de cifrado N veces **no multiplica la seguridad**. Es como poner 4 cerraduras en la misma puerta con la misma llave.

**Conclusión**: la seguridad está en la calidad de la clave, no en la cantidad de capas.

### 2. Clave aleatoria > passphrase humana

| Tipo | Entropía | Tiempo de crack (GPU 2024) |
|------|----------|----------------------------|
| Passphrase humana (`MiClave2024!`) | ~50 bits | Horas |
| Clave aleatoria 128 chars | ~846 bits | > edad del universo |

**Aplicación**: `key1` siempre aleatoria de 128 caracteres.

### 3. Separar secretos en canales distintos

**Defensa en profundidad real**: cada factor en un sitio distinto.

- PassA → cabeza + gestor de contraseñas.
- PassB → papel en caja fuerte.
- key1 → cifrada en `.meta` o sellada al TPM.

### 4. Diseño ortogonal vs modos cerrados

**Error intermedio**: 4 modos cerrados. Añadir un eje nuevo requeriría reescribir.

**Solución**: 2 ejes independientes (passphrases × TPM). 5 combinaciones.

**Ventaja**: escalable. Añadir un eje nuevo (YubiKey) sería trivial.

### 5. Criptografía moderna (age, no GPG)

| Aspecto | GPG | age |
|---------|-----|-----|
| Cifrado | AES256 | ChaCha20-Poly1305 |
| AEAD | Parcial | Siempre |
| KDF | String-to-key | scrypt |
| Código | 500K líneas | 15K líneas |

---

## 🔧 Lecciones técnicas

### 1. `age --passphrase` exige TTY

`age` no acepta passphrase por stdin. Es una decisión de diseño.

**Solución**: crear un pseudo-TTY con `script`.

```bash
printf 'pass\npass\n' | script -qec "age --passphrase -o out in" /dev/null
```

### 2. `systemd-creds` sella al TPM

Simple y funcional:

```bash
systemd-creds encrypt --with-key=tpm2 input output
systemd-creds decrypt --with-key=tpm2 input output
```

### 3. `--passphrase-fd 3` para GPG

Para GPG (retrocompatibilidad v4), usar `--passphrase-fd 3` con here-string. La passphrase nunca aparece en `ps aux`.

```bash
gpg --batch --passphrase-fd 3 --cipher-algo AES256 -c -o out in 3<<<"$key"
```

### 4. Checksum del comprimido, no del original

Si aplicas exclusiones (`--exclude node_modules`), el original tiene más archivos que el comprimido.

**Regla**: calcular SHA-256 del **comprimido**. Refleja lo que realmente se cifró.

### 5. `7z` necesita `cd` al padre

Para que las exclusiones funcionen:

```bash
(
    cd "$parent_dir" || exit 1
    7z a -mx=9 -xr!node_modules "$archive" "$file_name"
)
```

Sin el `cd`, 7z guarda rutas absolutas y las exclusiones no funcionan.

### 6. `-xr!` en 7z (recursivo)

| Flag | Comportamiento |
|------|----------------|
| `-x!patrón` | Solo en nivel superior |
| `-xr!patrón` | En cualquier nivel ✅ |

### 7. El parser del `.meta` debe ser robusto

Si `key1` contiene `=`, el parser clásico (`IFS='='`) se rompe.

**Solución**:

```bash
k="${line%%=*}"    # Todo antes del primer =
v="${line#*=}"     # Todo después del primer =
```

---

## 🎨 Lecciones de diseño

### 1. Subcomandos > menú interactivo

`cryp encrypt x` es scriptable, tab-completable, más rápido que un menú interactivo.

**Excepción**: `ufw-manager` (herramienta puntual) usa menú.

### 2. Manual separado del código

`cryp man` lee de `~/.config/cryptosith/manual.txt`. Editable sin tocar código.

### 3. Autocompletado mejora la usabilidad enormemente

Con `cryp <TAB>` el usuario descubre las opciones sin mirar el manual.

### 4. Documentar honestamente

**Mal**: "sistema de cifrado de nivel militar".
**Bien**: "8/10 de seguridad real. No protege contra X, Y, Z."

### 5. Sin excepciones en el código

`menu-principal` de `zsh-config` llama a `cryptosith`. Si no está instalado, **fallback elegante**: muestra un aviso.

### 6. Retrocompatibilidad

Cada versión nueva **sigue descifrando** los `.sith` de versiones anteriores. El descifrador detecta la `version=` del `.meta`.

---

## 🔐 Lecciones de seguridad

### 1. Los gestores de contraseñas han fallado

- **LastPass 2022**: filtración masiva de vaults.
- **Bitwarden 2022**: bug en el generador de contraseñas.

**Conclusión**: no confiar **ciegamente** en un gestor. Tener siempre un backup **físico** (papel en caja fuerte).

### 2. Canales separados son la defensa real

Modo dual: 2 passphrases en 2 sitios distintos. Para descifrar, **A Y B**.

### 3. 9.5/10 es el máximo real sin hardware criptográfico

Con `age` + `systemd-creds` + TPM, llegas a 9.5/10.

Para **10/10** necesitas:

- YubiKey (~50€).
- TPM sellado a PCRs específicos.
- Air-gap, Tails OS.
- Auditoría externa.

**Son procedimientos**, no código.

### 4. La comodidad importa

> "Si no lo usas, no protege."

Un sistema seguro pero incómodo no se usa. Un sistema cómodo pero mediocre se usa todos los días.

### 5. La clave privada en disco es punto de fallo

Si cifras con `age` usando clave pública/privada, la clave privada vive en disco.

**Alternativa**: `age --passphrase` (passphrase derivada con scrypt). No hay clave privada en disco.

---

## 📚 Lecciones meta

### 1. Documentar como si fuera para un desconocido

Tu yo del futuro es un desconocido. No recordará por qué tomaste cada decisión.

### 2. Cada decisión debe tener un por qué escrito

Un comentario de 3 líneas puede ahorrarte una hora dentro de 6 meses.

### 3. Aprender haciendo > leer tutoriales

En 2 días de desarrollo aprendiste más sobre criptografía que en 6 meses de tutoriales.

### 4. Menos es más

Pasamos de 4 capas a 2. De 4 modos cerrados a 5 ortogonales. **Menos código, más funcionalidad**.

### 5. La estructura es más importante que el contenido

Un proyecto bien organizado se mantiene. Uno desordenado se abandona.

---

## 🎯 Frase final

> **La seguridad no está en la cantidad de capas, sino en la calidad de la clave. Y la clave debe estar en un canal separado del archivo cifrado.**

---

**Fin de LESSONS.md.**
