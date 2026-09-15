---
name: app-store-changelog
description: Draft App Store release notes from git history over a requested tag or commit range.
---

# App Store changelog

From the repository root, run `.agents/skills/app-store-changelog/scripts/collect_release_changes.sh [base-ref] [head-ref]`. Without a base it uses the latest tag, or full history when no tag exists; inspect that range before drafting.

Read `references/release-notes-guidelines.md` for storefront wording when needed. Include only verified user-visible changes and combine overlapping commits. Internal dependency, CI, and instruction edits do not warrant release-note claims on their own.

Use the user's requested format and length; otherwise use concise benefit-focused bullets proportional to the actual changes. Each claim must map to inspected code or commits. Omit uncertain claims or investigate them, asking only when the unresolved detail changes the requested result. Drafting notes does not authorize publishing them.
