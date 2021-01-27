# Single line with number-sign
// Single line with double-slash
/*
Multi line comment block
*/
structure { }
structure "label0" { }
structure "label0" "label1" { }
structure "label0" "label1" "label2" {
    interpolation = "${lookup(element(var.foo, "bar"))}"
    decimal = -42
    hexidecimal = 0xDEADBEEF
    size = 1024Kb
    boolean = true
    string = "test"
    heredoc = <<EOT
        test
    EOT
    array = [ "foo", "bar", 42 ]
    map = { "foo" : true, "bar" : "baz"}

    nested-structure {
        foo = 348743
        bar = "348743Gb"
    }
}
