# Build Wise — SEO Plan

## Primary keywords
- construction budget app
- construction project manager app
- offline construction expense tracker
- building budget tracker
- contractor expense app
- home construction budget manager

## Long-tail
- track construction expenses offline
- construction material tracking app
- backup and restore construction projects
- budget vs spent construction app

## Per-page metadata

### index.html
- **Title:** Build Wise — Smart Construction Budget & Project Manager
- **Description:** Manage construction budgets, expenses, materials, stages, and
  progress photos in one offline-first app. No account, no cloud — your data
  stays on your device.

### privacy-policy.html
- **Title:** Privacy Policy — Build Wise
- **Description:** How Build Wise handles your data: stored locally on your
  device, no unnecessary personal data collected, no cloud upload.

### terms-and-conditions.html
- **Title:** Terms & Conditions — Build Wise
- **Description:** The terms governing your use of the Build Wise construction
  budget and project management app.

### contact.html
- **Title:** Contact Us — Build Wise
- **Description:** Get support, request features, or report bugs for the Build
  Wise construction budget app.

## On-page SEO checklist
- One `<h1>` per page; logical `h2`/`h3` hierarchy.
- Descriptive `<title>` + `<meta name="description">` per page.
- Canonical `<link rel="canonical">` per page.
- Open Graph + Twitter Card tags (title, description, type, url, image).
- `meta name="theme-color"` = #1E4E8C.
- Semantic HTML5 landmarks; `alt` text on all imagery.
- Descriptive link text (no "click here").
- Fast: single CSS file, single JS file, system + inline SVG, no blocking libs.
- `lang="en"` on `<html>`; responsive `viewport` meta.

## Structured data (JSON-LD on index.html)
- `SoftwareApplication` schema: name, category (BusinessApplication),
  operatingSystem (Android), offers (free), description.
- `FAQPage` schema mirroring the on-page FAQ.

## Crawlability
- `robots.txt` allows all; reference `sitemap.xml`.
- `sitemap.xml` lists all four pages.
- Clean relative URLs so it works under any GitHub Pages base path.

## Performance targets
- Lighthouse ≥ 95 across Performance / SEO / Best Practices / Accessibility.
- No render-blocking third-party requests.
- `font-display: swap` if web fonts added (system stack used by default).
