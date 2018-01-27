
CONVERT = ..\bin\convert.exe


all:	\
	flowtext.bmp


tmp\font.ppm: font.png
	$(CONVERT) font.png -compress none tmp\font.ppm

tmp\flowtext.ppm: _gen_text.awk flowtext.txt tmp\font.ppm
	gawk -f _gen_text.awk flowtext.txt

flowtext.bmp: tmp\flowtext.ppm
	$(CONVERT) tmp\flowtext.ppm -format bmp -define bmp:format=bmp3 flowtext.bmp

