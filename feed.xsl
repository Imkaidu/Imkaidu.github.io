<?xml version="1.0" encoding="utf-8"?>
<!-- Renders /feed.xml as a readable page when someone opens it in a browser.
     Feed readers ignore this stylesheet and read the Atom XML directly.
     Linked from feed.xml by script/build-index.py; hand-written, not generated.
     Colours come from /css/custom.css, so the page follows the site theme;
     a browser without XSLT support simply shows the raw XML. -->
<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:atom="http://www.w3.org/2005/Atom"
                exclude-result-prefixes="atom">
  <xsl:output method="html" encoding="utf-8" indent="yes"
              doctype-system="about:legacy-compat"/>

  <xsl:template match="/atom:feed">
    <html class="no-js" lang="en">
      <head>
        <meta charset="utf-8"/>
        <meta name="viewport" content="width=device-width, initial-scale=1.0, user-scalable=yes"/>
        <meta name="color-scheme" content="light dark"/>
        <meta name="robots" content="noindex"/>
        <script src="/js/theme.js"></script>
        <title><xsl:value-of select="atom:title"/> (feed)</title>
        <link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=Roboto:ital,wght@0,400;0,700;1,400;1,700&amp;family=Roboto+Mono:wght@400;700&amp;display=swap"/>
        <link rel="stylesheet" href="/css/custom.css"/>
      </head>
      <body>
        <a class="skip-link" href="#main">Skip to content</a>
        <nav aria-label="Main">
          <div id="nav">
            <h3 class="gray"><a href="/index.html">Kai Du</a></h3>
            <div class="nav-buttons">
              <a href="/index.html">Home</a>
              <a href="/blog/blog.html">Blog</a>
              <a href="https://github.com/ImKaiDu">GitHub</a>
              <select id="theme-select" aria-label="Colour theme">
                <option value="auto">Auto</option>
                <option value="light">Light</option>
                <option value="dark">Dark</option>
              </select>
            </div>
          </div>
        </nav>
        <main id="main">
          <header id="title-block-header">
            <h1 class="title"><xsl:value-of select="atom:title"/></h1>
            <p class="note">This is an Atom feed. To get new posts as they appear,
              copy this page's address into a feed reader such as Feedly, Inoreader
              or NetNewsWire.</p>
          </header>
          <ul>
            <xsl:for-each select="atom:entry">
              <li>
                <p>
                  <code><xsl:value-of select="substring(atom:published, 1, 10)"/></code>
                  <xsl:text> </xsl:text>
                  <a href="{atom:link/@href}"><xsl:value-of select="atom:title"/></a>
                </p>
                <xsl:if test="atom:summary">
                  <p><xsl:value-of select="atom:summary"/></p>
                </xsl:if>
              </li>
            </xsl:for-each>
          </ul>
        </main>
        <footer>
          <p><a href="mailto:mail@imkaidu.net">mail@imkaidu.net</a> &#183; <a href="/blog/blog.html">Blog</a> &#183; <a href="https://github.com/ImKaiDu">GitHub</a></p>
        </footer>
      </body>
    </html>
  </xsl:template>
</xsl:stylesheet>
