#!/usr/bin/env python3
"""Regenerate the blog index, the Atom feed and the sitemap from post front matter.

Reads the YAML front matter of every blog/posts/*.md (title, author, date,
description, updated, unlisted) and writes:

  * the list between the POSTS markers in blog/blog.md  (newest first)
  * feed.xml     (Atom, listed posts only)
  * sitemap.xml  (every public page; unlisted posts and 404 are left out)

A post with `unlisted: true` stays on the site but appears in none of the three.
Dates must be ISO 8601 (YYYY-MM-DD). Standard library only; run from anywhere:

    script/build-index.py            # rewrite the three outputs
    script/build-index.py --check    # exit 1 if any would change (no writes)
"""
import re
import sys
from pathlib import Path
from xml.sax.saxutils import escape

ROOT = Path(__file__).resolve().parent.parent
BASE = "https://imkaidu.net"
SITE_TITLE = "Kai Du"
START, END = "<!-- POSTS:START -->", "<!-- POSTS:END -->"
SKIP_NAMES = {"AGENTS.md", "CLAUDE.md", "README.md", "404.md"}
ISO = re.compile(r"^\d{4}-\d{2}-\d{2}$")


def front_matter(path):
    text = path.read_text(encoding="utf-8")
    m = re.match(r"---\n(.*?)\n---\n", text, re.S)
    if not m:
        return {}
    meta = {}
    for line in m.group(1).splitlines():
        k, sep, v = line.partition(":")
        if sep and re.match(r"^[A-Za-z_-]+$", k):
            meta[k.strip()] = v.strip().strip('"').strip("'")
    return meta


def load_posts():
    posts, problems = [], []
    for md in sorted((ROOT / "blog" / "posts").glob("*.md")):
        meta = front_matter(md)
        rel = md.relative_to(ROOT).with_suffix(".html").as_posix()
        if meta.get("unlisted", "").lower() == "true":
            continue
        date = meta.get("date", "")
        if not meta.get("title") or not ISO.match(date):
            problems.append(f"{md.name}: needs a title and an ISO date (YYYY-MM-DD), got date={date!r}")
            continue
        posts.append({
            "title": meta["title"], "date": date, "url": rel,
            "author": meta.get("author", SITE_TITLE),
            "description": meta.get("description", ""),
            "updated": meta.get("updated", date),
        })
    posts.sort(key=lambda p: (p["date"], p["title"]), reverse=True)
    return posts, problems


def index_block(posts):
    lines = [f"- `{p['date']}` [{p['title']}](posts/{Path(p['url']).name})\n" for p in posts]
    return START + "\n\n" + "\n".join(lines) + "\n" + END


def new_blog_md(posts):
    path = ROOT / "blog" / "blog.md"
    text = path.read_text(encoding="utf-8")
    if START not in text or END not in text:
        raise SystemExit(f"{path}: missing {START} / {END} markers")
    head, rest = text.split(START, 1)
    _, tail = rest.split(END, 1)
    return path, head + index_block(posts) + tail


def feed_xml(posts):
    updated = max((p["updated"] for p in posts), default="1970-01-01")
    out = ['<?xml version="1.0" encoding="utf-8"?>',
           # Renders the feed as a readable page in a browser; readers ignore it.
           '<?xml-stylesheet type="text/xsl" href="/feed.xsl"?>',
           '<feed xmlns="http://www.w3.org/2005/Atom">',
           f"  <title>{escape(SITE_TITLE)}: blog</title>",
           f'  <link href="{BASE}/blog/blog.html"/>',
           f'  <link rel="self" href="{BASE}/feed.xml"/>',
           f"  <id>{BASE}/</id>",
           f"  <updated>{updated}T00:00:00Z</updated>",
           f"  <author><name>{escape(SITE_TITLE)}</name></author>"]
    for p in posts:
        url = f"{BASE}/{p['url']}"
        out += ["  <entry>",
                f"    <title>{escape(p['title'])}</title>",
                f'    <link href="{url}"/>',
                f"    <id>{url}</id>",
                f"    <published>{p['date']}T00:00:00Z</published>",
                f"    <updated>{p['updated']}T00:00:00Z</updated>"]
        if p["description"]:
            out.append(f"    <summary>{escape(p['description'])}</summary>")
        out.append("  </entry>")
    out.append("</feed>")
    return "\n".join(out) + "\n"


def sitemap_xml(posts):
    urls = []
    for md in sorted(ROOT.rglob("*.md")):
        rel = md.relative_to(ROOT)
        if (rel.parts[0] in {"private", "node_modules"} or len(rel.parts) > 4
                or md.name in SKIP_NAMES):
            continue
        if front_matter(md).get("unlisted", "").lower() == "true":
            continue
        urls.append("/" + rel.with_suffix(".html").as_posix())
    lastmod = {f"/{p['url']}": p["updated"] for p in posts}
    out = ['<?xml version="1.0" encoding="UTF-8"?>',
           '<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">']
    for u in sorted(set(urls)):
        out.append("  <url><loc>%s%s</loc>%s</url>" % (
            BASE, escape(u), f"<lastmod>{lastmod[u]}</lastmod>" if u in lastmod else ""))
    out.append("</urlset>")
    return "\n".join(out) + "\n"


def main():
    check = "--check" in sys.argv
    posts, problems = load_posts()
    if problems:
        print("build-index: " + "\n".join(problems), file=sys.stderr)
        return 1
    blog_path, blog_text = new_blog_md(posts)
    outputs = {blog_path: blog_text,
               ROOT / "feed.xml": feed_xml(posts),
               ROOT / "sitemap.xml": sitemap_xml(posts)}
    stale = [p for p, t in outputs.items() if not p.exists() or p.read_text(encoding="utf-8") != t]
    if check:
        for p in stale:
            print(f"build-index: {p.relative_to(ROOT)} is out of date", file=sys.stderr)
        return 1 if stale else 0
    for p in stale:
        p.write_text(outputs[p], encoding="utf-8")
        print(f"build-index: wrote {p.relative_to(ROOT)}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
