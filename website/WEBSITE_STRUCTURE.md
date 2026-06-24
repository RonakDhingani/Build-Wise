# Build Wise — Website Structure

Static marketing + Play Store support site for the **Build Wise** Flutter app.
Pure HTML/CSS/vanilla JS. No framework, no backend. GitHub Pages compatible.

## Folder layout

```
website/
├── index.html                  # Home / landing
├── privacy-policy.html         # Privacy Policy (Play Store compliant)
├── terms-and-conditions.html   # Terms & Conditions
├── contact.html                # Contact + support form (mailto, no backend)
├── css/
│   └── style.css               # All styles (CSS variables, responsive)
├── js/
│   └── main.js                 # Nav toggle, FAQ accordion, form, scroll FX
├── WEBSITE_STRUCTURE.md
├── CONTENT_PLAN.md
└── SEO_PLAN.md
```

> Logo is an inline SVG (no image asset needed). Screenshot gallery uses CSS
> phone mockups with labelled placeholders — drop real PNGs in later.

## Pages & sections

### 1. index.html (Home)
1. **Header / Nav** — logo, links (Features, Screenshots, FAQ, Contact), Google Play CTA. Mobile hamburger.
2. **Hero** — logo, app name, tagline, short description, two buttons (Download on Google Play, Contact Us).
3. **Features** — 9 cards (Project Management, Expense Tracking, Material Management, Budget Monitoring, Progress Photos, Construction Stages, Reports & Analytics, Import & Export Backup, Offline First).
4. **Screenshots** — responsive gallery, 6 phone mockups.
5. **Why Build Wise** — 6 value points (easy, offline-first, for homeowners, budget tracking, progress monitoring, no account).
6. **FAQ** — accordion, 5+ questions.
7. **CTA band** — final download nudge.
8. **Footer** — Privacy, Terms, Contact, copyright, app version.

### 2. privacy-policy.html
Legal page shell (header + footer reused). Sections: intro, data we collect (none unnecessary), local storage, photos, import/export, permissions, third parties, children, changes, contact.

### 3. terms-and-conditions.html
Legal shell. Sections: acceptance, license, user responsibilities, data ownership, backup responsibility, acceptable use, disclaimer, limitation of liability, changes, contact.

### 4. contact.html
Header + footer reused. Support email, feature-request + bug-report cards, contact form (name/email/subject/message) that builds a `mailto:` — no server.

## Shared components (copied markup, single CSS)
- `.site-header` sticky nav + mobile drawer
- `.site-footer`
- `.btn` / `.btn-primary` / `.btn-outline` / `.btn-ghost`
- `.card`, `.section`, `.container`
- `.legal` typography wrapper for policy/terms

## Responsive breakpoints
- Mobile-first base
- `≥ 640px` small tablets (2-col features)
- `≥ 960px` desktop (3-col features, row hero, full nav)

## Accessibility
- Semantic landmarks (`header`, `nav`, `main`, `section`, `footer`)
- `aria-expanded` on hamburger + FAQ
- Focus-visible styles, color-contrast safe, `prefers-reduced-motion` respected.
