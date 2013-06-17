---
layout: post
Sassy Sitecore
---

I normally do not have a lot of input in front-end development but noticed
a lot of UI developers believe I would know the position of a Sitecore module
on a page. Let's say I had a series of advertisement blocks on a page, in Page
Editor, the content author can add as many or as little as he or she wanted. My
rendering or sublayout doesn't create a list of advertisement blocks, it just invokes
a method per block and let's Sitecore manage the list.

I don't have a loop I can access and add a "first" class to a dom element, but there
are work arounds. In the above example I could look at the renderings, and if the id of the first
renderings matching the placeholder I'm in is the one I'm on, then I can add a first class.

That's possible but feels like the front-end can take care of it more gracefully. I can add some
jQuery to determine the first element and add a class, but it really feels that those presentation
details are better kept in CSS, even if it requires using some sort of CSS pre-processing tool such
as SASS.