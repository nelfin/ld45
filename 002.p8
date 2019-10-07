pico-8 cartridge // http://www.pico-8.com
version 18
__lua__
-- untitled ld45 game
-- made with ♥ by amh
--
-- theme: start from nothing


function _init()
	debug = false
 srand(321)
 px = 64
	py = 64
	velx = 0
	vely = 0
	pcounter = 0
	prate = 8
	psprite = 19
	
	fills = {
	 fill_none,
	 fill_blend,
	 fill_blend,
	 fill_blend,
	 --fill_blend,
	 fill_black
	}
	palettes={}

	function load_palette(key, idx)
	palettes[key] = {}
		for c=1,16,2 do
		addr = 0x0600+64*idx+(c-1)/2
		val = peek(addr)		
		palettes[key][c] = band(val,0x0f)
		palettes[key][c+1] = shr(band(val,0xf0),4)
		end
	end

	load_palette(2,0)
	load_palette(3,1)
	load_palette(4,2)
	--load_palette(5,3)

end

function _update60()
	adjust_velocity()
	advance_sprite()
	move_cursor()
end

function _draw()
	cls()
	if (not debug) clip(px-42, py-42, 84, 84) 
 draw_background()
 draw_cursor()
	apply_lighting(px, py, px-42, px+42)
	if (debug) then
		clip()
	 print(flr(100*stat(1)).."%", 0, 0, 1)
	 print(stat(7).."fps", 24, 0, 1)
	end
end

--

function advance_sprite()
	if (abs(velx) + abs(vely)) > 0.5 then
		prate = 4
	else
		prate = 8
	end
 pcounter += 1
 if (pcounter > prate) then
 	psprite += 1
 	pcounter = 0
 end
	if (psprite > 22) then
		psprite = 19
	end
end

function adjust_velocity()
	if (btn(🅾️)) then
		velx = 0
		vely = 0
	end
	velx /= 1.03
	vely /= 1.03
	if (abs(velx) < 0.001) velx = 0
	if (abs(vely) < 0.001) vely = 0
	if (velx < -2) velx = -2
	if (velx > 2) velx = 2
	if (vely < -2) vely = -2
	if (vely > 2) vely = 2
	if (btn(⬅️)) velx -= 0.03
	if (btn(➡️)) velx += 0.03
	if (btn(⬆️)) vely -= 0.03
	if (btn(⬇️)) vely += 0.03
end

function move_cursor()
	px += velx
	py += vely
	-- bounce
	if (px < 0) velx *= -0.90
	if (px > 128) velx *= -0.90
	if (py > 128) vely *= -0.90
	if (py < 0) vely *= -0.90
 -- clip
	if (px < 0) px = 0
	if (px > 128) px = 128
	if (py > 128) py = 128
	if (py < 0) py = 0
end

function draw_background()
 if (debug) then rectfill(0, 0, 128, 128, 12)
 else map(0, 0, 0, 0, 16, 16)
 end
end

function draw_cursor()
	spr(psprite, px, py)
end

-->8
--- lighting functions
--maxrange = 42
--levels = 6

function apply_lighting(lx, ly, x1, x2)
	local maxrange = 42
	local levels = 5
	for cy=-maxrange,maxrange do
		local offset = flr(rnd(2))-1
		local retval = breakpoints(cy)
		local xs = x1+offset
		for lvl=levels,retval.top+1,-1 do
			local xe = lx-retval.b[lvl-1]+offset
			fills[lvl](xs, xe-1, ly+cy, lvl)
			xs = xe
		end
		for lvl=retval.top,levels-1 do
			xe = lx+retval.b[lvl]+offset
			fills[lvl](xs, xe-1, ly+cy, lvl)
			xs = xe
	 end
	 fills[levels](xs, x2+offset, ly+cy, levels)
	end
end
	
