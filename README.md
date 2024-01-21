# UXKit [![CI](https://github.com/ghoztsys/swift-uxkit/workflows/CI/badge.svg?branch=master)](https://github.com/ghoztsys/swift-uxkit/actions/workflows/ci.yml?query=branch%3Amain)

## Setup

```sh
# Prepare Ruby environment
$ brew install rbenv ruby-build
$ rbenv install
$ rbenv rehash
$ gem install bundler

# Install fastlane
$ bundle install
```

## Testing

> Ensure that you have installed any destinations listed in the `Fastfile`. For example, a destination such as `platform=iOS Simulator,name=iPhone 15 Pro` will require that you have installed iPhone 15 Pro simulator in Xcode.

```sh
$ bundle exec fastlane test
```

