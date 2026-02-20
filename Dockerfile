FROM node:20

# Android SDK
ENV ANDROID_SDK_ROOT=/opt/android-sdk
ENV PATH=$ANDROID_SDK_ROOT/emulator:$ANDROID_SDK_ROOT/platform-tools:$PATH

RUN apt-get update && apt-get install -y unzip wget openjdk-17-jdk

# Install Android SDK
RUN mkdir -p $ANDROID_SDK_ROOT
WORKDIR $ANDROID_SDK_ROOT
RUN wget https://dl.google.com/android/repository/commandlinetools-linux-9477386_latest.zip -O cmdline-tools.zip \
    && unzip cmdline-tools.zip -d cmdline-tools && rm cmdline-tools.zip

RUN yes | $ANDROID_SDK_ROOT/cmdline-tools/cmdline-tools/bin/sdkmanager --licenses
RUN $ANDROID_SDK_ROOT/cmdline-tools/cmdline-tools/bin/sdkmanager "platform-tools" "platforms;android-36" "system-images;android-36;google_apis_playstore;x86_64" "emulator"

WORKDIR /app
COPY package*.json tsconfig.json ./
RUN npm install
COPY . .

CMD ["pwsh", "-File", "run-tests.ps1", "-Headless"]