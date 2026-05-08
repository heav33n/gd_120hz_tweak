all:
	~/theos/toolchain/linux/iphone/bin/clang \
		-target arm64-apple-ios15.0 \
		-isysroot ~/theos/sdks/iPhoneOS16.5.sdk \
		-shared \
		-fmodules \
		-framework UIKit \
		-framework QuartzCore \
		-o gd120hz.dylib \
		Tweak.m
	ldid -S gd120hz.dylib
