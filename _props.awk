/\*/{
	MD5=$1
	BIN=$2
	sub(/\*/,"",BIN)
}

END{
	print "\"Cartridge.MD5\" \"" MD5 "\""
	print "\"Cartridge.Name\" \"" BIN "\""
	print "\"Display.Phosphor\" \"YES\""
	print "\"\""
}
