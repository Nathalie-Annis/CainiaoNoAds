ARCHS  = arm64 arm64e
TARGET = iphone:clang:latest:17.0      # 改成你的系统大版本
BUNDLE_ID = com.cainiao.cnwireless     # 若是国际 / 政企版请替换

include $(THEOS)/makefiles/common.mk

TWEAK_NAME            = CainiaoNoAds
CainiaoNoAds_FILES = Tweak.xm
CainiaoNoAds_CFLAGS = -fobjc-arc -Wno-deprecated-declarations

include $(THEOS_MAKE_PATH)/tweak.mk
