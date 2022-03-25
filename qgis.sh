#!/bin/bash
while [ -n "$1" ]
do
case "$1" in
-e) param="$2"
	echo "Found the -e option, with parameter value $param" 
	release=release-3_$param
	oversion='/opt/oracle/instantclient_21_4'
	gpath='/usr/local/$grass'
	export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:${HOME}/dev/cpp/build-QGIS$release/output/lib:$oversion
	cd ${HOME}/dev/cpp/build-QGIS$release/output/bin/
	./qgis ;;

-g) param="$2"
	echo "Grass Version is set to $param"
	grass=grass$param ;;

-b) param="$2"
	echo "Found the -b option, with parameter value $param"
	release=release-3_$param
	oversion='/opt/oracle/instantclient_21_4'
	gpath="/usr/local/$grass"
	cd ~/dev/cpp/QGIS
	git fetch upstream
	git stash
	git checkout -f $release
	git pull upstream $release
	[[ -d ~/dev/cpp/build-QGIS$release ]] || mkdir ~/dev/cpp/build-QGIS$release
	cd ~/dev/cpp/build-QGIS$release
	cmake ../QGIS/\
		-DWITH_ORACLE=ON \
		-DWITH_3D=ON \
		-DWITH_PDAL=ON \
		-DWITH_EPT=ON \
		-DGRASS_PREFIX7=$gpath \
		-DGRASS_PREFIX8=$gpath \
		-DOCI_LIBRARY=$oversion/libclntsh.so \
		-DOCI_INCLUDE_DIR=$oversion/sdk/include \
		-G Ninja
	ninja -j`nproc` -l$((`nproc`-1))
shift ;;
--) shift
break ;;
*) echo "$1 is not an option";;
esac
shift
done
count=1
for param in "$@"
do
echo "Parameter #$count: $param"
count=$(( $count + 1 ))
done
