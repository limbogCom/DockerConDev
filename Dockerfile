FROM php:7.4-apache

# Install OpenSSL
RUN apt-get update && apt-get upgrade -y && apt-get install -y \
    nano \
    openssl

# Install mysqli extension
RUN docker-php-ext-install mysqli && docker-php-ext-enable mysqli

# Install other required packages
RUN apt-get update && apt-get upgrade -y && \
    apt-get install -y libzip-dev zip unzip && \
    docker-php-ext-install zip && \
    docker-php-ext-install pdo pdo_mysql && \
    a2enmod rewrite ssl

# Create directory for SSL certificates
RUN mkdir -p /etc/apache2/ssl/

# Generate self-signed SSL certificate and key file
RUN openssl req -newkey rsa:2048 -days 365 -nodes -x509 \
    -subj "/C=US/ST=CA/L=San Francisco/O=My Org/CN=ihave.local" \
    -keyout /etc/apache2/ssl/private.key \
    -out /etc/apache2/ssl/certificate.crt

# Copy Apache config files
COPY vhosts/myapp.conf /etc/apache2/sites-available/myapp.conf
COPY vhosts/myapp-ssl.conf /etc/apache2/sites-available/myapp-ssl.conf

# Enable SSL module and site
#RUN ln -s /etc/apache2/mods-available/ssl.load /etc/apache2/mods-enabled/ssl.load

# Enable Apache virtual hosts
RUN a2ensite myapp && \
    a2ensite myapp-ssl && \
    service apache2 restart

CMD ["apache2-foreground"]