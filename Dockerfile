# Escolhe uma imagem oficial PHP 8.4-cli baseada em Debian bookworm
FROM php:8.4-cli-bookworm

# Instala extensões necessárias para PDO MySQL e outras ferramentas
RUN apt-get update && apt-get install -y \
    git \
    unzip \
    zip \
    libzip-dev \
    libonig-dev \
    libpq-dev \
    default-mysql-client \
    && docker-php-ext-install pdo pdo_mysql zip \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Define diretório de trabalho
WORKDIR /app

# Copia composer.lock e composer.json primeiro para cache efetivo do composer install
COPY composer.lock composer.json /app/

# Instala o Composer
RUN php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" \
    && php composer-setup.php --install-dir=/usr/local/bin --filename=composer \
    && php -r "unlink('composer-setup.php');"

# Roda composer install com otimizador
RUN composer install --no-dev --optimize-autoloader

# Copia todo o código do projeto
COPY . /app

# Expõe a porta que Railway vai mapear (variável PORT é do Railway)
EXPOSE 8080

# Comando default para rodar o servidor PHP embutido na pasta public na porta que o Railway passar
#CMD ["sh", "-c", "php -S 0.0.0.0:${PORT:-8080} -t public"]
CMD php -S 0.0.0.0:${PORT:-8080} -t public

