# Imagen oficial Node.js LTS sobre Alpine
FROM node:22-alpine

# Directorio de trabajo
WORKDIR /app

# Copiar archivos de dependencias
COPY package*.json ./

# Instalar solamente dependencias de producción
RUN npm ci --omit=dev

# Copiar código de la aplicación
COPY . .

# Ejecutar como usuario no privilegiado
USER node

# Puerto de la aplicación
EXPOSE 3000

# Iniciar aplicación
CMD ["npm", "start"]