FROM ubuntu:20.04

# Definir variáveis de ambiente para evitar interações durante a instalação
ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=America/Sao_Paulo

# Instalar dependências do sistema
RUN apt-get update && apt-get install -y \
    sudo \
    wget \
    unzip \
    python3-pip \
    openjdk-8-jdk

ENV ANDROID_HOME=/opt/android-sdk
ENV ANDROID_NDK_HOME=/opt/android-ndk
ENV PATH=$ANDROID_HOME/cmdline-tools/latest/bin:$ANDROID_HOME/platform-tools:$ANDROID_NDK_HOME:$PATH

# Baixar e instalar o Android SDK
RUN mkdir -p $ANDROID_HOME && \
    cd $ANDROID_HOME && \
    wget https://dl.google.com/android/repository/commandlinetools-linux-7583922_latest.zip -O sdk-tools.zip && \
    unzip sdk-tools.zip -d cmdline-tools && \
    rm sdk-tools.zip && \
    mkdir -p cmdline-tools/latest && \
    mv cmdline-tools/cmdline-tools/* cmdline-tools/latest/ && \
    rm -rf cmdline-tools/cmdline-tools

# Aceitar as licenças do SDK
RUN yes | $ANDROID_HOME/cmdline-tools/latest/bin/sdkmanager --sdk_root=$ANDROID_HOME --licenses

# Instalar pacotes necessários do Android SDK
RUN $ANDROID_HOME/cmdline-tools/latest/bin/sdkmanager --sdk_root=$ANDROID_HOME "platform-tools" "platforms;android-33" "build-tools;33.0.0"

# Baixar e instalar o Android NDK
RUN mkdir -p $ANDROID_NDK_HOME && \
    cd $ANDROID_NDK_HOME && \
    wget https://dl.google.com/android/repository/android-ndk-r21e-linux-x86_64.zip -O ndk.zip && \
    unzip ndk.zip && \
    rm ndk.zip && \
    mv android-ndk-r21e/* . && \
    rm -rf android-ndk-r21e

# Copiar o conteúdo do seu projeto para o container
COPY . /home/user/hostcwd/

# Copiar o arquivo build.spec
COPY build.spec /home/user/hostcwd/

WORKDIR /home/user/hostcwd/

# Instalar as dependências do Python for Android
RUN pip install --upgrade pip
RUN pip install python-for-android

# Executar o comando de build
CMD ["p4a", "apk", "--private", ".", "--package=org.example.myapp", "--name", "BLEScannerApp", "--version", "0.1", "--bootstrap=sdl2", "--requirements=python3,kivy,bleak", "--arch", "armeabi-v7a"]
