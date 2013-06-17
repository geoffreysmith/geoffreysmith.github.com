---
layout: post
Sitecore integration testing
---

Testing Sitecore presents a number of configuration changes to allow it work outside
an IIS process, but what it still prevents a number of difficulties:

1. You must test against a database, you're not testing in isolation and things like testing inserts
must then be deleted to revert the system to how it was before the test.
2. It takes a relatively long time to load a Sitecore instance.
3. I do not want to deploy a TDS package and update the database until the tests pass. The tests
themselves will depend on those new items in TDS to run. I cannot easily cleanup after a TDS package.

This is crazy. A better way to do this would be using an in-memory data provider that serializes
the base master database and then serializes any TDS projects you have. You can do all kinds of testing,
even experimental TDS testing and not worry persistent data. Luckily, Sitecore-FixtureDataProvider (https://github.com/hermanussen/Sitecore-FixtureDataProvider)
saved me from doing this myself.

The tests and sample are straightforward, albeit geared for the MSUNIT. I also recommend copying his stripped
down Sitecore configuration rather the one used in your web project. Events are disabled and I had no issue 
enabling them and testing code that relied on events.

Security is disabled by default in his examples as well, since this isn't how web projects normally run, I enabled it
to ensure that the calling methods always disabled security.

This works well for testing ETL processes but for actually accessing fields a serialized referenced to core will need to be
added and is commented out of the main project.

Best of all, you no longer have to keep a separate set of configuration files per environment for the web project.