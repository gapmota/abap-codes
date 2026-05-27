FUNCTION-POOL ZV360MOTAFG.                  "MESSAGE-ID ..

* INCLUDE LZV360MOTAFGD...                   " Local class definition

TYPES: BEGIN OF ty_source,
         object  TYPE string,
         part    TYPE string,
         include TYPE progname,
         line    TYPE string,
       END OF ty_source.

TYPES tt_source TYPE STANDARD TABLE OF ty_source WITH DEFAULT KEY.
