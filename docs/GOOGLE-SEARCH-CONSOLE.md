# Google Search Console setup for MI Linux

This file is the manual submission checklist for getting MI Linux indexed in Google. The site-side work is already in place; Google account verification still has to be completed in Robert's Google Search Console account.

## URLs to add

Preferred property:

```text
https://mi-linux.mannindustries.org/
```

Also submit/request indexing for the Mann Industries path:

```text
https://mannindustries.org/mi-linux/
```

## Sitemap to submit

```text
https://mi-linux.mannindustries.org/sitemap.xml
```

The sitemap currently includes:

- `https://mi-linux.mannindustries.org/`
- `https://mi-linux.mannindustries.org/download.html`
- `https://mi-linux.mannindustries.org/tour.html`
- `https://mi-linux.mannindustries.org/install.html`
- `https://mi-linux.mannindustries.org/known-issues.html`
- `https://mannindustries.org/mi-linux/`

## Manual steps

1. Open Google Search Console: `https://search.google.com/search-console/`.
2. Add a URL-prefix property for `https://mi-linux.mannindustries.org/`.
3. Choose HTML file or DNS verification.
4. If Google gives an HTML verification file, place that exact file in `website/` and deploy it to `/opt/manncloud/sites/mi-linux/`.
5. If Google gives a DNS TXT record, add it at the DNS provider and wait for propagation.
6. After verification, open Sitemaps and submit `https://mi-linux.mannindustries.org/sitemap.xml`.
7. Use URL Inspection and request indexing for:
   - `https://mi-linux.mannindustries.org/`
   - `https://mannindustries.org/mi-linux/`
   - `https://mi-linux.mannindustries.org/download.html`
8. Check back after Google crawls the site.

## Notes

- Google sitemap ping endpoints are deprecated, so Search Console submission is the correct free path.
- Keep the wording focused on realistic searches first, such as `MI Linux`, `Mann Industries Linux`, and `MI Linux Founder Preview`.
