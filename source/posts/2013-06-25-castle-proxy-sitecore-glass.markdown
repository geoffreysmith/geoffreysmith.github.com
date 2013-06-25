---
title: Sitecore Glass Mapper and Castle's DynamicProxy
date: 2013-06-25
---

I recently came across a case where it appeared Sitecore Glass was not correctly mapping
lazy loaded objects:

```csharp
    public class Car
    {
        public string Make { get; set; }
		public string Model { get; set; }
		public Link Website { get; set; }
        public IEnumerable<Wheel> Wheels { get; set; }        
    }
	
	public class Wheel
	{
		public string Make { get; set; }
		public string Model { get; set; }
		public string Position { get; set; }
	}
```

All of Car's fields populated correctly except the multilist field, Wheels. The problem 
(correctly outlined in Glass documentation) are the reference types and Glass Sitecore fields
are mapped when the item is loaded. Collections are lazy loaded using <a href="http://docs.castleproject.org/Tools.DynamicProxy.ashx">Castle's DynamicProxy</a>
and need to be marked as virtual to initiate loading, see 
<a href="https://github.com/mikeedwards83/Glass.Mapper/blob/master/Source/Glass.Mapper/Pipelines/ObjectConstruction/Tasks/CreateConcrete/LazyObjectProxyHook.cs"> the LazyObjectProxyHook</a>
class for the implementation.