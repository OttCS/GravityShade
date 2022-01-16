# GravityShade Changelog

## DEV Edition

WIP

## Version 22.1.16

### Major Changes

Emissive Nether Ores have been added, similar to standard overworld emissive ores.

Performance optimized fixed shadows: Shadows don't move throughout the day and are based on the skylight value. INCREDIBLE performance in skylit dimensions, almost 0 impact.

Spider, Enderman, and Magma Cube eyes are now emissive.

Water has "foam" as part of the normal bumping process.

Metallic Reflections are implemented: chest latches and rail (metallic parts?) are reflective.

Adaptive normal bumping for better performance on higher render distances.

A custom tonemapping function has been implemented, called the FilmicLum ToneMap. Curves based on true luminosity instead of linear RGB values, and desaturates the more intense of a curve is used (typically reflects how human vision is almost black and hite in very low light).

### Minor Changes

Rain's performance impact on overworld skylighting has been reduced.

Blocklight color has been changed to slightly more neutral, still warm.

Added support for the blindness effect, just makes the fog start at the player and be completely opaque 16 blocks from the player. (Support in advance for the deep dark update!)

### Bug Fixes

Error found and fixed that caused a fatal error when entering non-overworld dimensions.

Fixed lightning entityID check so that it is emissive instead of being recolored.

Tonemapping bug fixed where required functions could be unavailable.

## Version 21.12.20

### Major Changes

Underwater fog! Not perfect at the moment, but completely usable. Known bug is that the sky isn't fogged underwater, which leads to some weird visuals.

Dynamic Handlights! Dynamic handlights have been added, but as a result the original method of block lighting has changed. I'm working on getting blocklighting to where it was and keeping handlighting.

Fog fixed for almost any render distance, from 4 to 32 chunks.

### Minor Changes
Horizon fog-band bug fixed. An alpha-blending issue on water led to a very visible line where water was fog-occluded, opacity is not smoothly transitioned between on water.

Better sky is in progress.

Separate reflections for "metallic part" blocks (ie chests and rails) are also in progress.

## Version 21.12.16

### Major Changes
FOG HAS BEEN ADDED! While slightly buggy at the moment, optimizations ARE in place to reduce work done on fog-occluded textures.

Shadowmapping has been reduced. Shadowmap scale is now set to 1024 at a distance of 4 chunks, which more machines are capable of handling.

### Minor Fixes
Fog color set to match the time of day and the horizon color.

Sunset lighting has been adjusted to be a less purple, more coral hue.

Emissive ores now have separate block IDs to allow for better a emissive effect.

## Version 21.12.14
Code is now loosely based on the Sildurs Enhanced Default shaderpack.

Lighting now has proper coloring.

Overworld sky light changes realistically based on the time of day.

Block light has been changed to be warmer, but blend better with the environment.

End lighting has been changed to a less-greenish tone.

Feel free to change these values inside the shaderpack.

Emissive blocks get tonemapped separately for better visual effect.

Calmer and nicer-looking water has been added.

Emissive Ores have been added, inspired by Complementary Shaders.

Shadowmapping has been added, see note below regarding the resolution.

NOTE: Default shadowmap resolution is 2048. This is generally attainable with medium graphics cards, but do feel free to change this value or disable shadows in the settings file.