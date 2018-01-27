
all:
	..\k65-sdk\bin\k65 @files.lst
	_makeprops.bat
	..\k65-sdk\bin\Stella.exe -propsfile props.cfg ggj2600.bin
