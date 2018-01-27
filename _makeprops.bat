@echo off
md5sum ggj2600.bin | gawk -f _props.awk >props.cfg
