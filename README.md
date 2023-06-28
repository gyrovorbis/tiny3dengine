# Tiny 3D Engine
Tiny 3D Engine for the Sega Dreamcast's Visual Memory Unit by Thomas Fuchs / The Rockin'-B

<table><tr>
<td>
  <p align="left"><img src="https://github.com/gyrovorbis/tiny3dengine/blob/master/img/tiny3dBig.gif?raw=true" alt="Screen Capture 1" width="192" height="128"><br>
  </td><td>
<p align="left"><img src="https://github.com/gyrovorbis/tiny3dengine/blob/master/img/title.png?raw=true" alt="Title" width="192" height="128">
  </td><td>
<p align="left"><img src="https://github.com/gyrovorbis/tiny3dengine/blob/master/img/tiny3dBig2.gif?raw=true" alt="Screen Capture 2" width="192" height="128">
  </td><td>
<p align="left"><img src="https://github.com/gyrovorbis/tiny3dengine/blob/master/img/vms_icon.gif?raw=true" alt="VMS Icon" width="128" height="128">
  </td></tr></table>

## Features
* Generic Matrix Transform Stack
* Translation, Rotation, Scaling Operations
* Perspective Projection Matrix
* Multiple Geometry Types
* Fast Lookup Table-Based SIN/COS Functions
* Rendering Functions for Points and Lines
* Clipping Routines 
* 16-Bit Addition (with Carry) of 2 Twos-Compliment Integers
* 16-Bit Multiplicaton of 2 Twos-Compliment Integers
* 16-Bit Division of 2 Twos-Compliment Integers
* Dot Product for 3D/4D Vectors

## History
The Tiny3D engine was developed from 2003 to 2006 by Thomas Fuchs, aka "The Rockin'-B," who was a well-known indie developer within the Sega Dreamcast VMU and Sega Saturn homebrew communities. It was originally released for download on his site, http://www.rockin-b.de/, where it stayed for many years, until the links eventually broke sometime around 2010. 

For years, Tiny3D engine was just an incredibly impressive ROM circulating around without any source code, with The Rockin'-B seemingly disappearing from the homebrew scene and his website. In 2023, I was finally able to contact him, and he has graciously supplied the VMU development scene with his original source tree, including source code, documentation, binaries, and a rigorous history of his work. I have uploaded it here so that it may be preserved and can benefit other VMU developers in the future. 

## Building
The project has been migrated away from buildilng with Marcus Comstedt's original <a href="https://pkgsrc.se/devel/aslc86k">aslc86k</a> assembler and to the newer, <a href="https://github.com/wtetzner/waterbear">Waterbear</a> assembler, which is fully cross-platform and has several additional features. 

To build, simply cd into the cloned directory, then run:

    $ waterbear assemble src/3d.s -o Tiny3D.vms

## References
Within the <a href="https://github.com/gyrovorbis/tiny3dengine/tree/master/doc">doc</a> folder lies a wealth of useful information, used during the development of the engine. These include varoius presentations and PDFs on the math routines and integer algorithms.

## Future Work and Optimizations
Within The Rockin'-B's carefully kept notes (<a href="https://github.com/gyrovorbis/tiny3dengine/blob/master/CHANGELOG.md">CHANGELOG</a>) lies a treasure trove of information along with a list of potential and in-progress ideas for various performance optimizations which could still be implemented.

## ROMs
The binary ROM images are available for download and can be used with any VMU emulator or loaded onto the actual device, using something such as DreamShell or VMU Explorer.
* <a href="https://github.com/gyrovorbis/tiny3dengine/raw/master/rom/3D.VMI">3D.VMI</a> (Web Browser Info Format)
* <a href="https://github.com/gyrovorbis/tiny3dengine/raw/master/rom/3D.VMS">3D.VMS</a> (Web Browser File Format)
* <a href="https://github.com/gyrovorbis/tiny3dengine/raw/master/rom/3D.DCI">3D.DCI</a> (Nexus Memory Card Format)
