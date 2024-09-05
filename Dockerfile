# Use an official PHP runtime as a parent image
FROM php:8.1-apache

# Install necessary PHP extensions and other dependencies
RUN apt-get update && apt-get install -y \
    libfreetype6-dev \
    libjpeg62-turbo-dev \
    libpng-dev \
    libonig-dev \
    libzip-dev \
    libicu-dev \
    zip \
    unzip \
    git \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install -j$(nproc) gd mbstring pdo pdo_mysql zip intl

# Enable Apache mod_rewrite for CakePHP
RUN a2enmod rewrite

# Set the working directory
WORKDIR /var/www/html

# Copy the entire project into the container
COPY . /var/www/html


# Ensure the webroot directory exists
RUN mkdir -p /var/www/html/webroot

# Create necessary directories if they don't exist
RUN mkdir -p /var/www/html/tmp /var/www/html/logs

# Set permissions for the web server (optional, but recommended)
RUN chown -R www-data:www-data /var/www/html \
    && chmod -R 755 /var/www/html/tmp \
    && chmod -R 755 /var/www/html/logs

# Install Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Install CakePHP dependencies
RUN composer install --no-interaction --optimize-autoloader --no-dev

# Expose port 80
EXPOSE 80

# Set the environment variable for production
ENV APP_ENV=production


# Run Apache in the foreground
CMD ["apache2-foreground"]
