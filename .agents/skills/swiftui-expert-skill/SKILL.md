---
name: swiftui-expert-skill
description: Implement or review SwiftUI state ownership, view identity, performance, and animations for a specific feature or defect.
---

# SwiftUI feature guidance

Start from the affected view and its state owner. Preserve the project's composition and Observation conventions in `AGENTS.md`; reference examples do not mandate architectural rewrites or unrelated API replacements. Adopt new Liquid Glass styling only when requested.

Read only references relevant to the task:
- State ownership and bindings: `references/state-management.md`.
- Composition and layout: `references/view-structure.md`, `references/layout-best-practices.md`.
- Update cost and collection identity: `references/performance-patterns.md`, `references/list-patterns.md`.
- Navigation and sheets: `references/sheet-navigation-patterns.md`.
- Scrolling: `references/scroll-patterns.md`.
- Animations: `references/animation-basics.md`, then `references/animation-transitions.md` or `references/animation-advanced.md` as needed.
- Text, images, and API alternatives: `references/text-formatting.md`, `references/image-optimization.md`, `references/modern-apis.md`.
- Glass: `references/liquid-glass.md`.

For SDK-specific behavior, prefer installed Apple guidance and verify API availability against the project's deployment target. An alternative API in a reference is not necessarily a deprecation. Validate the affected interaction and state transitions; compilation alone does not establish visual correctness.
