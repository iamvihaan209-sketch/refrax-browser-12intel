# Rift Browser — Monterey Intel compatibility port

This fork explores a native browser build for Intel Macs running macOS 12 Monterey.

## Monterey build

The upstream Refrax application targets macOS 26 and uses APIs that Monterey does not provide, including SwiftData and the Observation framework. Lowering `MACOSX_DEPLOYMENT_TARGET` does not backport those frameworks. To avoid pretending the full upstream application can run just by changing a version number, this branch adds an independent compatibility app in `MontereyBrowser/`.

The current compatibility app is **Rift Browser**, a small native AppKit + WebKit baseline that can be built for x86_64 with a macOS 12.0 minimum. It currently includes:

- Native WebKit page rendering
- Address/search field, back, forward, reload, and home controls
- Multiple tabs
- Local bookmarks and a capped browsing history list
- GitHub Actions packaging of an Intel `.app` bundle

The build workflow uploads `rift-browser-macos12-intel` as an Actions artifact when compilation succeeds. The workflow checks the executable architecture and app metadata; it does not claim that a build succeeded until the Actions run is green.

## Upstream project

The original Refrax source remains in `Refrax/` and is based on a newer macOS architecture. Full feature parity is not yet implemented in the Monterey compatibility app; porting the entire upstream codebase would require replacing SwiftData persistence and migrating Observation-driven state, plus auditing newer SwiftUI and WebKit APIs.

Upstream project: https://github.com/kageroumado/refrax-browser

This fork uses a distinct name in line with the upstream trademark policy for redistributed forks. The source is GPL-3.0; see the upstream license and trademark policy before redistributing.
