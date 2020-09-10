# PluginVal CMake Integration

This repository is going to contain the integration of [pluginval](https://github.com/Tracktion/pluginval) via [CMake](https://cmake.org/).

## Documentation

### pluginval_display_version

Displays the version of pluginval installed on the computer.

### pluginval_minimum_required

Specifies the version or the range of versions desired for pluginval.

_Usage:_ `pluginval_minimum_required(VERSION <min>[...<max>] [FATAL_ERROR])` similar to [cmake_minimum_required](https://cmake.org/cmake/help/latest/command/cmake_minimum_required.html)

## Todo

- [X] Check the pluginval version installed (something like [cmake_minimum_required](https://cmake.org/cmake/help/latest/command/cmake_minimum_required.html))
- [ ] Download/Install a specific version of pluginval (chocolatey on Windows, ??? on mac, ??? on linux)
- [ ] Run pluginval on a VST
- [ ] Run pluginval on a VST3
- [ ] Run pluginval on a AU
- [ ] Adds the ability to pass custom flags to pluginval
