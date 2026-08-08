TARGET := iphone:clang:latest:14.0
ARCHS = arm64
INSTALL_TARGET_PROCESSES = YouTube

# دعم البناء بدون روت (rootless) والعادي
THEOS_PACKAGE_SCHEME ?= rootless

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = YTOmarPlus

YTOmarPlus_FILES = Tweak.xm
YTOmarPlus_CFLAGS = -fobjc-arc
YTOmarPlus_FRAMEWORKS = UIKit AVFoundation

include $(THEOS_MAKE_PATH)/tweak.mk
