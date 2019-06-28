## WolMo - Reactive Core iOS
[![Build Status](https://app.bitrise.io/app/0ad84576e94db94f/status.svg?token=FUdFU0dh338YPuOoKi1r5Q&branch=master)
[![Codestats](http://codestats.wolox.com.ar/organizations/wolox/projects/wolmo-reactive-core-ios/badge)](http://codestats.wolox.com.ar/organizations/wolox/projects/wolmo-reactive-core-ios/badge)
[![GitHub release](https://img.shields.io/github/release/Wolox/wolmo-reactive-core-ios.svg)](https://github.com/Wolox/wolmo-reactive-core-ios/releases)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
![Swift 4](https://img.shields.io/badge/Swift-4-orange.svg)

WolMo - Reactive Core iOS is a framework which provides extensions for easier handling on [ReactiveCocoa](https://github.com/ReactiveCocoa/ReactiveCocoa) framework in iOS, commonly used at [Wolox](http://www.wolox.com.ar/).


## Table of Contents

  * [Installation](#installation)
    * [Carthage](#carthage)
    * [Manually](#manually)
  * [Usage](#usage)
  * [Bootstrap](#bootstrap)
  * [Contributing](#contributing)
  * [About](#about)
  * [License](#license)

## Installation

### Carthage

[Carthage](https://github.com/Carthage/Carthage) is a dependency manager that builds your dependencies and provides you with binary frameworks.

You can install Carthage with Homebrew using the following command:

```
brew update
brew install carthage
```
To download wolmo-reactive-core-ios, add this to your Cartfile:
```
github "Wolox/wolmo-reactive-core-ios" ~> 1.0.0
```

### Manually
[Bootstrap](#bootstrap) the project and then drag it to your workspace.

### Usage
We have extensions which depends exclusively on ReactiveSwift components.

`WolmoReactiveCore` provides extensions for the following components:

1. [Signal](WolmoReactiveCore/Signal.swift)
2. [SignalProducer](WolmoReactiveCore/SignalProducer.swift)

to do things like: filter values, handle special Result-valued signals or producers and more.

## Bootstrap
```
git clone git@github.com:Wolox/wolmo-reactive-core-ios.git
cd wolmo-reactive-core-ios
script/bootstrap
```

## Contributing
1. Fork it
2. [Bootstrap](#bootstrap) using the forked repository (instead of `Wolox/wolmo-reactive-core-ios.git`, `your-user/wolmo-reactive-core-ios.git`)
3. Create your feature branch (`git checkout -b my-new-feature`)
4. Commit your changes (`git commit -am 'Add some feature'`)
5. Run tests (`./script/test`)
6. Push your branch (`git push origin my-new-feature`)
7. Create a new Pull Request to the original repository

## About

This project is maintained by [Wolox](http://www.wolox.com.ar).

![Wolox](https://raw.githubusercontent.com/Wolox/press-kit/master/logos/logo_banner.png)

## License
**WolMo - Reactive Core iOS** is available under the [MIT license](LICENSE.txt).

    Copyright (c) 2018 Daniela Paula Riesgo <daniela.riesgo@wolox.com.ar>

    Permission is hereby granted, free of charge, to any person obtaining a copy
    of this software and associated documentation files (the "Software"), to deal
    in the Software without restriction, including without limitation the rights
    to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
    copies of the Software, and to permit persons to whom the Software is
    furnished to do so, subject to the following conditions:

    The above copyright notice and this permission notice shall be included in
    all copies or substantial portions of the Software.

    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
    IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
    FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
    AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
    LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
    OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
    THE SOFTWARE.
