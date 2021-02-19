# Exercise 3: Input Variables, Types, and Outputs

Note that this is one exercise we're we'll be looking at 0.12-specific capabilities heavily. Variable types in 0.11 consist of:

* string
* list
* map

and are pretty simple. Using variables and their types in 0.11 don't require much to understand. The changes introduced in 0.12 around variables and data types, however, do warrant some study. So, that's what we'll be doing here, in a bit more detailed way that the intro level.

## Looking at the new variable types in some detail

We have good examples of all variable/data types defined/declared in our `variables.tf` file:

```
# Primitives
variable "string_var" {
  type = string
}

variable "number_var" {
  type = number
}

variable "bool_var" {
  type = bool
}

# Complex: Collection
variable "list_any_var" {
  type = list(any)
}

variable "list_number_var" {
  type = list(number)
}

variable "map_any_var" {
  type = map(any)
}

variable "map_bool_var" {
  type = map(bool)
}

variable "set_any_var" {
  type = set(any)
}

variable "set_string_var" {
  type = set(string)
}

# Complex: Structural
variable "object_person_var" {
  type = object({
    name = string,
    age = number
  })
}

variable "tuple_line_item_var" {
  type = tuple([
    string,
    number,
    bool
  ])
}

# Complex: Mixed
variable "list_object_people_var" {
  type = list(object({
    name = string,
    age = number
  }))
}

# Untyped
variable "untyped_var" {}
```

### Primitives

Let's just look at our primitives first and play a little bit with them. We'll spend this exercise playing primarily in fact to see how we can use and even break some of our variables based on everything from loose to strict typing.

Here are our primitive variable declarations:

```
variable "string_var" {
  type = string
}

variable "number_var" {
  type = number
}

variable "bool_var" {
  type = bool
}
```

Pretty straightforward. Notice also that we have a `terraform.tfvars` file in this project with some defaults set. We've opted to set defaults here instead of the variable declarations themselves so it's easier to see them separately, and to just get a chance to continue some work with a tfvars file. Here are the related defaults for these primitives:

```
string_var = "this value is a string"
number_var = 1
bool_var = true
```

Probably nothing too surprising or ground-breaking going on here, but again, let's play around with this a bit. Simply by way of setting types for our variables, we've added some early validation capabilities in terraform. So, let's try passing in some non-numeric value to our `number_var` and see what happens:

```
$ terraform apply -var number_var="not a number"

Error: Invalid value for input variable

The argument -var="number_var=..." does not contain a valid value for variable
"number_var": a number is required.
```

Cool, so since that variable is supposed to be a number, we get an error early that terraform can't accept a value set that isn't a number.

A quick aside at this point. `terraform.tfvars` is setting the number_var for us to a valid number. We're passing in an invalid value via an alternative way of passing in variables. So, what's the precedence here? For the different ways to pass in variables to terraform, here's the order of precedence and how terraform determines the final value to actually attempt to use. Later sources in the list taking precedence over earlier ones:

* Environment variables
* The terraform.tfvars file, if present.
* The terraform.tfvars.json file, if present.
* Any \*.auto.tfvars or \*.auto.tfvars.json files, processed in lexical order of their filenames.
* Any -var and -var-file options on the command line, in the order they are provided. (This includes variables set by a Terraform Cloud workspace.)

So, our `-var number_var="not a number"` being used instead of the value set in terraform.tfvars

OK, back to our main exercise path. We see that variable typing gives us a way to have added validation for our terraform configuration. What if we tried to pass a number to the string_var?

```
$ terraform apply -var string_var=20

Apply complete! Resources: 0 added, 0 changed, 0 destroyed.
...
string_var = 20
```

Hmm, no error, why is that? Well, the string data type really being one of the more foundational, and type conversion can happen for just about any value you pass in via the command line, so even something like the following works:

```
$ terraform apply -var string_var=[1,2,3]

Apply complete! Resources: 0 added, 0 changed, 0 destroyed.
...
string_var = [1,2,3]
```

Really, it's just seeing anything we pass into that value on the command line as a string of characters, thus just about anything could be valid.

### Complex Types: Collections

OK, on to our complex collection types

```
variable "list_any_var" {
  type = list(any)
}

variable "list_number_var" {
  type = list(number)
}

variable "map_any_var" {
  type = map(any)
}

variable "map_bool_var" {
  type = map(bool)
}

variable "set_any_var" {
  type = set(any)
}

variable "set_string_var" {
  type = set(string)
}
```

Let's look at our terraform.tfvars defaults being set

```
list_any_var = [false, true, true]
list_number_var = [2, 3, 8]
map_any_var = {
  one = 1,
  two = 2
}
map_bool_var = {
  one_enabled = true,
  two_enabled = false
}
set_any_var = ["first", "second", "third"]
set_string_var = ["first", "second", "third"]
```

So, these are all complex collection types, meaning they represent some list or some set of things. One primary important, common aspect of these types is that the content of any variable must be of the same type. So, a list must include all numbers, or all strings, a map must include values in the key/value pairs that are all strings or all booleans. Let's see what happens when we try to set something of mixed type:

```
$ terraform apply -var list_number_var='["one", 2, 3]'

Error: Invalid value for input variable

The argument -var="list_number_var=..." does not contain a valid value for
variable "list_number_var": a number is required.
```

