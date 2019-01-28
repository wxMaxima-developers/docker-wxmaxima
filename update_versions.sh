#!/bin/sh

maxima_build='tags\/5.42.2'
wxmaxima_build='ae6bc1663110ce6f56a1deaaf2a2a7e6876a2ee0'

sed -i -e "s/ENV maxima_build .*/ENV maxima_build $maxima_build/" Dockerfile
sed -i -e "s/ENV wxmaxima_build .*/ENV wxmaxima_build $wxmaxima_build/" Dockerfile
