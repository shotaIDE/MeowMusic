fastlane documentation
----

# Installation

Make sure you have the latest version of the Xcode command line tools installed:

```sh
xcode-select --install
```

For _fastlane_ installation instructions, see [Installing _fastlane_](https://docs.fastlane.tools/#installing-fastlane)

# Available Actions

### generate

```sh
[bundle exec] fastlane generate
```

Generate automatic codes

----


## Android

### android build_dev

```sh
[bundle exec] fastlane android build_dev
```

Build develop app

### android build_prod

```sh
[bundle exec] fastlane android build_prod
```

Build production app

### android deploy_dev

```sh
[bundle exec] fastlane android deploy_dev
```

Deploy develop app to Firebase App Distribution

----


## iOS

### ios build_dev

```sh
[bundle exec] fastlane ios build_dev
```

Build develop app

### ios deploy_dev

```sh
[bundle exec] fastlane ios deploy_dev
```

Deploy develop app to Firebase App Distribution

### ios deploy_prod

```sh
[bundle exec] fastlane ios deploy_prod
```

Deploy production app to App Store Connect

----

This README.md is auto-generated and will be re-generated every time [_fastlane_](https://fastlane.tools) is run.

More information about _fastlane_ can be found on [fastlane.tools](https://fastlane.tools).

The documentation of _fastlane_ can be found on [docs.fastlane.tools](https://docs.fastlane.tools).