We're attempting to mix numbers and strings in a list that is strictly typed as a list of numbers, so we get the expected error. What if we did this though?

```
$ terraform apply -var list_any_var='["one", 2, 3]'
```

Do you expect an error? You might, but we actually won't get one for a similar reason to our `string_var` value setting just about any string of characters. When attempting the above we get:

```
$ terraform apply -var list_any_var='["one", 2, 3]'

Apply complete! Resources: 0 added, 0 changed, 0 destroyed.

Outputs:

bool_var = true
generated_password = <sensitive>
list_any_var = [
  "one",
  "2",
  "3",
]
...
```

Terraform is really just seeing `2` and `3` as strings, so no error. It's a list variable that accepts any type, so string is just fine. What about this though?

```
$ terraform apply -var list_any_var='[1, 2, 3]'

Apply complete! Resources: 0 added, 0 changed, 0 destroyed.

Outputs:

bool_var = true
generated_password = <sensitive>
list_any_var = [
  1,
  2,
  3,
]
```

Since we are passing a value whose items can all be identified as numeric, we can see that the ultimate value for `list_any_var` is indeed a list of numbers.

Let's do one last thing here, have a look at the `terraform apply` output for our variables of type `set`:

```
set_any_var = [
  "first",
  "second",
  "third",
]
set_string_var = [
  "first",
  "second",
  "third",
]
```

You may or may not see the same ordering in your output. Remember that one of the attributes of sets is that they are _unordered_. This is the primary difference b/w sets and lists. Lists always being ordered.

### Complex Types: Structural

The last set of types are complex structural types, whose common trait would be support for content that has mixed type. Let's look at both `variables.tf` and `terraform.tfvars` for these types:

```
variable "object_person_var" {
  type = object({
    name = string,
    age = number
  })
}

variable "tuple_line_item_var" {
  type = tuple([
    string,
    number,
    bool
  ])
}
```

```
object_person_var = {
  name = "Tom",
  age = 20
}
tuple_line_item_var = ["finance", 15, false]
```

Our first variable `object_person_var` being a object of mixed property value types that might, say, represent data about a person. We want to know the name which is a string, and the age which is a number, so we can do such mixing in a variable of type object.

A tuple is similar, just that it's a set of mixed-typed values. A tuple maybe being a representation of line item data from a relational database table as an example.

Try to break an apply similar to how we've been doing with above examples for both this object variable and the tuple one.

### Complex Types: Embedded

We can also set embedded types for variables. For example

```
variable "list_object_people_var" {
  type = list(object({
    name = string,
    age = number
  }))
}
```

So, similar to our person object variable type we saw before, but just a list of these things now. And here's how we're setting our default value:

```
list_object_people_var = [
  {
    name = "Beth",
    age = 35
  },
  {
    name = "Priya",
    age = 28
  }
]
```

Now is a time to call out the benefit of using tfvars files when your project deals in complex variables. Writing out these vars files tends to be a nicer automation experience than say having to pass these values in via the alternative mechansims of environment variable:

```
$ TF_VAR_list_object_people_var='[{name="Beth",age=35},{name="Priya",age=30}]' terraform apply
```

or

```
terraform apply -var list_object_people_var='[{name="Beth",age=35},{name="Priya",age=30}]'
```

Shell string escaping, how to quote items, etc. can get messy really quick in such approaches.

### Untyped Variables

Getting close to the end of this exercise, we want to look at some cases of untyped variables. An untyped variable in Terraform >= 0.12 means that the type will attempt to be inferred. Let's look at the bottom of our `variables.tf` at the variable example that is untyped

```
variable "untyped_var" {}
```

So, no type explicitly set, and we do still have a `terraform.tfvars` value set for it

```
untyped_var = ["one", 2, 3]
```

So, let's see what we get as an output, so how terraform sees this variable type:

```
$ terraform apply
...
untyped_var = [
  "one",
  2,
  3,
]
```

In short, Terraform is able to see this value as a tuple

### Sensitive Outputs

One last topic to cover, and related to outputs, what if you have an output that contains sensitive content, like a password or key? You can declare the output as a sensitive value:

```
output "generated_password" {
  value = "${local.generated_password}"
  sensitive = true
}
```

And we can see in our apply logs, it being handled accordingly:

```
$ terraform apply

Apply complete! Resources: 0 added, 0 changed, 0 destroyed.

Outputs:

bool_var = true
generated_password = <sensitive>
...
```

This feature is really **just about protecting sensitive items from being present in logs**. Note that it will still be in plain text in the state file. You can verify this by opening the `terraform.tfstate` file in this project directory:

```
{
  "version": 4,
  "terraform_version": "0.12.29",
  "serial": 12,
  "lineage": "465784ce-8419-fb1a-53ea-d8d43f1d2118",
  "outputs": {
    "bool_var": {
      "value": true,
      "type": "bool"
    },
    "generated_password": {
      "value": "dGhpcyB2YWx1ZSBpcyBhIHN0cmluZw==",
      "type": "string",
      "sensitive": true
    },
    ...
```

That's it for this exercise. If you have more time, feel free to continue playing around with the different types and various scenarios related to validation and otherwise.
