#THEOS_DEVICE_IP = 127.0.0.1
#THEOS_DEVICE_PORT = 2222

THEOS_DEVICE_IP = 10.0.2.45

GO_EASY_ON_ME = 1

TARGET_IPHONEOS_DEPLOYMENT_VERSION = 7.0
TARGET_CC = xcrun -sdk iphoneos clang 
TARGET_CXX = xcrun -sdk iphoneos clang++
TARGET_LD = xcrun -sdk iphoneos clang++
ADDITIONAL_OBJCFLAGS = -fobjc-arc

include theos/makefiles/common.mk

TWEAK_NAME = springshot

springshot_FILES = Tweak.xm
springshot_FRAMEWORKS = Foundation UIKit

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 backboardd"
