# Exercise #8: Understanding and Manipulating Data/Variables

This is one part of the course where we'll look at some very brand new stuff. Prior to terraform version 0.12, the only variable types available were:

* String
* List
* Map

As we just saw in our discussion, there are a number of others now, so let's look at them in action. As you go
along in this exercise, you're encouraged to change the HCL to experiment a bit with the different data types
and using them in action.

### Primitive Types

Terraform has restructured to include variable types in a category "primitive". These are quite similar to
what you'd find in other language primitives. Let's change into the `primitives` directory and run some terraform
to see primitives in action

```bash
cd primitives
terraform apply
```

Wow that was fast! That's because we're not really creating any infrastructure in this folder, rather we're just looking at the processing and output of variables and data. You should see something like the following when running the above:

```
Apply complete! Resources: 0 added, 0 changed, 0 destroyed.

Outputs:

my_bool_negated = false
my_bool_value = my_bool is true
my_number_plus_two = 12
my_string_interpolated = my_string_value_interpolated
```

Now, take a look in the main.tf file and we'll look through each variable and each related output

```hcl
variable "my_string" {
  type    = string
  default = "my_string_value"
}
...
output "my_string_interpolated" {
  value = "${var.my_string}_interpolated"
}
```

The string type is probably the simplest of the primitives. It remains the default type if you don't explicitly set
a variable type. The above shows you the syntax for string interpolation. You could do this when defining resource
properties, not just in constructing outputs like the above. We've seen this when making our buckets or bucket object
names in the previous exercises.

```hcl
variable "my_number" {
  type    = number
  default = 10
}
...
output "my_number_plus_two" {
  value = var.my_number + 2
}
```

The `number` type is new in 0.12. The above shows how you can deal in this number variable directly by doing arithmetic.

```hcl
variable "my_bool" {
  type    = bool
  default = true
}
...
output "my_bool_negated" {
  value = !var.my_bool
}

output "my_bool_value" {
  value = var.my_bool == true ? "my_bool is true" : "my_bool is false"
}
```

The `bool` type is also new in 0.12. It gives you the power to perform boolean operations and checks in your HCL like we
see above in both the ternary and negation syntax to construct these output values.

### Complex Types

Complex types are made up of mostly new types and capabilities in v0.12. Let's take a look at them in action

```bash
cd complex
terraform apply
```

Running the above should give you something like

```
Apply complete! Resources: 0 added, 0 changed, 0 destroyed.

Outputs:

my_list_index_2 = 3
my_list_values = [
  "1",
  "2",
  "3",
]
my_map_values = {
  "ages" = [
    "12",
    "14",
    "10",
  ]
  "names" = [
    "John",
    "Susy",
    "Harold",
  ]
}
my_object_values = {
  "ages" = [
    12,
    14,
    10,
  ]
  "names" = [
    "John",
    "Susy",
    "Harold",
  ]
}
my_set_values = [
  1,
  2,
  3,
  4,
  5,
]
my_tuple_values = [
  "1",
  2,
  "3",
]
```

Let's look at each of the complex types individually and see what's actually going on in our `main.tf` file. Again, we're not
creating any infrastructure in this exercise, merely seeing variables getting set, then outputs being constructed from these
variable values. The way we're using these variables in outputs would apply to any other resource or use in your HCL.

```hcl
variable "my_list" {
  type      = list(string)
  default   = ["1", "2", "3"]
}
...
output "my_list_index_2" {
  value = var.my_list[2]
}

output "my_list_values" {
  value = var.my_list
}
```

