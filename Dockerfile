# Pull base image.
FROM debian:jessie

MAINTAINER Dominik Hahn <dominik@monostream.com>

# Set ENV
ENV DEBIAN_FRONTEND noninteractive
ENV ANDROID_SDK_VERSION r24.4.1
ENV ANDROID_BUILD_TOOLS_VERSION build-tools-17,build-tools-18,build-tools-19,build-tools-20,build-tools-21,build-tools-22,build-tools-23,build-tools-24
ENV ANDROID_SDK_FILENAME android-sdk_${ANDROID_SDK_VERSION}-linux.tgz
ENV ANDROID_SDK_URL http://dl.google.com/android/${ANDROID_SDK_FILENAME}
ENV ANDROID_API_LEVELS android-17,android-18,android-19,android-20,android-21,android-22,android-23,android-24
ENV ANDROID_HOME /opt/android-sdk-linux
ENV PATH ${PATH}:${ANDROID_HOME}/tools:${ANDROID_HOME}/platform-tools

# Add OpenJDK8 and enable gradle daemon
RUN echo "deb http://http.debian.net/debian jessie-backports main" | tee -a /etc/apt/sources.list && \
    echo "oracle-java8-installer shared/accepted-oracle-license-v1-1 select true" | debconf-set-selections && \
    mkdir -p ~/.gradle/ && \
    touch ~/.gradle/gradle.properties && \
    echo "org.gradle.daemon=true" >> ~/.gradle/gradle.properties

# Enable multiarch i386, install OpenJDK, ADB & AAPT
RUN dpkg --add-architecture i386 && \
    apt-get -yqq update && \
    apt-get -yqq install curl openjdk-8-jdk libc6:i386 libc6-dev:i386 libncurses5:i386 libstdc++6:i386 lib32z1 && \
    update-alternatives --config java && \
    apt-get -yqq autoremove && \
    apt-get -yqq clean && \
    rm -rf /var/lib/apt/lists/* /var/cache/* /tmp/* /var/tmp/*

# Installs Android SDK and accept licenses
RUN cd /opt && \
    curl -s ${ANDROID_SDK_URL} | tar -xz && \
    ( sleep 5 && while [ 1 ]; do sleep 1; echo y; done ) | android -s --clear-cache update sdk --no-ui --all --filter tools,platform-tools && \
    ( sleep 5 && while [ 1 ]; do sleep 1; echo y; done ) | android -s --clear-cache update sdk --no-ui --all --filter tools,platform-tools,${ANDROID_API_LEVELS},${ANDROID_BUILD_TOOLS_VERSION},extra-android-support,extra-android-m2repository,extra-google-m2repository && \
    mkdir -p "$ANDROID_HOME/licenses" && \
    echo -e "\n8933bad161af4178b1185d1a37fbf41ea5269c55" > "$ANDROID_HOME/licenses/android-sdk-license" && \
    echo -e "\n84831b9409646a918e30573bab4c9c91346d8abd" > "$ANDROID_HOME/licenses/android-sdk-preview-license"
