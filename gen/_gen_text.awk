

function ppm_load(IMAGE,path,	line,len,args,step,iw,ih,xp,yp,ch,i,col)
{
	# steps:
	#	1:	"P3" header
	#	2:	image size
	#	3:	levels count
	#	4:	image data
	step = 1;
	xp=0;
	yp=0;
	ch=0;
	col = 0;
	while( (getline line <path)>0 )
	{
		len = split(line,args);
		if(step==1)
		{
			if(len!=1 || args[1]!="P3") { close(path); return 0; }
			step++;
			continue;
		}
		if(step==2)
		{
			if(len!=2) { close(path); return 0; }
			IMAGE["w"] = iw = args[1]+0;
			IMAGE["h"] = ih = args[2]+0;
			if(iw<=0 || ih<=0) { close(path); return 0; }
			step++;
			continue;
		}
		if(step==3)
		{
			if(len!=1) { close(path); return 0; }
			IMAGE["levels"] = args[1]+0;
			if(IMAGE["levels"]!=255) { close(path); return 0; }
			step++;
			continue;
		}
		for(i=1;i<=len;i++)
		{
			col = or(col,lshift(and(args[i]+0,0xFF),(2-ch)*8));
			if(++ch>=3)
			{
				IMAGE[xp,yp] = col;
				col = 0;
				ch = 0;
				if(++xp>=iw)
				{
					xp=0;
					if(++yp>=ih) { close(path); return 1; }	# All OK
				}
			}
		}
	}

	close(path);
	return 0;
}

function ppm_save(IMAGE,path,	x,y,n)
{
	print "P3" >path;
	print IMAGE["w"] " " IMAGE["h"] >path;
	print IMAGE["levels"] >path;
	for(y=0;y<IMAGE["h"];y++)
		for(x=0;x<IMAGE["w"];x++)
		{
			if(n>0)
				printf(" ") >path;
			printf("%d %d %d",and(rshift(IMAGE[x,y],16),0xFF),and(rshift(IMAGE[x,y],8),0xFF),and(IMAGE[x,y],0xFF)) >path;
			if(++n>=8)
			{
				n=0;
				print "" >path;
			}
		}
	if(n>0)
		print "" >path;
	close(path);
}

function ppm_create(IMAGE,w,h)
{
	IMAGE["w"] = w;
	IMAGE["h"] = h;
	IMAGE["levels"] = 255;
}

function is_column_used(col,IMAGE,	y)
{
	for(y=0;y<IMAGE["h"];y++)
		if( and(IMAGE[col,y],0x808080) )
			return 1;
	return 0;
}

# populates image FONT with indexes:
#	FONT[char,"x"]	- starting X position
#	FONT[char,"w"]	- character width
#
function detect_fonts(FONT,charlist,	i,x,x0)
{
	x=0
	for(i=1;i<=length(charlist);i++)
	{
		while( !is_column_used(x,FONT) )
			if(++x>=FONT["w"])
				return;		# done

		x0=x;

		while( is_column_used(x,FONT) )
			x++;

		FONT[substr(charlist,i,1),"x"] = x0;
		FONT[substr(charlist,i,1),"w"] = x-x0;
		#print substr(charlist,i,1) ": " (x-x0) "  @ " x0;
	}
}

function font_putchar(FONT,IMAGE,xpos,ypos,ch,		x,y)
{
	for(x=0;x<FONT[ch,"w"];x++)
		for(y=0;y<FONT["h"];y++)
			IMAGE[xpos+x,ypos+y] = FONT[FONT[ch,"x"]+x,y];
}

function font_puttext(FONT,IMAGE,xpos,ypos,text,	i)
{
	for(i=1;i<=length(text);i++)
	{
		font_putchar(FONT,IMAGE,xpos,ypos,substr(text,i,1));
		xpos += FONT[substr(text,i,1),"w"]+1;
	}
}

function font_text_len(FONT,text,	i,len)
{
	len = 0;
	for(i=1;i<=length(text);i++)
		len += FONT[substr(text,i,1),"w"]+1;
	if(len>0) len--;
	return len;
}


BEGIN {
	ppm_load(FONT,"tmp/font.ppm");
	detect_fonts(FONT,"ABCDEFGHIJKLMNOPQRSTUVWXYZ.abcdefghijklmnopqrstuvwxyz")
	FONT[" ","x"] = -100
	FONT[" ","w"] = 1;

	ppm_create(IMAGE,500,256);
	YPOS = 0;
}

{
	FONT[" ","w"] = 1;
	txt = $0
	center = 0
	if(txt~/^\//)
	{
		txt = substr(txt,2);
		center = 1;
	}
	len = font_text_len(FONT,txt);

	if(len>48)
		FONT[" ","w"] = 0;

	font_puttext(FONT,IMAGE,0,YPOS,txt);

#	if( 11+len<48 && !center )
#		font_puttext(FONT,IMAGE,11,YPOS,txt);
#	else
#		font_puttext(FONT,IMAGE,int((48-len)/2),YPOS,txt);
	YPOS += 6;
}

END {
	ppm_save(IMAGE,"tmp/flowtext.ppm");
}
