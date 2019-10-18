# Creating a new dashboard filter
A new filter is created using `Filter$new(renderer, [queryTemplate])`. Filters can be placed in associated their dashboard *R* file or their own file.

## renderer - `function(ns, [arg1, arg2, ...], ...) -> tags`
The renderer function should always take a namespace function as its first argument. It may also have any additional arguments.  
The renderer should return shiny html tags created by `hr()`, `sliderInput()`, etc. to be placed in the UI.

**Note:** Due to implementation details the renderer function must take a `...` argument.

## queryTemplate [optional]
A SQL query template. It can contain references to the input elements in the form of `?identifier` where `identifier` is any of the input element ids.

For inputs such as `checkboxGroupInput` where the value may be a vector of many values each value will be quoted and then concatenated into a single comma separated string.

`NULL` values will be turned into the empty string `""`

**Note:** `identifier` must only contain lower/upper letters, numbers and _
