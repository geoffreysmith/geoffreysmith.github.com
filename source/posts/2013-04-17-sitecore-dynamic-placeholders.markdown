---
title: Sitecore 6.6 MVC and Dynamic Placeholders
date: 2013-04-17
---

Sitecore's template processing is great and flexible, but has some severe limitations out of the box. The most 
glaring of these is the inability for Sitecore to handle certain types of complex content types. For example,
nearly every site I've encountered hash a tabbed FAQ section. This would entail adding a "tab" placeholder to a page
and allow Page Editor to add a rendering or sublayout to this section. This works great, except tabbed content presupposes
different content per tab. For example, we might have the following tabs:

- Offices in North America
- Offices in South America

In Sitecore I want the content author to add any number of regions if the need arises, either different contintents 
or arbitrary regions (Offices on the East Coast), the end result is that I do not or should not know the number of tabs.
This is fine if I want each tab to contain a very generic field such as "rich text," which is usually not possible or 
ideal. I want the user to add a tab, then add individual offices to that tab and not just in a big content block.

Out of the box, this is not possible if we do not know the number of unique tabs. The "offices" placeholder in each tab
must be unique or Sitecore's template processing will simply render the same content for every tab. It will find the "offices"
key and put any renderings with "offices" as the placeholder key in that placeholder. This will not work for our use case.

This is where I discovered <a href="http://stackoverflow.com/a/15135796/193495">Duston's </a> Stackoverflow answer
to create placeholders on the fly. The general flow is simple:

1. Define a dynamic placeholder with a friendly name,  "offices."
2. The dynamic placeholder code will take the parent datasource's GUID and and append it to the generic name
3. Any children in that rendering will be associated to that parent rendering.
4. As the placeholder id for a rendering is denormalized, there's no restrictions or validations on what a placeholder
must be, it does not have to be previously be defined in Sitecore.
5. If the parent is deleted, Sitecore retains the renderings with placeholder keys that no longer exist. They will not
show up on the page, but they'll live in the item's renderings (Presentation Details) until updated or deleted manually.

The drawbacks aren't severe, but they are contradictory to how other items exist in Sitecore. If a parent is deleted,
the children are removed and not left in an orphaned state. The code could be updated to update child renderings, or, preferably a
simple script could be run on a regular basis that deals with orphaned renderings regardless of the cause.
