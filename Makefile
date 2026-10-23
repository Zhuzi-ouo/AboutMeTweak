TARGET := iphone:clang:latest:15.0
ARCHS := arm64 arm64e

# 如果是 Rootless 越獄（如 Dopamine、Palera1n）需啟用以下旗標
THEOS_PACKAGE_SCHEME = rootless

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = AboutMeTweak

AboutMeTweak_FILES = Tweak.x \
    Classes/AboutMeHeaderView.m \
    Classes/AboutMeTweakManager.m \
    Classes/AboutMeUIFactory.m \
    Utils/AboutMeSystemInfo.m

AboutMeTweak_CFLAGS = -fobjc-arc
AboutMeTweak_FRAMEWORKS = UIKit CoreFoundation

include $(THEOS_MAKE_PATH)/tweak.mk
