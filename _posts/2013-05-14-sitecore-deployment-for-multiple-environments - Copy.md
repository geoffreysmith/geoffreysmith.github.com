---
layout: post
Sitecore Deployment for Multiple Environemts
---

After several weeks of running automated deployments without issue across multiple local environments and higher environments,
I've made a few simplifications and conceptually changed how config settings are deployed.

I ran into several issues:

- Higher environments are often configured (locked down) in a manner
which precludes attaching databases, creating IIS sites and other management
tasks that we've previously scripted. This is a relic of devops that hasn't died
in corporate environments, and foreign to those of us who are used to doing
"heroku ps --remote qa" to create a new staging environment from the command line.

- Having muliple configuration folders with separate copies of all the configs was
an improvement but still a headache. The general idea was to be able to deliver a product
that a very junior developer could look at and manually copy config files without needing
to learn about transforms. It was more of a liability measure, I've encountered enough horrible
build scripts to know that over the years developers will take the path of least resistence when
solving build problems. I think up to date documentation is the answer to this, and documentation
that describes a manual build process, not just "invoke build.cmd".

- Sitecore has multiple environments, per environemnt. This was hard for me to grasp when learning
Sitecore, mostly due to the jargon. It makes it a lot easier to think of the 'master' and 'web' as the same 
database, with 'web' simply being the latest version of approved content. In this way it is more of a cache, it
does not care what came before or what comes next, it is overridden by previous versions. The separate instances
also contain configruation elements which differ, more or less removing the ability to go to any /sitecore cms page
and any reference to the master databases.
-- For most projects, these hardening changes are environment agnostic. What we script to harden in one project and 
environment should work across the board.
-- Unless the front end needs to communicate with Sitecore's data repository, the content delivery server has only 
a reference to the cache and cannot write to the master database. A message bus or WCF end pont is need to connect the
content delivery server to a writable server. This complicates the build needlessly and I haven't had the need to come up
with an elegant solution.

So I've begun keeping all the config settings in a single YAML file organized with:

1. Project globals (project name, test projects, sitecore version)
2. A section for each environment: local, release, production

Here's a sample config.yml

analytics: 'DMS 6.6.0 rev. 130404'
test_projects: penelope.Web.Tests.dll
databases:
    - core
    - master
    - web
    - analytics
sitecore: 'Sitecore 6.6.0 rev. 130404'
tds_packages:
    - penelope.Fixtures
    - penelope.Content
local:
    src_directory: 'C:\_APPLICATION\penelope'
    data_folder: ..\Data
    site_name: kcpl
    deploy_directory: 'C:\_SITES\penelope\'
    sql_server_name: (local)
    connection_string: 'Trusted_Connection=Yes;Data Source=$sqlServerName;Database=$siteName.$db'
    live_mode: 'true'
    host_name: local.penelope.com
dev:
    src_directory: 'C:\jenkins\workspace\penelope'
    data_folder: ..\Data
    site_name: penelope
    deploy_directory: \\10.10.10.0
    sql_server_name: (local)
    connection_string: 'redacted'
    live_mode: 'true'
    host_name: dev.penelope.com

This is great and let's me keep all my config files in my project's App_Config, 
this is as close to something like Fabric you'd achieve in .NET right now.

I use the "go.ps1" file to some basic setup and invoke the build script, mostly 
calling the "build.ps1" or the "deploy.ps1" along with passing in the targeted 
environment as parameter.

The rest of the steps are straightforward.

1. Extract Sitecore to the /tmp directory if it isn't already extracted.
2. Build the projects in /tmp/artifacts in release mode.
3. Package up serialized items (TDS)
3. Run tests, if they fail exit build with error code 1.
4. Copy base Sitecore install from the zip, then copy build artifacts over that
5. Generate a copy of the same code base and config files for the
CMS and CD server.
6. Run environment specific transforms from the YAML file and perform 
the hardening.
7. Done, exit script 0

We now have a release ready to be copied directly to the server, no additional
transforms necessary, allowing deployment teams that cannot utilize automation for
whatever reason to pick up the build with minimal effort.

However with the deploy script we can now do the following:

1. Invoke the Hedgehog TDS connector to upload our packages in the order we want, allowing
templates to be deployed before presentation content.
2. Run a robocopy or overwrite on whatever environment we want to target.

Even with unzipping the Sitecore project, the whole process including deployment takes around
2.5 minutes. If the project is already unzipped in the tmp directory, it drops down a minute and
I'm sure could be sped up even more if you're willing to invest in an SSD or RAM disk.