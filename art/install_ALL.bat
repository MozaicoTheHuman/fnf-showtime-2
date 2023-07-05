@echo off
color 0a
echo INSTALL HAXE BEFORE RUNNING THIS .bat
echo Installing HaxeFlixel
haxelib install lime
haxelib install openfl
haxelib install flixel
haxelib run lime setup flixel
echo Setting Up Libs
haxelib run lime setup
haxelib install flixel-tools
haxelib run flixel-tools setup
echo Installing Showtime Libs
haxelib install hxCodec 2.6.1
haxelib git linc_luajit https://github.com/AndreiRudenko/linc_luajit.git
haxelib install hxcpp-debug-server
xcopy /s /i "discord_rpc" "C:\HaxeToolkit\haxe\lib\discord_rpc"
echo ---------------------------------------------------------------------
echo done.
pause
close