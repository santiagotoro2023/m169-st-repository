FROM nginx:alpine

# Copy our custom HTML file into the nginx web directory without deleting other files
COPY index.html /usr/share/nginx/html/

# Expose port 80
EXPOSE 80

# Start nginx
CMD ["nginx", "-g", "daemon off;"]
