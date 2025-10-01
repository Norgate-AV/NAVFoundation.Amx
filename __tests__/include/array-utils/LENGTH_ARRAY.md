# LENGTH_ARRAY

**LENGTH_ARRAY** returns the effective length of a dimension of an array, implicitly through array initialization or array manipulation operations, or explicitly through a call to the function `SET_LENGTH_ARRAY`.

**Syntax:**

```netlinx-source
LONG LENGTH_ARRAY (<type> Array[ ])
```

**Parameters:**

- **\<type\>** - may be any intrinsic or user-defined data type.
- **Array** - an array of any type.

**Result:**

- The effective (or working) length of the array.

**Example:**

```netlinx-source
INTEGER Len
INTEGER Array1[ ] = {3, 4, 5, 6, 7}
INTEGER Array2[ ] = {1, 2}
INTEGER My3DArray[5][3][4] =

{
 {
  {1,2,3,4},
  {5,6,7,8},
  {9,10,11}
 },
 {
  {13,14}
 }
}

Len = LENGTH_ARRAY(Array1) // Len = 5
Len = LENGTH_ARRAY(Array2) // Len = 2

Len = LENGTH_ARRAY(My3Darray)
(* Len = 2, the number of tables *)

Len = LENGTH_ARRAY(My3Darray[2])
(* Len = 1, the number of rows in table 2 *)

Len = LENGTH_ARRAY(My3Darray[1][3])
(* Len = 3, the number of columns in table 1, row 3 *)
```

**Note:**

The lengths of an array are determined by calling `LENGTH_ARRAY` and `MAX_LENGTH_ARRAY`:

`LENGTH_ARRAY` returns the effective length of a dimension of an array: the length set implicitly through array initialization or explicitly through a call to `SET_LENGTH_ARRAY`.

`MAX_LENGTH_ARRAY` is used to determine the maximum length of a dimension of an array.

Changing an element in array does not change its length. `SET_LENGTH_ARRAY` is used  to change the effective length of an array when necessary, such as when you’ve added elements via a FOR loop.

See Also

- Array Keywords
- MAX_LENGTH_ARRAY
- SET_LENGTH_ARRAY
