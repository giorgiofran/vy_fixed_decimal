# vy_fixed_decimal

Utilities for managing fixed decimal and money numbers

FixedDecimal class allows to manage numbers with a fixed decimal length and a certain rounding policy.

Money class is built on top of FixedDecimal and allows managing currencies.

Both classes implement the Decimal one (by Alexandre Ardhuin) that allows making computations without loosing precision

The package is logically divided into three parts:
- Decimal extensions and utilities
- FixedDecimal class
- Money class

# Decimal extensions and utilities

The package contains also some extensions to the Decimal class.
- a DecimalPoint class allows defining points in Decimal precision
- A simple LineaRegression class, that allows performing a linear regression calculation on a series of points. 
- Basic Decimal extensions  
- A locale based formatter and parser.

# Fixed Decimal class

The need behind a Fixed Decimal class is not to worry about decimal precision at the cost of a little loose of precision.
The main use is in financial calculations.

Mainly, when you define a fixed decimal number, you decide the scale (how many decimal digits) and the rounding criteria (how to round those decimal exceeding the scale).
Then, the calculations on these fields are made consequently without any worry about calculation precision.

For instance, let's say that I define a variable of type fixedDecimal with two decimal digits and truncate rounding policy.
If I assign the value 1.274 to that variable, the content will be automatically adjusted to 1.27.
Multiplying the variable with value 1.27 by itself, will lead to a result of 1.61 (instead of 1.6129)

## Parameters

#### Minimum value and scale
These parameters are alternative, the meaning is to specify which is the number of decimal digits to be used in the calculation.
The scale concept is a little easier to understand.
- Scale 0 means no decimal (ex. 12)
- Scale 1 means one digit only (ex. 12.3)
- Scale 2 means two digits only (ex. 12.37)
- and so on...

Please note that also negative scale are accepted.
- Scale -1 means only tens (ex. 10, 40, or 70)
- Scale -2 means only hundreds (ex. 100, 200 or 600)
- and so on ...

Any scale is converted into a minimum value. 
The minimum value is the lesser value you can use based on the scale assigned.
- Scale 0 -> minimum value 0
- Scale 1 -> minimum value 0.1
- Scale 2 -> minimum value 0.001
- and so on ...

Functionally speaking, assigning a scale or a minimum value works the same exact way.
The only difference is that a minimum value can have a more fine-grained value.
For example, I can assign a minimum value of 0.05 (with scale I cannot), 
and my calculations will be rounded consequently.
- (Minimum value 0.05 and truncation), 1.23 -> 1.20, 1.27 -> 1.25

##### Default

By default, if the number we are creating has finite precision, 
its scale is used unless it is bigger of 10, in this case 10 is assumed.
If the number has not finite precision, a scale of 10 is used.

#### Rounding

There are ten different rounding ways:
  - truncate (or round towards zero),
  - floor (or round down),
  - ceil (or round up),
  - awayFromZero,
  - halfUp,
  - halfDown,
  - halfTowardsZero,
  - halfAwayFromZero,
  - halfToEven,
  - halfToOdd
  
  See this wikipedia page for details: 
    https://en.wikipedia.org/wiki/Rounding#Types_of_rounding
    
    
##### Default

The default is halfToEven.

#### Scaling Policy

This is a tricky argument. 
The logic is: how do we create the result of an operation if the operands 
have different scale and/or roundings?
There are 4 policies:
 - adjust,
 - sameAsFirst,
 - biggerScale, 
 - thisOrNothing
 
 First we have to understand how the calculation works.
 For any operation the calculation is made on the decimal values of each operand.
 Then the minimum value, rounding and scaling policy are determined based on some rule 
 (we will see later). As a final step, the fixed decimal variable is generated with 
 the above values.
 
There are three ways of doing most of the operations:
 - language operand (ex. `var1 + var2`)
 - instance method  (ex. `var1.add(var2)`)
 - static method (ex. `FixedDecimal.addition(var1, var2)`)
 
The difference are:
- language operand: both operands must be of type FixedDecimal
- instance method: the first operand must be of type FixedDecimal the 
  second can be any number.
- static method: both operand can be of any type (numeric...)

In general, the types that can be used (depending on the methods) are: int, double, Decimal and FixedDecimal.

This is quite flexible. For example, I could say: `FixedDecimal.addition(5, 3)` 
and obtain a fixed decimal variable from two int.
Obviously this flexibility is payed with a complicated parameters definition, 
because none of the above types (except fixed decimal, obviously) carries with it
the scale and the rounding policy.  

This is why the instance and the static methods allow defining the result variable
parameters like scale and rounding policy. But they are optional. 
If no parameter is given, the programs makes its assumptions...

So, resuming, the scaling policy is about **how to calculate scale and rounding in
the result variable of an operation if they are not explicitly defined** 
(for example with the language operand it is not possible to assign these parameters)

Let's see how scaling policies works. 
 
##### Scaling policy: Adjust

The logic of the adjust policy is to try to keep the minor number of decimal 
digits with the minimum loss of precision.

The rounding policy of the first addend is maintained. 
If only one FixedDecimal is present, its rounding policy will be used, 
otherwise the default halfToEven will be used.

Example: 
 - fd halfToEven + fd truncate -> fd halfToEven
 - fd truncate + fd halfToEven -> fd truncate
 - double + fd truncate -> fd truncate
 - double + int -> fd adjust

###### Addition

- minimum value: the minor of the two addends (the bigger scale) is maintained.
  Example:
  - fd 1.578 + fd 1.38 -> fd 2.958
  - fd 1.38 + fd 1.578 -> fd 2.958
          
###### Subtraction

- minimum value: the minor of the two addends (the bigger scale) is maintained.
  Example:
  - fd 1.578 - fd 1.38 -> fd 0.198
  - fd 1.38 - fd 1.578 -> fd -0.198
          
## Usage

A simple usage example:

    import 'package:vy_fixed_decimal/vy_fixed_decimal.dart';

    main() {
      FixedDecimal fixed = FixedDecimal.parse('1');
    }

## Features and bugs

Please file feature requests and bugs at the [issue tracker][tracker].

[tracker]: https://github.com/giorgiofran/vy_fixed_decimal/issues