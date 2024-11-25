#!/bin/bash
if [ -d jivelite-build ]; then
	rm -rf jivelite-build
fi

unsquashfs jivelite_touch.tcz 
mv squashfs-root jivelite-build

rm -rf jivelite-build/opt/jivelite/bin/{lua,luac} jivelite-build/opt/jivelite/lib/liblua.so jivelite-build/opt/jivelite/share/lua jivelite-build/opt/jivelite/lib/lua

if [ -f hdskins.tar.gz ]; then
	rm hdskins.tar.gz
fi

tar -czf hdskins.tar.gz jivelite-build/opt/jivelite/share/jive/applets/{HDGridSkin,HDSkin}

if [ -f wqvgaskins.tar.gz ]; then
	rm wqvgaskins.tar.gz
fi

tar -czf wqvgaskins.tar.gz jivelite-build/opt/jivelite/share/jive/applets/{WQVGAlargeSkin,WQVGAsmallSkin}

if [ -f qvgaskins.tar.gz ]; then
	rm qvgaskins.tar.gz
fi

tar -czf qvgaskins.tar.gz jivelite-build/opt/jivelite/share/jive/applets/{QVGAbaseSkin,QVGAlandscapeSkin,QVGAportraitSkin,QVGA240squareSkin}

rm -rf jivelite-build/opt/jivelite/share/jive/applets/{HDGridSkin,HDSkin}
rm -rf jivelite-build/opt/jivelite/share/jive/applets/{WQVGAlargeSkin,WQVGAsmallSkin}
rm -rf jivelite-build/opt/jivelite/share/jive/applets/{QVGAbaseSkin,QVGAlandscapeSkin,QVGAportraitSkin,QVGA240squareSkin}

cp -p pcp.png jivelite-build/opt/jivelite/share/jive/jive/splash.png

if [ -f pcp-jivelite-vis.tcz ]; then
	rm pcp-jivelite-vis.tcz
fi

mksquashfs jivelite-build pcp-jivelite-vis.tcz -all-root -no-progress
md5sum pcp-jivelite-vis.tcz > pcp-jivelite-vis.tcz.md5.txt
cd jivelite-build
find * -not -type d > ../pcp-jivelite-vis.tcz.list
cd ..
  
rm -rf jivelite-build
tar -xzf hdskins.tar.gz

if [ -f pcp-jivelite-vis_hdskins.tcz ]; then
	rm pcp-jivelite-vis_hdskins.tcz
fi

mksquashfs jivelite-build pcp-jivelite-vis_hdskins.tcz -all-root -no-progress
md5sum pcp-jivelite-vis_hdskins.tcz > pcp-jivelite-vis_hdskins.tcz.md5.txt
cd jivelite-build
find * -not -type d > ../pcp-jivelite-vis_hdskins.tcz.list
cd ..

rm -rf jivelite-build
tar -xzf wqvgaskins.tar.gz

if [ -f pcp-jivelite-vis_wqvgaskins.tcz ]; then
	rm pcp-jivelite-vis_wqvgaskins.tcz
fi

mksquashfs jivelite-build pcp-jivelite-vis_wqvgaskins.tcz -all-root -no-progress
md5sum pcp-jivelite-vis_wqvgaskins.tcz > pcp-jivelite-vis_wqvgaskins.tcz.md5.txt
cd jivelite-build
find * -not -type d > ../pcp-jivelite-vis_wqvgaskins.tcz.list
cd ..

rm -rf jivelite-build
tar -xzf qvgaskins.tar.gz

if [ -f pcp-jivelite-vis_qvgaskins.tcz ]; then
	rm pcp-jivelite-vis_qvgaskins.tcz
fi

mksquashfs jivelite-build pcp-jivelite-vis_qvgaskins.tcz -all-root -no-progress
md5sum pcp-jivelite-vis_qvgaskins.tcz > pcp-jivelite-vis_qvgaskins.tcz.md5.txt
cd jivelite-build
find * -not -type d > ../pcp-jivelite-vis_qvgaskins.tcz.list
cd ..

rm -rf jivelite-build
rm hdskins.tar.gz
rm wqvgaskins.tar.gz
rm qvgaskins.tar.gz
