VERSION = 4.0.0-22.04

JDK = 17
NDK = android-ndk-r23c

define BUILD_ARGS
JDK=$(JDK)
NDK=$(NDK)
NDK_SUM=e5053c126a47e84726d9f7173a04686a71f9a67a
SDK=10406996_latest
SDK_SUM=87b485c7283cba69e41c10f05bf832d2fd691552
endef

define IMAGE_ENV
JAVA_HOME=/usr/lib/jvm/java-$(JDK)-openjdk-amd64
ANDROID_NDK_HOME=/opt/$(NDK)
ANDROID_HOME=/opt/android-sdk-linux
PATH=$${ANDROID_HOME}/build-tools/30.0.2:$${PATH}
PATH=$${ANDROID_HOME}/cmdline-tools/latest/bin:$${PATH}
PATH=$${ANDROID_HOME}/platform-tools:$${PATH}
PATH=$${ANDROID_NDK_HOME}:$${PATH}
endef
