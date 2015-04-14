# binterface-parser
Parse the string values of bInterfaceClass, bInterfaceSubClass and bInterfaceProtocol in usb.ids

How to use:
- get usb.ids (http://www.linux-usb.org/usb-ids.html)
- $ awk -f parseusb.awk usb.ids > classes.h
- $ gcc -o loflofl loflofl.c
- $ ./loflofl
