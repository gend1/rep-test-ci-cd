FROM ubuntu:22.04

# Установим все нужные пакеты в одном слое, очистим кеш apt для уменьшения размера образа
ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
       wget \
       bzip2 \
       make \
       unzip \
       cppcheck \
       git \
       ca-certificates \
    && update-ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Создаём директорию для инструментов
RUN mkdir -p /dev/tools

# Копируем уже распакованную папку с GCC в /opt
COPY gcc-arm-none-eabi-10.3-2021.10 /opt/gcc-arm-none-eabi-10.3-2021.10

# Добавляем бинарники GCC в PATH
ENV PATH="/opt/gcc-arm-none-eabi-10.3-2021.10/bin:${PATH}"
