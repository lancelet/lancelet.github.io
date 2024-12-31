+++
title = "A New Blog"
date = "2024-12-31"
description = """
  First Light! I'm launching a new blog for my eclectic collection of
  interests. Read about how I set it all up.
"""
authors = ["Jonathan Merritt"]
extra.summary_image = "cat-plans.jpg"
taxonomies.tags = ["blog", "web"]
+++

Welcome to my new blog! This is where I'll collect my random thoughts on
various topics for the world.

To create this blog, here's what I used:
- [Zola](https://www.getzola.org) provided site generation.
- HTML templates and CSS styles I created from scratch.
- [Sass](https://sass-lang.com/) (the SCSS dialect) provided CSS wrangling.
- [Cloudflare](https://www.cloudflare.com/) provided the domain name and
  hosting.
  
I was keen to explore creating my own CSS styles for the site. I haven't
necessarily finished them, but I'm happy with what I have for now.
  
## Responsive Layout

A responsive layout was important to me, since I'd like the site to be legible
on web browsers of multiple sizes. This is mostly done using [@media
queries](https://developer.mozilla.org/en-US/docs/Web/CSS/CSS_media_queries/Using_media_queries),
but the hiding and showing of the pop-over menu is done using JavaScript.

This is the normal web version of the site, in which I chose to use a header
with buttons:

{% blogfig(imgs='responsive-layout-ipad.png') %}
Web version of the site, with a regular button menu.
{% end %}

The phone version of the site switches to a hamburger menu (shown on the left)
with a pop-over menu (shown on the right).

{% blogfig(imgs='responsive-layout-iphone.png;responsive-layout-iphone-menu.png') %}
iPhone version of the site, with a hamburger menu.
{% end %}

Something that took me a while to figure out was why my site was scaling
strangely on an iPhone. It turned out that I needed this magic incantation:

```html
<meta
  name="viewport"
  content="width=device-width, initial-scale=1.0">
```

Setting `width=device-width` requests that mobile browsers [use the actual
width](https://developer.mozilla.org/en-US/docs/Web/CSS/Viewport_concepts#mobile_viewports)
of the mobile device, and not a "virtual width", which many do by default.