The list type is not new in 0.12, and works similarly as it did before. In our example here, however, we're setting a [type
constraint](https://www.terraform.io/docs/configuration/types.html), so that our list can only contain string values. In
our two output examples, we see first an example of accessing a particular list item value, as well as using the entire list.

```hcl
variable "my_set" {
  type      = set(number)
  default   = [1, 2, 3, 4, 5]
}
...
output "my_set_values" {
  value = var.my_set
}
```

Sets are very similar to lists, but have their differences. We discussed them, but play around with the definition in the HCL here and see if you can remember or identify what makes a set _unique_.

```hcl
variable "my_tuple" {
  type      = tuple([string, number, string])
  default   = ["1", 2, "3"]
}
...
output "my_tuple_values" {
  value = var.my_tuple
}
```

My guess is that you'll probably use tuples the least of any of the types. But we get to see it in action here nonetheless.
The key takeaway is that it's a list with mixed, strict type constraints and ordering.

```hcl
variable "my_map" {
  type    = map(list(any))
  default = {
    names : ["John", "Susy", "Harold"],
    ages : [12, 14, 10],
  }
}
...
output "my_map_values" {
  value = var.my_map
}
```

Maps are also not new in 0.12, and they work very similarly to how they did before, except that they now allow a type constraint for the related value(s). A map is just a collection of key/values.

```hcl
# How is this different than the map above?
variable "my_object" {
  type = object({
    names : list(string),
    ages : list(number),
  })
  default = {
    names : ["John", "Susy", "Harold"],
    ages : [12, 14, 10]
  }
}
...
output "my_object_values" {
  value = var.my_object
}
```

And finally the object type. Which is similar to map. But, can you identify the differences? Also, add some other outputs
of your own to access specific values in the object, change the object structure to see how far you can go with setting up
an object.

### Terraform Data and Reference

We've covered HCL data and variable concepts pretty completely at this point, but we want to finish off by looking closely
at one other thing: Terraform data sources and referencing these data sources.

Remember earlier when we queried the state of another terraform project? That was a Terraform data source. We want to look at how
providers allow you the ability to query particular sources to get things you need at runtime with the same mechanism.
Two very common examples in the AWS provider:

1. Querying available AMI images in AWS to get the AMI ID to use for your EC2 instance
1. Querying availability zones in your current AWS region. This is useful for things like ensuring that you have a resource in every AZ for your region

So, let's look at some of this in action

```bash
cd other-data
terraform init
terraform apply
```

And you should get something like the following as the output

```
data.aws_ami.ubuntu: Refreshing state...
data.aws_availability_zones.available: Refreshing state...

Apply complete! Resources: 0 added, 0 changed, 0 destroyed.

Outputs:

current_region_availability_zones = [
  "us-east-2a",
  "us-east-2b",
  "us-east-2c",
]
most_recent_ubuntu_ami_id = ami-0d03add87774b12c5
```

Two different data sources are being called here:

1. The AWS AMI data source
1. The AWS availability zones data source

First, a look at the `main.tf` relevant resource that actually did the AMI querying for us

```hcl
# A Terraform data source is a specific type of resource that gives us the ability to pull in data from elsewhere to
# use in our own terraform HCL and operations
data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-xenial-16.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}
```

Don't worry too much about all the pieces here, the most important part to understand right now is really `data "aws_ami"`. This is a data source type resource that is a generic construct in Terraform itself. The AWS provider implements this `aws_ami` data source type so that we can query AMIs available in AWS.

After the data source resource is declared, we can then access it's attributes that have been populated by actually making the
query to AWS

```
data.aws_ami.ubuntu.id
```

Second, let's look at the availability zone query pieces

```hcl
# Another AWS provider data source, giving us the ability to get all of the AZs in our current region
data "aws_availability_zones" "available" {
  state = "available"
}
```

Availability zones are specific to a particular region, and we're not passing in a region here, so how is this working? If you
can't figure out, ask a fellow classmate or the instructor for a little help!

Similar to the AMI data source, this one also has attributes that have been populated and can be accessed after the query to
the AWS api actually happens. So in our subsequent HCL, we can access the `names` attribute, giving us all AZ names

```
data.aws_availability_zones.available.names
```

### Finishing off this exercise

We're gonna do a little bit of experimenting as a way to finish off this exercise. This will give you an opportunity to play
a bit with things that look interesting to you in the HCL syntax, variable, and data usage areas:

1. Conditionals like ternary syntax, other expressions: https://www.terraform.io/docs/configuration/expressions.html
1. Interpolation, figuring what you can and can't do here
1. Built-in functions: https://www.terraform.io/docs/configuration/functions.html

Maybe try some of the above out with `terraform console`?

