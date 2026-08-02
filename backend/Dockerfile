# Imagen oficial de Node.js LTS
FROM node:22-alpine

# Directorio de trabajo
WORKDIR /app

# Copiar archivos de dependencias
COPY package*.json ./

# Instalar dependencias
RUN npm install --omit=dev

# Copiar el resto del proyecto
COPY . .

# Puerto que utilizará la aplicación
EXPOSE 3000

# Iniciar la aplicación
CMD ["npm", "start"]