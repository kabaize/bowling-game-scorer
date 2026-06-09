# Build stage
FROM node:24-alpine AS build

WORKDIR /app

# Copy dependency files first for caching
COPY package.json package-lock.json ./

RUN npm install

# Copy app source and build
COPY . .
RUN npm run build


# Runtime stage
FROM nginx:alpine

# Remove default Nginx config
RUN rm /etc/nginx/conf.d/default.conf

# Copy built React files
COPY --from=build /app/dist /usr/share/nginx/html

# Copy custom Nginx config (we'll add this next)
COPY nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
