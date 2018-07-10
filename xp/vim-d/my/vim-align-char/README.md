#   Name

vim-align-char

#   Status

This library is a stable but minimalism personal experiment.

#   Description

Type `,a` and a following char to align the next char in the same line after
or at the cursor.


#   Synopsis

A Markdown table as:

```
| Name    | Age    |
| :-- | --: |
| Alice    | 10    |
| Bob    | 20    |
```

Put cursor at `A` of `Alice` and type `,a|`, it becomes:

```
| Name  | Age    |
| :--   | --: |
| Alice | 10    |
| Bob   | 20    |
```

Then put cursor at `1` and type `,a|`, it becomes:

```
| Name  | Age |
| :--   | --: |
| Alice | 10  |
| Bob   | 20  |
```

#   Features

-   `,a` then type any char to align.

-   `,a<space>` is dealt specially: it aligns the first non-space char.

-   `,a` with non-space char will align text and add a space before the
    user-typed char.

-   It align text with the same indent:

    ```python
    def foo(a, b=2):
        x = 3
        a_long_var = 4
    ```

    Put cursor at `x` and type `,a=`, it won't affect the `=` in `b=2` in function
    declaration:

    ```python
    def foo(a, b=2):
        x          = 3
        a_long_var = 4
    ```

    If you'd like to align text lines with different indent, visual-select all
    the 3 lines and type `,a=`:

    ```python
    def foo(a, b   =2):
        x          = 3
        a_long_var = 4
    ```

#   TODO

-   Align all following chars found in the line.

-   Customizable key map.

#   Author

Zhang Yanpo (张炎泼) <drdr.xp@gmail.com>

#   Copyright and License

The MIT License (MIT)

Copyright (c) 2015 Zhang Yanpo (张炎泼) <drdr.xp@gmail.com>
