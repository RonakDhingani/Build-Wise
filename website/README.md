# Build Wise — Marketing & Support Website

Static site for the **Build Wise** app: landing page + Google Play support
pages (Privacy Policy, Terms & Conditions, Contact). Pure HTML/CSS/vanilla JS,
no framework, no backend. GitHub Pages compatible.

## Files

```
website/
├── index.html                  # Home / landing
├── privacy-policy.html         # Privacy Policy (Play Store URL)
├── terms-and-conditions.html   # Terms & Conditions (Play Store URL)
├── contact.html                # Contact + mailto form
├── css/style.css               # All styles
├── js/main.js                  # Nav, FAQ, reveal, form
├── robots.txt                  # SEO crawl
├── sitemap.xml                 # SEO sitemap
├── WEBSITE_STRUCTURE.md / CONTENT_PLAN.md / SEO_PLAN.md
└── README.md
```

## Deploy on GitHub Pages

1. Push this `website/` content to a repo (or its own repo root).
2. Repo **Settings → Pages** → deploy from branch. If serving from a subfolder,
   point Pages at `/website` (or move files to repo root / a `docs/` folder).
3. Pages gives you a URL like `https://USER.github.io/REPO/`.

## Before going live (TODO)

- **Google Play link:** replace `href="#"` on the "Download on Google Play"
  buttons (in `index.html`) with your real Play Store listing URL.
- **Domain:** replace `https://YOUR-DOMAIN-HERE/` in `robots.txt` and
  `sitemap.xml`, and the `og:url` / canonical values, with your live URL.
- **Support email:** currently `support.ronaklabs@gmail.com` (in pages + `js/main.js`
  `SUPPORT_EMAIL`). Change if different.
- **Screenshots:** the gallery uses CSS phone mockups as placeholders. Drop real
  PNGs into an `assets/` folder and swap the `.phone` blocks for `<img>` tags.
- **OG image:** add `assets/og-image.png` (1200×630) for nicer social previews.

## Play Store support URLs

- Privacy Policy: `<base>/privacy-policy.html`
- Terms: `<base>/terms-and-conditions.html`
- Contact / Support: `<base>/contact.html`

## Theme

Primary `#1E4E8C` · Accent `#F59E0B` · Background `#F8F9FC` · Cards `#FFFFFF`.
All tokens live at the top of `css/style.css` (`:root`).
