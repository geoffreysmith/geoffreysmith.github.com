---
title: Sitecore content item organization and integration testing
date: 2013-07-19
---

I've tried a new approach to organizing templates and content with Sitecore for my latest project and really like the lack of collision with third party
modules and Sitecore's standard templates. It is simple, but surprisingly effective in keeping different types of content separate. I completely stole this 
from an open source Sitecore project and I cannot remember the name, unfortunately, so proper attribution will have to wait. This organization also lead me to 
a unique form of integration testing, which I'll explain towards the end:

1. Templates

For templates I've eschewed the "User Defined" section as I find some third party modules like to write in this directory. Instead, I broke them up into three
separate components under "sitecore\templates\(project name)\":

1. Base Templates, from which all other templates derive, no content item will be based on these templates and no icon is needed.
2. Data Templates, for items such as renderings, metadata and content items that are not pages
3. Presentation Templates, for items that will be pages

2. Renderings and Media Library

I've also broke up renderings and the media library in a similar manner, using the project's name to create a root folder. If we ever have the need for a multi-tenant
site, we won't have to spend time separating content out, it is already separate for us. This also makes differentiating items created by us and items created by third party
modules easier.

3. Content

While leaving "/sitecore/content/Home" I've created the following directories under the content node following <a href="http://corecompetency.tohams.com/">Thomas Lin's</a> suggestion:

1. Metadata, similar to "Data Templates" items like Google Analytics codes and application logic (e.g., a listing of states)
2. Navigation, used to build the navigation elements out if we're not using the content items themselves to build the navigation
3. Components, rendering items created in the Page Editor

This is all very simple, but provides just enough organization to really make the difference on larger projects. It does lead to several interesting scenarios since we know, especially
for templates, renderings and placeholders, that the items in a certain folder <i>must</i> have been created with our project: we can run automated tests to ensure Sitecore best practices
are followed. That, for example, all presentation and data templates have icons, standard values and insert options set. Or, that no base templates are used in the content tree without being
inherited by another template, and all templates are actually being used (and if not, delete them). Here's an example I threw in my integration test project:

```csharp
            _fields = new List<Template>();
			
            var defaultTemplate = TemplateManager.GetTemplate("{1930BBEB-7805-471A-A3BE-4858AC7CF696}", _db);

            var item = _db.GetItem("/sitecore/templates/MyProject/Base Templates/");
			
            var templateItems = item.Axes.SelectItems("descendant::*[@@TemplateName='Template']");

            foreach (TemplateItem templateItem in templateItems)
            {
                _fields.AddRange(from template in templateItem.BaseTemplates
                                 from field in template.Fields.Where(x => !defaultTemplate.ContainsField(x.ID))
                                 select new Template
                                     {
                                         Type = type,
                                         Field = field.Name,
                                         InheritedFrom = template.Name,
                                         StandardValue = template.StandardValues.Fields[field.Name].Value,
                                         TemplateName = templateItem.Name,
                                         Section = field.Section.Name,
                                         Id = field.ID
                                     });

                foreach (var field in templateItem.OwnFields)
                {
                    _fields.Add(new Template
                        {
                            Type = type,
                            Field = field.Name,
                            InheritedFrom = string.Empty,
                            StandardValue = templateItem.StandardValues == null
                                                ? ""
                                                : templateItem.StandardValues.Fields[field.Name].Value,
                            TemplateName = templateItem.Name,
                            Section = field.Section.Name,
                            Id = field.ID
                        });
                }
            }
			
			
		 private class Template
        {
            public string Type { get; set; }
            public string TemplateName { get; set; }
            public string InheritedFrom { get; set; }
            public string Field { get; set; }
            public string StandardValue { get; set; }
            public string Section { get; set; }
            public ID Id { get; set; }
        }
```

Note that "Template" is not a Sitecore template but a stub class I created to ease testing. What I've done is load all the templates
into my custom list, with just the properties I need. I can then run a variety of checks and tests without having to deal with Sitecore's
cumbersome classes.

It also makes documentation easy, all I have to do is feed the list through a CsvWriter:

```csharp
            using (var csv = new CsvWriter(new StreamWriter("_Templates.csv")))
                csv.WriteRecords(_fields);
```