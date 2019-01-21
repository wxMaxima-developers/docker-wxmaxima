Appimage build for wxMaxima
===========================

Building Appimage
-----------------

To build the Appimage, run the following command:

```
$ docker build -t wxmaxima .
```

This will build all dependenecies and the wxMaxima application itself.
After the build has completed, run the following command to copy the
Appimage from the container:

```
$ docker run maxima cat wxmaxima-x86_64.AppImage > wxmaxima-x86_64.AppImage
```

Finally, set the executable flag so that the executable can be run:

```
$ chmod +x wxmaxima-x86_64.AppImage
```
