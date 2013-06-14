---
layout: post
Automated Sitecore 6.6 MVC deployment
---

Sitecore is an unusual framework, from a development perspective, to
begin development on. Generally you will need to do the following to 
standup a Sitecore site and create a Visual Studio solution to commit to
source control:

1. Download the Sitecore zip file
2. Download your license.xml
3. Extract Website/Data folder from the zip file to your site directory
4. Attach the databases to MSSQL
5. Copy your license.xml file to your /Data directory
6. Edit the config files in the Web.config and App_Config/* to update your
connection strings, and Sitecore data folder settings
7. Create an AppPool (v4)
8. Create an IIS site and add the AppPool, point it to your installation directory
9. Add site address to hosts file

You now have Sitecore running! But you haven't even committed anything to source control:

1. Create an MVC project in Visual Studio
2. Copy Sitecore.Mvc.dll, Sitecore.Kernel.dll and Sitecore.Client.dll to your referenced assemblies
directory
3. Copy the Web.config and App_Config/* files from your site to your source directory
4. If using MVC4, make sure to upgrade the Web.config to MVC4 (http://www.asp.net/whitepapers/mvc4-release-notes#_Toc303253806)
5. Add a TDS project to the solution, set up the settings...

There's 15 steps, and a bit more if you follow a more verbose setup by Jon West (http://www.sitecore.net/Community/Technical-Blogs/John-West-Sitecore-Blog/Posts/2012/06/Sitecore-MVC-Playground-Part-3-Creating-a-Visual-Studio-Project.aspx).

For comparison, here is how you would setup a RefineryCMS site in Ruby:

gem install refinerycms
refinerycms path/to/my_new_app
cd path/to/my_new_app/
rails server

It is unfair to compare a propietary CMS to an open source CMS, or a Ruby project to a C# project, but there is serious merit in looking 
at how developers in other environments deal with the same problems we deal with. Sitecore, to be fair, does include a Windows installer,
but that introduces human error and ugly screenshot step by steps in Wikis.

What I really want to do is the following (assuming a source project has been created):

git clone git://myrepo/sitecoresite.git
cd sitecoresite
.\LOCAL.InstallSitecoreAndDeploy.bat

Done! Three steps, and we can very nearly get there if we add the two steps of copying the Sitecore zip file and the license file a specific location.
This is a huge benefit, and just doesn't save the developer the 20-30 minutes it takes to standup a Sitecore site:

- New developers can come on in less than 5 minutes with little or no knowledge of how to install Sitecore
- You can, quickly, roll back database changes very quickly by simply installing the base database and running TDS
- Allows you to standup higher environments quickly and with confidence
- Testing and trying out new features no longer an arduous task, simply abandon changes and run the deploy again

To accomplish this I began using Dropkick, a powerful deployment framework I've used many times before, but ended up choosing the simplicity of 
PowerCore, a newly release collection of Sitecore specific Powershell scripts.

Dropkick and Sitecore

The concept behind Dropkick is simple: define the deployment tasks fluently in C#, expose the environment settings in a JSON
file for sysadmins to audit on higher environments, and invoke the Dropkick executable on your compiled deployment assembly.
Here's the basic deployment that mimics steps 1-8 outlined above:

https://gist.github.com/geoffreysmith/5544474

There are two major components missing:

1. The ability to add an entry to the hosts file, which I created an API for the Hosts file just for this task called Simple.HostsManager (https://github.com/geoffreysmith/Simple.HostsManager)
2. Building and publishing the custom web project
3. Running TDS to update the Sitecore database

There are also several drawbacks to Dropkick:

1. System admins don't really know what is being deployed and how
2. It requires an additional step of building the deployment solution, then running dk.exe on that compiled assembly

While the first issue might cause corporate governance problems, the second issue isn't that hard to overcome. I was in the process of very proudly
completing a blog post and sample site with the perfect Sitecore Dropkick solution when I came across a much better solution using Powershell: Powercore.