GO_EASY_ON_ME = 1

THEOS_DEVICE_IP = 127.0.0.1
THEOS_DEVICE_PORT = 2222

TARGET = iphone:clang:latest:7.0
ARCHS = armv7 armv7s arm64

include theos/makefiles/common.mk

TWEAK_NAME = springshot

springshot_CFLAGS = -fobjc-arc -Wno-ignored-attributes
springshot_FILES = Tweak.xm
springshot_LIBRARIES = substrate
springshot_FRAMEWORKS = Foundation UIKit

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 backboardd"
