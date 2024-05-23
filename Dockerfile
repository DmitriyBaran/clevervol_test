FROM php:7.4-apache

RUN apt-get update && apt-get install -y default-mysql-client \
    libzip-dev \
    unzip \
    && docker-php-ext-install pdo pdo_mysql zip

# Установка Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Установка Node.js и npm
RUN apt-get update && \
    apt-get install -y curl gnupg && \
    curl -sL https://deb.nodesource.com/setup_16.x | bash - && \
    apt-get install -y nodejs

# Копируем все файлы в контейнер
COPY . /var/www/html

# Установка рабочего каталога
WORKDIR /var/www/html

# Установка прав доступа
RUN chown -R www-data:www-data /var/www/html \
    && chmod -R 775 /var/www/html/storage \
    && chmod -R 775 /var/www/html/bootstrap/cache \
    && chmod -R 775 /var/www/html/public

# Установка зависимостей Composer
RUN composer install

# Установка npm-зависимостей и компиляция ассетов
RUN npm install && npm run prod


CMD ["php", "artisan", "serve", "--host=0.0.0.0", "--port=8000"]
