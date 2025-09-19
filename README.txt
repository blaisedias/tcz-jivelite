How to build jivelite-vis for piCorePlayer

git clone https://github.com/blaisedias/tcz-jivelite.git
cd tcz-jivelite
git checkout vis
./build-vis.sh <jivelite branch or tag>
cp -v pcp-jivelite-vis.tcz* <destination_path>

Example: command line to build jivelite-vis release 2 ( uses git tag vis-release-2 )
./build-vis.sh vis-release-2


List of tcz files for installation:
pcp-jivelite-vis.tcz
pcp-jivelite-vis.tcz.dep
pcp-jivelite-vis.tcz.info
pcp-jivelite-vis.tcz.list
pcp-jivelite-vis.tcz.md5.txt


Notes:
1) The build scripts currently also generates the following tcz files for other skins.
pcp-jivelite-vis_hdskins.tcz.md5.txt
pcp-jivelite-vis_hdskins.tcz.list
pcp-jivelite-vis_hdskins.tcz
pcp-jivelite-vis_wqvgaskins.tcz.md5.txt
pcp-jivelite-vis_wqvgaskins.tcz.list
pcp-jivelite-vis_wqvgaskins.tcz
pcp-jivelite-vis_qvgaskins.tcz.md5.txt
pcp-jivelite-vis_qvgaskins.tcz.list
pcp-jivelite-vis_qvgaskins.tcz
pcp-jivelite-vis_qvgaskins.tcz.info
pcp-jivelite-vis_hdskins.tcz.info
pcp-jivelite-vis_wqvgaskins.tcz.info

These are not required or used by jivelite-vis.
Future changes to the scripts will remove the generation of these tcz files.

2) The build scripts also generates the following tcz files which are not part of the jivelite installation.
jivelite_touch.tcz.md5.txt
jivelite_touch.tcz
pcp-lua.tcz.md5.txt
pcp-lua.tcz.list
pcp-lua.tcz
pcp-lua.tcz.info

