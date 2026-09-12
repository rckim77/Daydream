---
name: swiftui-ui-patterns
description: Find component-specific SwiftUI examples for navigation, sheets, lists, search, controls, and screen composition.
---

# SwiftUI component patterns

Inspect a nearby implementation and follow `AGENTS.md` ownership/composition rules. Use `references/components-index.md` to select the relevant component reference; do not load the entire catalog.

For app wiring, read `references/app-wiring.md`. Treat scaffolding as an example, preserving the existing app lifecycle and navigation unless a change is requested.

For selection-driven sheets, `references/sheets.md` covers item-based presentation. Choose action and dismissal ownership to suit the existing flow rather than forcing every sheet to own persistence.

Build and inspect the affected interaction. Add new reference entries to `references/components-index.md` only when they provide reusable guidance, with paths that exist in this repository.
