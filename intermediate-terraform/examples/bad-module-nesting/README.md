# Just a quick example of a structure that might indicate some suboptimal nesting of modules

Per Hashicorp's guidance, flat, composable module structures are recommended, meaning if you find yourself with highly-nested structures of modules, you're likely organizing or architecting your Terraform projects in a way that will be hard to manage over time:

```
$ tree .
.
├── README.md
├── data
│   └── cache
│       └── network
├── main.tf
└── network
    └── subnet
        └── cidrs
```

An example structure here where the module `data` might nest `cache` which might nest `network`

And `network` might nest `subnet` which might nest `cidrs`

And possibly `data/cache/network` relies on some value from `network/subnet/cidrs`. At first glance, the structure might look sane and like a good idea, but this will end up very hard to follow and maintain in this case. Flatten it out and you'll likely find yourself with a simpler structure that makes just as much sense and will be easier to maintain.
