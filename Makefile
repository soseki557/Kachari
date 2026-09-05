PRODUCT_NAME := Kachari

.PHONY: generate
generate:
	mint run xcodegen xcodegen generate
	make open

.PHONY: open
open:
	open ./${PRODUCT_NAME}.xcodeproj
