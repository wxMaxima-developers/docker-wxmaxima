#!/bin/sh

ENV wxmaxima_build Version-22.05.0

export wxmaxima_build=Version-22.12.0
export maxima_build=tags/5.46.0

git clone https://github.com/wxMaxima-developers/wxmaxima.git
cd wxmaxima
git checkout ${wxmaxima_build}
cd ..

git clone https://git.code.sf.net/p/maxima/code maxima-code
cd maxima-code
git checkout ${maxima_build}
cd ..

mkdir flatpack
flatpack-builder flatpack com.github.wxMaxima-developers.wxmaxima.yml