function _breakpoints(cy)
 light_range = {10*42, 18*42, 26*42, 34*42, 42*42}
 ret = {}
 ret.b = {0,0,0,0,0}
 ret.top = 1
 y2 = cy*cy
 for lvl=4,1,-1 do
 	range = light_range[lvl]
 	x2 = range-y2
 	if x2 > 0 then
 		ret.b[lvl] = sqrt(x2)
 	else
 		ret.top = lvl+1
 		break
 	end
 end
 return ret
end

function breakpoints(cy)
	if cachebp == nil then
		cachebp = {}
	for cy=-42,42 do
			cachebp[cy] = _breakpoints(cy)
		end
	end
	return cachebp[cy]
end

function fill_none(xmin, xmax, y, lvl)
end

function fill_black(xmin, xmax, y, lvl)
	line(xmin, y, xmax, y, 0)
end

function fill_ignore(xmin, xmax, y, c)
	fade = {10, 9, 4, 5, 0}
 mapc = fade[c]
	line(xmin, y, xmax, y, mapc)
end

function fill_blend(xmin, xmax, y, lvl)
	for x=flr(xmin),xmax do
		local c = pget(x,y)
		c = palettes[lvl][c+1]
		pset(x, y, c)
	end
end

function fill_lut(xmin, xmax, y, lvl)
	local lut = 0x0800+256*(lvl-3)
	for x=flr(xmin),xmax,2 do
--		print(xmin)
		--c = pget(x,y) 
		--c = palettes[lvl][c+1]
		--pset(x, y, c)
		--print(screenaddr(x, y), 0, 16)
	--	break
		c = peek(screenaddr(x, y))
		print(c, 80, 8, 15)
		c = peek(bor(lut, c))
		print(c, 80, 16, 15)
		--c = palettes[lvl][c+1]
			extcmd("shutdown")
		poke(screenaddr(x, y), c)
		--pset(x, y, c)
	end
end

function screenaddr(x, y)
	a = 0x6000+0x40*y+x
	pset(x,y+1, 8)
	--return a
	print(x..","..y..","..a, 80, 0, 15)
--	extcmd("shutdown")
end
-->8
--- sound routines


