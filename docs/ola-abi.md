# Ola language ABI
In order to interact programmatically with compiled ola programs, Ola language supports passing arguments using an ABI.

To illustrate this, we'll use the following example program:

```

contract BookExample {
    struct Book {
        u32 book_id;
        string book_name;
    }

    fn createBook(u32 id, string name) -> (Book) {
        Book myBook = Book({
            book_name: name,
            book_id: id
        });
        return myBook;
    }

    fn getBookName(Book _book) -> (string) {
        return _book.book_name;
    }

    fn getBookId(Book _book) -> (u32) {
        u32 b = _book.book_id + 1;
        return b;
    }

}
```

## ABI specification

When compiling a ola program, an ABI specification is generated and describes the interface of the program.

In this example, the ABI specification is:

```json
[
  {
    "name": "createBook",
    "type": "function",
    "inputs": [
      {
        "name": "id",
        "type": "u32",
        "internalType": "u32"
      },
      {
        "name": "name",
        "type": "string",
        "internalType": "string"
      }
    ],
    "outputs": [
      {
        "name": "",
        "type": "tuple",
        "internalType": "struct BookExample.Book",
        "components": [
          {
            "name": "book_id",
            "type": "u32",
            "internalType": "u32"
          },
          {
            "name": "book_name",
            "type": "string",
            "internalType": "string"
          }
        ]
      }
    ]
  },
  {
    "name": "getBookName",
    "type": "function",
    "inputs": [
      {
        "name": "_book",
        "type": "tuple",
        "internalType": "struct BookExample.Book",
        "components": [
          {
            "name": "book_id",
            "type": "u32",
            "internalType": "u32"
          },
          {
            "name": "book_name",
            "type": "string",
            "internalType": "string"
          }
        ]
      }
    ],
    "outputs": [
      {
        "name": "",
        "type": "string",
        "internalType": "string"
      }
    ]
  },
  {
    "name": "getBookId",
    "type": "function",
    "inputs": [
      {
        "name": "_book",
        "type": "tuple",
        "internalType": "struct BookExample.Book",
        "components": [
          {
            "name": "book_id",
            "type": "u32",
            "internalType": "u32"
          },
          {
            "name": "book_name",
            "type": "string",
            "internalType": "string"
          }
        ]
      }
    ],
    "outputs": [
      {
        "name": "",
        "type": "u32",
        "internalType": "u32"
      }
    ]
  }
]
```

## ABI encode function and params

We can use the tools provided by ola-lang-abi to generate function selectors and function parameters corresponding to ABI.

https://github.com/Sin7Y/ola-lang-abi/tree/main/examples