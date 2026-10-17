# Refrax — macOS Monterey Intel port

This branch is for porting the **actual Refrax application** to Intel Macs running macOS 12 Monterey. It is not a replacement browser.

## Current status

The upstream app uses APIs and frameworks unavailable on Monterey, including SwiftData and the Observation framework. Lowering the deployment target alone does not make those APIs available. The port must replace them with older equivalents while preserving Refrax's existing architecture and features.

The first migration work is still in progress. The CI workflow now builds the real `Refrax.xcodeproj` / `Refrax` scheme for `x86_64` with a macOS 12 deployment target. It does not build the former standalone compatibility app.

## Compatibility plan

- Replace SwiftData persistence with a Monterey-supported persistence layer (Core Data is the primary candidate), preserving model relationships and migration behavior.
- Replace Observation macros and property wrappers with `ObservableObject`, `@Published`, and compatible SwiftUI state/environment wrappers.
- Audit SwiftUI, WebKit, AppKit, AuthenticationServices, WidgetKit, and other APIs against macOS 12 availability.
- Audit Swift package dependencies, build tools, helper processes, extensions, and bundled engines for Intel/Monterey support.
- Use the real Refrax build and tests in GitHub Actions to drive each fix; do not treat a deployment-target change or a substitute app as a completed port.

## CI artifact

When the real Refrax scheme successfully builds, Actions uploads `refrax-macos12-intel`. A successful compile is not by itself proof that every feature works on Monterey; runtime testing on macOS 12 is still required.

Upstream project: https://github.com/kageroumado/refrax-browser
