---
name: swift-concurrency
description: Diagnose or change Swift task lifetimes, actor isolation, Sendable boundaries, and concurrency migrations.
---

# Swift concurrency

Inspect the active Swift language mode, isolation, strict-concurrency settings, and relevant upcoming features before interpreting diagnostics. Use resolved build settings when project values are absent; ask only if a consequential uncertainty cannot be resolved locally.

Identify the isolation boundary and the lifetime of the async operation. Preserve cancellation and UI ownership. Avoid blanket `@MainActor` or `Task.detached` fixes. For `@preconcurrency`, `@unchecked Sendable`, or `nonisolated(unsafe)`, document the concrete safety invariant and remaining limitation; this guidance does not authorize creating external tickets.

Read the relevant references as needed:
- Async operations and task cancellation: `references/async-await-basics.md`, `references/tasks.md`.
- Isolation and value transfer: `references/actors.md`, `references/sendable.md`, `references/threading.md`.
- Retention and streams: `references/memory-management.md`, `references/async-sequences.md`.
- Migration or legacy persistence: `references/migration.md`, `references/core-data.md`.
- Diagnostics and verification: `references/linting.md`, `references/testing.md`, `references/performance.md`.
- Terminology: `references/glossary.md`.

Use current Apple SDK guidance for toolchain-specific behavior. Make the smallest correction that addresses the boundary, then test the affected cancellation, ordering, or lifetime behavior. Do not add dummy awaits to silence warnings or infer execution threads solely from async syntax.