__gfx__
0000000011e01010000000000300333000000000000bb0000065550000000000000000000000000033300000000000000000000011c1cc999999999900000000
0000000002020202000000003323b33200000300033b3b2005555550000200000000000000330003b3bb300000020000000200001111cc9a9a999a9a00000000
0070070000a00a00000000003bbbbb2300488b0003b333b0555595550e03008000b3b0b003333b33339b33300ab300800e0300801c17c99999a9999900000000
0007700000006000000000003b2344bb0044220003b343305449944503003030b3333b343333333333b333330aa0303003003030111cc9999999a99900000000
0007700000a06a0000000000bbbb3b43000020000033400054449445b3bb3b30b33bbbbb033b333333333330333b3b3bb3bb3b30111c7cc999a9999900000000
007007000000600000000000b3b33b330ccccc000004400054444445bbbbbbb34400000400823333393333303bbbbbbbbbbbbbb31c117c99999a99a900000000
0000000000a06a000000000003b33333011111100005400055555555000abbb3000000000088b3b3374003003bb3bbb3000abbb311117c999a999a9900000000
00000000000060000000000034543400000000000054450000000000000003330000000000000000444000000b000330000003331c17ccc9999a999900000000
000000000880000000000000008800000000000000800000088800005454445500000000000000057540000000000000000000001117cc99999a999900000000
9a0000008a9000000000000000888000088800000898000088980800544454450000000000000004445000000000000000000000111cc99999999a9900000000
000000009a900000000000000889800008a90000899980008998880058455575000000000000000e4645000000b3b0b000003000111cc999999999a900000000
0000000009000000000000008999800009aa900089a9800089999800545245550000000000000a0354400000b3333b340054333b1117c99a9993999900000000
00000000000000000000000089a98000099990008aa9800089aa980055544645000000000e00534345400000b33bbbbb005440331c17c9999999399900000000
00000000000000000000000088988000000000008898000088998800565454450000000003045344444484004400000450440303111cc9a99993999900000000
000000000000000000000000008000000000000000000000088800005455545500000000035533330044444400000000000000001c17c9999999999900000000
000000000000000000000000000000000000000000000000000000005445245500000000000050000000400400000000000000001111cc999999a99900000000
0000000000000000000000000000000000000000008000004444524554545455000000050000000000000000000000000000000099999a000000000000000000
0000000000000000000000000000000000000000089800004475454554545545500000540000000000000000000000000000000099aa99009000000000000000
00000000000000000000000000000000000000008999800054556440555465555500544400000030000030000000000000000000999aaa000000000000000000
000000000000000000000000000000000000000089a980005454554056524695464444440000b033b3b3b3000000000000000000a99a9a0a0000000000000000
00000000000000000000000000000000000000008aa9800045545000575446555455545500033b1111111130000000000000000099aaa9090000000000000000
00000000000000000000000000000000000000008898000042555400565455255452525203b11111ccccc0300000000000000000a999aaa00000000000000000
000000000000000000000000000000000000000000000000554540005455545569554444011ccccccc7ccd10000000000000000099a999a00000000000000000
00000000000000000000000000000000000000000000000045400000544524555455455531cc01cc11cd11130000000000000000a9aa99aa0000000000000000
0143456689abcd8e0000000000000000000555555555555555555555555555555555000033ccc61cc7ccc1110000000000000000a999aaa00000000000000000
014355562493d522000000000000000000000404595454545954545452545652440402000310ccc11cccc113000000000000000099a9a99a0000000000000000
01445155249411220000000000000000052000045524544455245444556455244545455455bbc111cc1cc130000000000000000099a99aa00000000000000000
00011011044410000000000000000000404444044644444446444444444447444644404405033cc3cccc11b400000000000000009999a9000000000000000000
0123456789abcdef0000000000000000005554555455545554555455545554555455445044b313b5333155bb0000000000000000999a99a00000000000000000
000000000000000000000000000000000052505259500252575252525252525254524050544533545304544400000000000000009999a9a00000000000000000
0000000000000000000000000000000000054444600000006955444444556455444440000004444444544000000000000000000099aa99000000000000000000
000000000000000000000000000000000400055500000000545545555555555505550400000000000000000000000000000000009999a9a9a000000000000000
000104030405060608090a0b0c0d080e101114131415161618191a1b1c1d181e404144434445464648494a4b4c4d484e303134333435363638393a3b3c3d383e
404144434445464648494a4b4c4d484e505154535455565658595a5b5c5d585e606164636465666668696a6b6c6d686e606164636465666668696a6b6c6d686e
808184838485868688898a8b8c8d888e909194939495969698999a9b9c9d989ea0a1a4a3a4a5a6a6a8a9aaabacada8aeb0b1b4b3b4b5b6b6b8b9babbbcbdb8be
c0c1c4c3c4c5c6c6c8c9cacbcccdc8ced0d1d4d3d4d5d6d6d8d9dadbdcddd8de808184838485868688898a8b8c8d888ee0e1e4e3e4e5e6e6e8e9eaebecede8ee
0001040305050506020409030d0502021011141315151516121419131d1512124041444345454546424449434d4542423031343335353536323439333d353232
5051545355555556525459535d5552525051545355555556525459535d5552525051545355555556525459535d5552526061646365656566626469636d656262
2021242325252526222429232d2522224041444345454546424449434d4542429091949395959596929499939d9592923031343335353536323439333d353232
d0d1d4d3d5d5d5d6d2d4d9d3ddd5d2d25051545355555556525459535d5552522021242325252526222429232d2522222021242325252526222429232d252222
00010404050505050204090401010202101114141515151512141914111112124041444445454545424449444141424240414444454545454244494441414242
50515454555555555254595451515252505154545555555552545954515152525051545455555555525459545151525250515454555555555254595451515252
20212424252525252224292421212222404144444545454542444944414142429091949495959595929499949191929240414444454545454244494441414242
10111414151515151214191411111212101114141515151512141914111112122021242425252525222429242121222220212424252525252224292421212222
__label__
88888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888
88888eeeeee888888888888888888888888888888888888888888888888888888888888888888888888ff8ff8888228822888222822888888822888888228888
8888ee888ee88888888888888888888888888888888888888888888888888888888888888888888888ff888ff888222222888222822888882282888888222888
888eee8e8ee88888e88888888888888888888888888888888888888888888888888888888888888888ff888ff888282282888222888888228882888888288888
888eee8e8ee8888eee8888888888888888888888888888888888888888888888888888888888888888ff888ff888222222888888222888228882888822288888
888eee8e8ee88888e88888888888888888888888888888888888888888888888888888888888888888ff888ff888822228888228222888882282888222288888
888eee888ee888888888888888888888888888888888888888888888888888888888888888888888888ff8ff8888828828888228222888888822888222888888
888eeeeeeee888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111666161611111111111111111616166616111616111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111616161611111171177711111616161116111616111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111666116111111777111111111616166116111161111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111611161611111171177711111666161116111616111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111611161611111111111111111161166616661616111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111eee1eee11111171166616161111171111111cc11ccc1ccc11711111166616161111111111111ccc11111111111111111111111111111111111111111111
111111e11e11111117111616161611111171111111c1111c1c1c11171111161616161111177711111c1c11111111111111111111111111111111111111111111
111111e11ee1111117111666116111111117111111c11ccc1ccc11171111166611611111111111111c1c11111111111111111111111111111111111111111111
111111e11e11111117111611161611111171111111c11c111c1c11171111161116161111177711111c1c11111111111111111111111111111111111111111111
11111eee1e1111111171161116161111171111111ccc1ccc1ccc11711111161116161111111111111ccc11111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
1eee1ee11ee111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
1e111e1e1e1e11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
1ee11e1e1e1e11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
1e111e1e1e1e11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
1eee1e1e1eee11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
1eee1e1e1ee111ee1eee1eee11ee1ee1111116611666166616161111166616661166161611661666116616161661166111711171111111111111111111111111
1e111e1e1e1e1e1111e111e11e1e1e1e111116161616161616161111161616161611161616111616161616161616161617111117111111111111111111111111
1ee11e1e1e1e1e1111e111e11e1e1e1e111116161661166616161111166116661611166116111661161616161616161617111117111111111111111111111111
1e111e1e1e1e1e1111e111e11e1e1e1e111116161616161616661111161616161611161616161616161616161616161617111117111111111111111111111111
1e1111ee1e1e11ee11e11eee1ee11e1e111116661616161616661666166616161166161616661616166111661616166611711171111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111eee11ee1eee1111166611111cc111111cc11ccc1ccc11111ee111ee11111111111111111111111111111111111111111111111111111111111111111111
11111e111e1e1e1e11111161177711c1111111c1111c1c1c11111e1e1e1e11111111111111111111111111111111111111111111111111111111111111111111
11111ee11e1e1ee111111161111111c1111111c11ccc1ccc11111e1e1e1e11111111111111111111111111111111111111111111111111111111111111111111
11111e111e1e1e1e11111161177711c1117111c11c111c1c11111e1e1e1e11111111111111111111111111111111111111111111111111111111111111111111
11111e111ee11e1e1111166611111ccc17111ccc1ccc1ccc11111eee1ee111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111118888811111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
111111111b111bbb1bb11bbb11718888811111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
111111111b1111b11b1b1b1117118888811111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
111111111b1111b11b1b1bb117118888811111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
111111111b1111b11b1b1b1117118888811111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
111111111bbb1bbb1b1b1bbb11718888811111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
1eee1e1e1ee111ee1eee1eee11ee1ee1111116611666166616161111116616161666116611661666117111711111111111111111111111111111111111111111
1e111e1e1e1e1e1111e111e11e1e1e1e111116161616161616161111161116161616161116161616171111171111111111111111111111111111111111111111
1ee11e1e1e1e1e1111e111e11e1e1e1e111116161661166616161111161116161661166616161661171111171111111111111111111111111111111111111111
1e111e1e1e1e1e1111e111e11e1e1e1e111116161616161616661111161116161616111616161616171111171111111111111111111111111111111111111111
1e1111ee1e1e11ee11e11eee1ee11e1e111116661616161616661666116611661616166116611616117111711111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
111111bb1bbb1bbb1171166611661666166616661666166611111111166616161111111116661616117111111111111111111111111111111111111111111111
11111b111b1b1b1b1711161616111616161611611161161111111111161616161111111116161616111711111111111111111111111111111111111111111111
11111bbb1bbb1bb11711166616661666166111611161166111111111166611611111111116661666111711111111111111111111111111111111111111111111
1111111b1b111b1b1711161111161611161611611161161111711111161116161171111116111116111711111111111111111111111111111111111111111111
11111bb11b111b1b1171161116611611161616661161166617111111161116161711111116111666117111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
1eee1ee11ee111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
1e111e1e1e1e11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
1ee11e1e1e1e11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
1e111e1e1e1e11111111111111111111111111111111111111111111111111111111111711111111111111111111111111111111111111111111111111111111
1eee1e1e1eee11111111111111111111111111111111111111111111111111111111111771111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111777111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111777711111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111771111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111117111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
1eee1e1e1ee111ee1eee1eee11ee1ee1111116611666166616161111166616661666166611661666116611711171111111111111111111111111111111111111
1e111e1e1e1e1e1111e111e11e1e1e1e111116161616161616161111161116111611161116111161161117111117111111111111111111111111111111111111
1ee11e1e1e1e1e1111e111e11e1e1e1e111116161661166616161111166116611661166116111161166617111117111111111111111111111111111111111111
1e111e1e1e1e1e1111e111e11e1e1e1e111116161616161616661111161116111611161116111161111617111117111111111111111111111111111111111111
1e1111ee1e1e11ee11e11eee1ee11e1e111116661616161616661666166616111611166611661161166111711171111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111eee1eee1111117116661611166611661616111116661111171111111ccc117111111eee1e1e1eee1ee11111111111111111111111111111111111111111
111111e11e111111171116111611161616111616111111611111117111111c1c1117111111e11e1e1e111e1e1111111111111111111111111111111111111111
111111e11ee11111171116611611166616661666111111611111111711111c1c1117111111e11eee1ee11e1e1111111111111111111111111111111111111111
111111e11e111111171116111611161611161616111111611111117111111c1c1117111111e11e1e1e111e1e1111111111111111111111111111111111111111
11111eee1e111111117116111666161616611616117111611111171111111ccc1171111111e11e1e1eee1e1e1111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
1111111111bb1bbb1bbb11bb1bbb1bbb1b111b111171166616111666116616161111161611111111166616111666116616161111161611111111166616111666
111111111b1111b11b1b1b111b1111b11b111b111711161116111616161116161111161611111111161116111616161116161111161611111111161116111616
111111111b1111b11bb11b111bb111b11b111b111711166116111666166616661111116111111111166116111666166616661111166611111111166116111666
111111111b1111b11b1b1b111b1111b11b111b111711161116111616111616161111161611711111161116111616111616161111111611711111161116111616
1111111111bb1bbb1b1b11bb1b111bbb1bbb1bbb1171161116661616166116161171161617111111161116661616166116161171166617111111161116661616
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
1111111111bb1bbb1bbb11bb1bbb1bbb1b111b111171166616111666116616161111161611111111166616111666116616161111161611111111166616111666
111111111b1111b11b1b1b111b1111b11b111b111711161116111616161116161111161611111111161116111616161116161111161611111111161116111616
111111111b1111b11bb11b111bb111b11b111b111711166116111666166616661111116111111111166116111666166616661111166611111111166116111666
111111111b1111b11b1b1b111b1111b11b111b111711161116111616111616161111161611711111161116111616111616161111111611711111161116111616
1111111111bb1bbb1b1b11bb1b111bbb1bbb1bbb1171161116661616166116161171161617111111161116661616166116161171166617111111161116661616
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
1111111111bb1bbb1bbb11bb1bbb1bbb1b111b111171166616111666116616161111161611111111166616111666116616161111161611111111166616111666
111111111b1111b11b1b1b111b1111b11b111b111711161116111616161116161111161611111111161116111616161116161111161611111111161116111616
111111111b1111b11bb11b111bb111b11b111b111711166116111666166616661111116111111111166116111666166616661111166611111111166116111666
111111111b1111b11b1b1b111b1111b11b111b111711161116111616111616161111161611711111161116111616111616161111111611711111161116111616
1111111111bb1bbb1b1b11bb1b111bbb1bbb1bbb1171161116661616166116161171161617111111161116661616166116161171166617111111161116661616
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
1111111111bb1bbb1bbb11bb1bbb1bbb1b111b111171166616111666116616161111161611111111166616111666116616161111161611111111166616111666
111111111b1111b11b1b1b111b1111b11b111b111711161116111616161116161111161611111111161116111616161116161111161611111111161116111616
111111111b1111b11bb11b111bb111b11b111b111711166116111666166616661111116111111111166116111666166616661111166611111111166116111666
111111111b1111b11b1b1b111b1111b11b111b111711161116111616111616161111161611711111161116111616111616161111111611711111161116111616
1111111111bb1bbb1b1b11bb1b111bbb1bbb1bbb1171161116661616166116161171161617111111161116661616166116161171166617111111161116661616
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111eee1ee11ee11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111e111e1e1e1e1111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111ee11e1e1e1e1111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111e111e1e1e1e1111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111eee1e1e1eee1111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
1eee1ee11ee111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
1e111e1e1e1e11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
1ee11e1e1e1e11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
88888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888
82888222822882228888822282228882822282228888888888888888888888888888888888888888888888888222822882228882822282288222822288866688
82888828828282888888828882828828888288828888888888888888888888888888888888888888888888888882882882828828828288288282888288888888
82888828828282288888822282228828888288228888888888888888888888888888888888888888888888888222882882228828822288288222822288822288
82888828828282888888888282828828888288828888888888888888888888888888888888888888888888888288882888828828828288288882828888888888
82228222828282228888822282228288888282228888888888888888888888888888888888888888888888888222822288828288822282228882822288822288
88888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888

__map__
1d1e2d0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0d1e2d0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1d1e3d00000000010000001b0c00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0d0e3d0000030300060100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1d0e2d0008081c00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1d0e2d00000000001c00090a0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0d1e2d001c080c080004191a1c00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0d0e3d0034362837363537373638000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0d1e3d1c0c070000292a0027001c0b0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0d0e3d0000000000393a07170000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1d1e2d0000000000000005270b00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1d0e2d000000000000343626001b0c0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1d1e3d000005031c000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0d0e3d0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1d0e2d0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0d0e2d0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
000a00000761002610036100461004610046100561004610046100361001610006100061000610006100061001610026100361001610036100561005610056100060000600006000060000600006000060000600
000100001021002210002100020000200002000020000200002000020000200002000020000200002000020000200002000020000200002000020000200002000020000200002000020000200002000020000200
000800000a8200b8400f8501785010850128600b8501284015830188301784012860148401484014840168501a8502185024860218601c85017850188501a8401484012840128200d830088200e8101282011820
011000002480024800248002390000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__music__
03 02414344
00 42414344

