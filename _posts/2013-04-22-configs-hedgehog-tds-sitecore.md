---
layout: post
Build and deployment with Sitecore and Hedgehog TDS
---

One of the harder concepts to grasps for the Sitecore developer unaquainted
to working in team's is an essential Sitecore tool, Hedgehog's 
[Team Development for Sitecore](http://www.hhogdev.com/Products/Team-Development-for-Sitecore/Overview.aspx.

TDS is best described as a migrations utility, similar to [ActiveRecord's Migrations](http://guides.rubyonrails.org/migrations.html)
or the multitude of other migrations utilities.
Sitecore's data structure, with a few caveats, is a document based database. The schema
to Sitecore's database doesn't change when we add new data types and there's no relational
constraints or hallmarks of a relational database. This is why I find calling projects
like [Customer Item Generator](https://github.com/Velir/Custom-Item-Generator) and 
[Sitecore.Glass.Mapper](https://github.com/Glass-lu/Glass.Sitecore.Mapper) an ORM. There's
no relational-object mismatch these are simply mappers to generic Sitecore objects.
an essential product for any Sitecore developer. It is as close as we'll
get to a [database migrations](http://guides.rubyonrails.org/migrations.html)
utility for document oriented databases like Sitecore. N.B. that the data structure
is so simple for items inside Sitecore that creating a dataprovider is a relatively
<<<<<<< HEAD
straight [simple task](https://github.com/pbering/SitecoreData)
=======
straight [simple task] (https://github.com/pbering/SitecoreData)
>>>>>>> bfc92a44464bcb51c3ab466b5f73509473e5269d

## *.scproj, the Build and Deployment Workflow

Hedgehog created a (custom project type)[http://msdn.microsoft.com/en-us/library/bb166376(VS.100).aspx]
, scproj, for managing Sitecore items from managing and building Sitecore projects. When building, this
invokes 'C:\Program Files (x86)\MSBuild\HedgehogDevelopment\SitecoreProject\v9.0\HedgehogDevelopment.SitecoreProject.targets'
which builds the following workflow for lower environments:

1. Build and create project artifacts
2. Perform post-build steps, such as replacing config files
3. Install Sitecore connector (the source of which is here: C:\Program Files (x86)\Hedgehog Development\Team Development for Sitecore (VS2010)\PackageInstaller\PackageInstaller)
4. Deploy, or deserialize the items to the database
5. Perform any post-deploy steps

For higher environments, unfortunately, system administrators generally want a more manual deployment process.
This is the cost of working in an enterprise environment, but with a few config changes, the workflow may be
adjusted:

1. Build and create project artifacts
2. Perform post-build steps
3. Generate Sitecore package for deployment

From here you can either hand off the entire Sitecore package, with code deployment, or the build artifacts and the
*.scitems file separately.

The only problem with the *.scproj project template is that the build, deployment and Sitecore item settings
reside in the same file. With large content trees and multiple deployment environments, this can quickly bloat
and become a nightmare during merges.

## Simple config samples

I prefer to keep my deploments as simple as possible and try to create a universal build step for the web project:

{% highlight xml %}
  <PropertyGroup>
    <Configuration Condition=" '$(Configuration)' == '' ">
    </Configuration>
    <Platform Condition=" '$(Platform)' == '' ">AnyCPU</Platform>
    ProjectGuid>{61236e89-492e-454f-868e-f9126572c77a}</ProjectGuid>
    <TargetFrameworkVersion>v4.0</TargetFrameworkVersion>
    <SourceWebProject>{2E70A40A-85A8-4A1E-9A5B-E23935372C71}|SampleTDSProject.Web\SampleTDSProject.Web.csproj</SourceWebProject>
    <SourceWebPhysicalPath>..\SampleTDSProject.Web\</SourceWebPhysicalPath>
    <SourceWebVirtualPath>/SampleTDSProject.Web.csproj</SourceWebVirtualPath>
  </PropertyGroup>
{% endhighlight %}

This will create the build artifacts for any target, and create the debug symbols which we can
take out in a later step of the process. For individual environments, I create a property group
targeting the various environments:

{% highlight xml %}
  <PropertyGroup Condition=" '$(Configuration)' == 'SampleTDSProject.local' ">
    <DebugSymbols>true</DebugSymbols>
    <RecursiveDeployAction>Ignore</RecursiveDeployAction>
    <SitecoreDeployFolder>C:\_SITES\sampletdsproject.local\Website</SitecoreDeployFolder>
    <SitecoreAccessGuid>8536b728-2fd4-4cb4-9861-1494fd8c4372</SitecoreAccessGuid>
    <SitecoreWebUrl>http://local.sampletdsproject.com</SitecoreWebUrl>
    <InstallSitecoreConnector>True</InstallSitecoreConnector>
    <OutputPath>.\VML.enhance.local\</OutputPath>
  </PropertyGroup>
{% endhighlight %}

They're a variety of options surrounding the deployment of the Sitecore options. The
[sample project](http://www.hhogdev.com/~/media/Files/Products/Team_Development/TDS-Sample.zip)
outlines the most common options. Either build within Visual Studio or use msbuild from the cli:

C:\Windows\Microsoft.NET\Framework\v4.0.30319\msbuild c:\_application\SampleTdsProject.TDS\SampleTdsProject.scproj /p:Configuration=SampleTDSProject.local