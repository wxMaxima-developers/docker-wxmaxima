#!/bin/sh
docker build -t wxmaxima .
docker run wxmaxima cat wxmaxima-x86_64.AppImage > wxmaxima-x86_64.AppImage
chmod +x wxmaxima-x86_64.AppImage
