# PSearch

PSearch is a simple vim plugin for jumping through curlybraces in a common
scope. The below example illustrates cycling through 1->2->3->1.
```
{
    { }  //1
    { }  //2
    { }  //3
}
{
    { }
}
```

## Default Mappings
The default mappings are `[[` and `]]`, and can be changed with the following
```
g:PSearch_map_n_forward = ']]'
g:PSearch_map_v_forward = ']]'
g:PSearch_map_n_backward = '[['
g:PSearch_map_v_backward = '[['
```
