---
title: Adding custom languages / regions to Sitecore
date: 2013-07-15
---

Often times, with multi-lingual sites, a company's region is not based on geographic regions. Usually these are based on sales territories and we often find ourselves
defining regions as "English - Southeast Asia" that need their own special languages. Sitecore builds regions off Windows' list of cultures, to add a new region within
Sitecore we first need to add a region to Windows. Alex Shyba provides a great <a href="http://marketplace.sitecore.net/en/Modules/Custom_Language_Registration.aspx">Custom Language Registration</a>
utility, that does the job. Unfortunately, this adds a manual step into my wonderful one-click deployment process. Anything manual adds error, so let's do the following:

- Before App_Start, check if the language or region exists on the current environment
- If not, add the region

Arguably this should be part of a build process, but I found doing this in Powershell more cumbersome than simply writing C# code. The process, however, is the same. Let's use 
<a href="https://github.com/davidebbo/WebActivator">WebActivator</a> to create a method that starts before the application spins up to do this:

```csharp
[assembly: WebActivatorEx.PreApplicationStartMethod(typeof(MyProject.Web.App_Start.RegisterLanguages), "Register")]
namespace MyProject.Web.App_Start
{
    public class RegisterLanguages
    {
        public static void Register()
        {
            if (IsCultureExist("en-SEA")) return;

            var cib = new CultureAndRegionInfoBuilder("en-SEA", CultureAndRegionModifiers.None);
            cib.LoadDataFromCultureInfo(new CultureInfo("en-US"));
            cib.LoadDataFromRegionInfo(new RegionInfo("en-US"));
            cib.CultureEnglishName = "English (Southeast Asia)";
            cib.CultureNativeName = "English (Southeast Asia)";
            cib.RegionEnglishName = "English (Southeast Asia)";
            cib.RegionNativeName = "English (Southeast Asia)";
            cib.Register();
        }    
```

That's it! Make sure Include\LanguageDefinitions.config is updated to include the new region. This also requires the AppPool user has access to the "C:\Windows\Globalization" directory
as Windows writes the custom culture files here.