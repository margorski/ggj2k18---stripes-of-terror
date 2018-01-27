/\*/{
	MD5=$1
	BIN=$2
	sub(/\*/,"",BIN)
}

END{
	print "\"Cartridge.MD5\" \"" MD5 "\""
	print "\"Cartridge.Name\" \"" BIN "\""
#	print "\"Controller.Left\" \"KEYBOARD\""
#	print "\"Controller.Right\" \"KEYBOARD\""
	print "\"Display.Phosphor\" \"YES\""
	print "\"\""
}
