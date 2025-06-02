FROM nginx:alpine
COPY . /usr/share/nginx/html/  
COPY . /var/www/html/
EXPOSE 80                          
ENTRYPOINT ["nginx", "-g", "daemon off;"] 
