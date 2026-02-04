# Subir Cali App a GitHub

## 1. Crear el repositorio en GitHub

1. Entrá a [github.com/new](https://github.com/new)
2. **Repository name:** `cali_app` (o el nombre que quieras)
3. Elegí **Public** o **Private**
4. **No** marques "Add a README" (el repo debe empezar vacío)
5. Clic en **Create repository**

## 2. En la terminal, desde la carpeta del proyecto

```bash
# Ir a la carpeta del proyecto
cd "/Users/lucas/Desktop/App Cali/cali_app"

# Inicializar Git (si todavía no está inicializado)
git init

# Agregar todos los archivos
git add .

# Primer commit
git commit -m "Initial commit: Cali App - app de gimnasio"

# Conectar con tu repositorio de GitHub (reemplazá TU_USUARIO por tu usuario de GitHub)
git remote add origin https://github.com/TU_USUARIO/cali_app.git

# Subir la rama main
git branch -M main
git push -u origin main
```

## 3. Si ya tenés Git inicializado

Si el proyecto ya tiene `git init` y solo querés agregar el remoto de GitHub:

```bash
cd "/Users/lucas/Desktop/App Cali/cali_app"
git remote add origin https://github.com/TU_USUARIO/cali_app.git
git branch -M main
git add .
git commit -m "Initial commit: Cali App"   # solo si hay cambios sin commitear
git push -u origin main
```

## Notas

- **TU_USUARIO**: reemplazá por tu usuario de GitHub (ej. `lucasgym`).
- Si GitHub te pide **autenticación**, podés usar:
  - **Token personal:** GitHub → Settings → Developer settings → Personal access tokens.
  - O **GitHub CLI:** `brew install gh` y luego `gh auth login`.
- El `.gitignore` del proyecto ya excluye `build/`, `.dart_tool/`, etc., así que no se suben archivos generados.
