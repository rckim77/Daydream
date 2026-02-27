---
name: apple-hig-page-controls
description: "Apply Apple Human Interface Guidelines for page controls (dot indicators): when to use them, where to place them, how many pages are appropriate, and how to avoid common misuse. Use when building or reviewing paged UI in UIKit or SwiftUI."
---

# Apple HIG: Page Controls

Use this skill when designing or reviewing a dot-style page indicator in iOS.

## Source

- Primary page: https://developer.apple.com/design/human-interface-guidelines/page-controls
- Related API: https://developer.apple.com/documentation/uikit/uipagecontrol

## What A Page Control Is

- A page control communicates position within a flat set of peer pages.
- It appears as equally spaced dots, with one active dot for the current page.
- Page movement is sequential (next/previous), typically driven by swipe gestures.
- It is not for direct random access to an arbitrary page by tapping a specific dot.

## When To Use It

- Use it when pages are siblings of the same content type (for example, onboarding cards or photo pages).
- Use it when users benefit from seeing progress through a small, linear set.

## When Not To Use It

- Do not use it for hierarchical navigation.
- Do not use it when users need nonsequential jumps across many items.

## Quantity Guidance

- Keep page counts modest.
- Around 10+ dots becomes hard to scan quickly.
- Around 20+ pages becomes slow to traverse linearly.
- If page count is large, switch to a pattern that supports direct navigation (for example, grid or list).

## Placement Guidance

- Place the control centered near the bottom.
- Position it between content and the bottom edge so it remains visible without obscuring key content.
- Avoid collisions with bottom overlays (metadata chips, action buttons, toolbars, safe-area content).

## Implementation Notes

### UIKit

- Prefer system `UIPageControl`.
- Keep `numberOfPages` and `currentPage` synced with the paged content container.
- If content is scroll-driven, update the current page during paging callbacks.

### SwiftUI

- For `TabView` with `.page`, verify indicator visibility against safe area and bottom overlays.
- If overlap occurs, adjust surrounding layout first; replace the system indicator only if necessary.

## Review Checklist

- Are pages truly peers (not hierarchical)?
- Is navigation intentionally sequential?
- Is page count small enough for dot-based scanning?
- Is the indicator centered and clearly visible at the bottom?
- Does it avoid overlap with metadata/action overlays on all target devices?
- Is the active page indicator always in sync with visible content?
