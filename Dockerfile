FROM nginx:alpine

# Put our files in the webroot
WORKDIR /usr/share/nginx/html

# Remove default static content
RUN rm -rf /usr/share/nginx/html/*

# Copy site files
COPY . /usr/share/nginx/html

# Copy custom nginx config to enable SPA fallback for Docsify
COPY nginx.conf /etc/nginx/nginx.conf

EXPOSE 80

# Run nginx in foreground
CMD ["nginx", "-g", "daemon off;"]
