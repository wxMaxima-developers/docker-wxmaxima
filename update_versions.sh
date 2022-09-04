#!/bin/sh

maxima_build='tags\/5.46.0'
wxmaxima_build='Version-22.09.0'

sed -i -e "s/ENV maxima_build .*/ENV maxima_build $maxima_build/" Dockerfile
sed -i -e "s/ENV wxmaxima_build .*/ENV wxmaxima_build $wxmaxima_build/" Dockerfile
sed -i -e "s/export wxmaxima_build.*/export wxmaxima_build=$wxmaxima_build/" build_flatpack.sh
sed -i -e "s/export maxima_build.*/export maxima_build=$maxima_build/" build_flatpack.sh
