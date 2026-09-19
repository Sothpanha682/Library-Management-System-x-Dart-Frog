# Figma Design System & UX/UI Specification

This document details the Figma design tokens, component library, and interaction specifications implemented in the Flutter Mobile Application.

---

## 1. Color Palette

The color scheme evokes academic prestige, trust, and clarity, adhering strictly to **Material 3**:

| Token | Hex Value | Role in Application |
|---|---|---|
| `Primary / Royal Navy` | `#1E3A8A` | Main branding, primary CTAs, active navigation indicators |
| `Secondary / Scholarly Teal` | `#0D9488` | Returned status badges, accent actions |
| `Accent / Amber Gold` | `#D97706` | Administrator badges, holds/reservations, highlights |
| `Background / Canvas` | `#F8FAFC` | Main screen background, reduces eye strain |
| `Surface / Card` | `#FFFFFF` | Elevated cards, dialog surfaces, sheet containers |
| `Text / Slate 900` | `#0F172A` | Primary headings, titles, high contrast copy |
| `Text / Slate 500` | `#64748B` | Subheadings, authors, metadata, captions |
| `Status / Success Green` | `#16A34A` | Available status, success snackbars, confirmation |
| `Status / Error Red` | `#DC2626` | Overdue flags, destructive actions, validation alerts |

---

## 2. Typography Scale

Clean sans-serif typography using standard Android and iOS system font hierarchy:

- **Display Title**: 24sp / SemiBold (800) / Tracking +0.5 / Slate 900
- **Screen Title / App Bar**: 20sp / Bold (700) / Slate 900
- **Section Heading**: 16sp / Bold (700) / Slate 900
- **Book Card Title**: 15sp / Bold (700) / Height 1.25 / Slate 900
- **Body Regular**: 14sp / Regular (400) / Slate 900
- **Subhead / Metadata**: 13sp / Medium (500) / Slate 500
- **Pills & Badges**: 11sp / Bold (700) / LetterSpacing 0.5
- **Footnotes & Captions**: 10sp / Regular (400) / Slate 400

---

## 3. Spacing Grid (8.dp System)

- **Micro (4.dp)**: Icon-to-text spacing within badges and chips.
- **Small (8.dp)**: Spacing between title and subtitle; padding between horizontal category chips.
- **Medium (16.dp)**: Screen content margins; card inner padding; form field vertical gaps.
- **Large (24.dp)**: Section breaks; dialog inner padding.
- **X-Large (32.dp)**: Welcome banner vertical spacing; empty state padding.

---

## 4. UI Components Specification

### A. Book Card
- **Dimensions**: Full width with 16dp horizontal margins.
- **Border Radius**: 16dp.
- **Thumbnail**: 76dp width x 110dp height with 10dp radius. Displays cover image or fallback scholarly icon.
- **Details**: Category chip (Slate 700 on Slate 50), 2-line title clamp, author, available quantity counter, status pill.

### B. Status Badges
- **Shape**: Pill container with 20dp border radius.
- **Border**: 1px matching status color with 30% opacity.
- **Background**: Matching status color with 10% opacity.
- **Icon**: 14dp matching icon (e.g. checkmark, book, warning hourglass).

### C. Buttons
- **Primary CTA**: 50dp height, 12dp border radius, flat surface with bold font.
- **Secondary Outlined**: 50dp height, 12dp border radius, 1.5px primary border.
- **Interactive Targets**: Minimum 48dp x 48dp to satisfy WCAG AA accessibility.
