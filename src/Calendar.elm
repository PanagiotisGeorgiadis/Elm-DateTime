module Calendar exposing
    ( Date, RawDate
    , fromPosix, fromRawParts
    , toMillis, monthToInt
    , getYear, getMonth, getDay
    , setYear, setMonth, setDay
    , incrementYear, incrementMonth, incrementDay
    , decrementYear, decrementMonth, decrementDay
    , compare
    , getDateRange, getDatesInMonth, getDayDiff, getFollowingMonths, getPrecedingMonths, getWeekday, isLeapYear, sort
    , months, millisInADay
    )

{-| The [Calendar](Calendar#) module was introduced in order to keep track of the `Calendar Date` concept.
It has no knowledge of `Time` therefore it can only represent a [Date](Calendar#Date)
which consists of a `Day`, a `Month` and a `Year`. You can construct a `Calendar Date` either
from a [Posix](https://package.elm-lang.org/packages/elm/time/latest/Time#Posix) time or by
using its [Raw constituent parts](Calendar#RawDate). You can use a `Date` and the
Calendar's utilities as a standalone or you can combine a [Date](Calendar#Date) and a
[Time](Clock#Time) in order to get a [DateTime](DateTime#DateTime) which can then be converted into
a [Posix](https://package.elm-lang.org/packages/elm/time/latest/Time#Posix).


# Type definition

@docs Date, RawDate


# Creating a `Date`

@docs fromPosix, fromRawParts


# Conversions

@docs toMillis, monthToInt


# Accessors

@docs getYear, getMonth, getDay


# Setters

@docs setYear, setMonth, setDay


# Increment values

@docs incrementYear, incrementMonth, incrementDay


# Decrement values

@docs decrementYear, decrementMonth, decrementDay


# Compare values

@docs compare


# Utilities

@docs getDateRange, getDatesInMonth, getDayDiff, getFollowingMonths, getPrecedingMonths, getWeekday, isLeapYear, sort


# Constants

@docs months, millisInADay

-}

import Array exposing (Array)
import Calendar.Internal as Internal
import Time exposing (Month)


{-| A full ([Gregorian](https://en.wikipedia.org/wiki/Gregorian_calendar)) calendar date.
-}
type alias Date =
    Internal.Date


{-| The raw representation of a calendar date.
-}
type alias RawDate =
    { year : Int
    , month : Time.Month
    , day : Int
    }



-- Creating a `Date`


{-| Construct a [Date](Calendar#Date) from a [Posix](https://package.elm-lang.org/packages/elm/time/latest/Time#Posix) time.
You can construct a `Posix` time from milliseconds using the [millisToPosix](https://package.elm-lang.org/packages/elm/time/latest/Time#millisToPosix)
function located in the [elm/time](https://package.elm-lang.org/packages/elm/time/latest/) package.

    fromPosix (Time.millisToPosix 0)
    -- Date { day = Day 1, month = Jan, year = Year 1970 } : Date

    fromPosix (Time.millisToPosix 1566795954000)
    -- Date { day = Day 26, month = Aug, year = Year 2019 } : Date

    fromPosix (Time.millisToPosix 1566777600000)
    -- Date { day = Day 26, month = Aug, year = Year 2019 } : Date

Notice that in the second and third examples the timestamps that are used are different but the resulting [Dates](Calendar#Date) are identical.
This is because the [Calendar](Calendar#) module doesn't have any knowledge of `Time` which means that if we attempt to convert both of these dates back [toMillis](Calendar#toMillis)
they will result in the same milliseconds. It is recommended using the [fromPosix](DateTime#fromPosix) function provided in the [DateTime](DateTime#)
module if you need to preserve both `Date` and `Time`.

-}
fromPosix : Time.Posix -> Date
fromPosix =
    Internal.fromPosix


{-| Attempt to construct a [Date](Calendar#Date) from its (raw) constituent parts.
Returns `Nothing` if any parts or their combination would form an invalid date.

    fromRawParts { day = 25, month = Dec, year = 2019 }
    -- Just (Date { day = Day 25, month = Dec, year = Year 2019 }) : Maybe Date

    fromRawParts { day = 29, month = Feb, year = 2019 }
    -- Nothing : Maybe Date

-}
fromRawParts : RawDate -> Maybe Date
fromRawParts =
    Internal.fromRawParts



-- Conversions


{-| Transforms a [Date](Calendar#Date) into milliseconds.

    date = fromRawParts { day = 25, month = Dec, year = 2019 }
    Maybe.map toMillis date -- Just 1577232000000 == 25 Dec 2019 00:00:00.000

    want = 1566795954000 -- 26 Aug 2019 05:05:54.000
    got = toMillis (fromPosix (Time.millisToPosix want)) -- 1566777600000 == 26 Aug 2019 00:00:00.000

    want == got -- False

Notice that transforming a **date** to milliseconds will always get you midnight hours.
The first example above will return a timestamp that equals to **Wed 25th of December 2019 00:00:00.000**
and the second example will return a timestamp that equals to **26th of August 2019 00:00:00.000** even though
the timestamp we provided in the [fromPosix](Calendar#fromPosix) was equal to **26th of August 2019 05:05:54.000**

-}
toMillis : Date -> Int
toMillis =
    Internal.toMillis


{-| Convert a given [Month](https://package.elm-lang.org/packages/elm/time/latest/Time#Month) to an integer starting from 1.

    monthToInt Jan -- 1 : Int

    monthToInt Aug -- 8 : Int

-}
monthToInt : Month -> Int
monthToInt =
    Internal.monthToInt



-- Accessors


{-| Extract the `Year` part of a [Date](Calendar#Date).

    -- date == 25 Dec 2019
    getYear date -- 2019 : Int

-}
getYear : Date -> Int
getYear =
    Internal.yearToInt << Internal.getYear


{-| Extract the `Month` part of a [Date](Calendar#Date).

    -- date == 25 Dec 2019
    getMonth date -- Dec : Month

-}
getMonth : Date -> Month
getMonth =
    Internal.getMonth


{-| Extract the `Day` part of a [Date](Calendar#Date).

    -- date == 25 Dec 2019
    getDay date -- 25 : Int

-}
getDay : Date -> Int
getDay =
    Internal.dayToInt << Internal.getDay



-- Setters


{-| Attempts to set the `Year` part of a [Date](Calendar#Date).

    -- date == 29 Feb 2020
    setYear 2024 date -- Just (29 Feb 2024) : Maybe Date

    setYear 2019 date -- Nothing : Maybe Date

-}
setYear : Int -> Date -> Maybe Date
setYear =
    Internal.setYear


{-| Attempts to set the `Month` part of a [Date](Calendar#Date).

    -- date == 31 Jan 2019
    setMonth Aug date -- Just (31 Aug 2019) : Maybe Date

    setMonth Apr date -- Nothing : Maybe Date

-}
setMonth : Month -> Date -> Maybe Date
setMonth =
    Internal.setMonth


{-| Attempts to set the `Day` part of a [Date](Calendar#Date).

    -- date == 31 Jan 2019
    setDay 25 date -- Just (25 Jan 2019) : Maybe Date

    setDay 32 date -- Nothing : Maybe Date

-}
setDay : Int -> Date -> Maybe Date
setDay =
    Internal.setDay



-- Increment values


{-| Increments the `Year` in a given [Date](Calendar#Date) while preserving the `Month` and `Day` parts.

    -- date  == 31 Jan 2019
    incrementYear date -- 31 Jan 2020 : Date

    -- date2 == 29 Feb 2020
    incrementYear date2 -- 28 Feb 2021 : Date

**Note:** In the first example, incrementing the `Year` causes no changes in the `Month` and `Day` parts.
On the second example we see that the `Day` part is different than the input. This is because the resulting date
would be an invalid date ( _**29th of February 2021**_ ). As a result of this scenario we fall back to the last valid day
of the given `Month` and `Year` combination.

-}
incrementYear : Date -> Date
incrementYear =
    Internal.incrementYear


{-| Increments the `Month` in a given [Date](Calendar#Date). It will also roll over to the next year where applicable.

    -- date  == 15 Sep 2019
    incrementMonth date -- 15 Oct 2019 : Date

    -- date2 == 15 Dec 2019
    incrementMonth date2 -- 15 Jan 2020 : Date

    -- date3 == 31 Jan 2019
    incrementMonth date3 -- 28 Feb 2019 : Date

**Note:** In the first example, incrementing the `Month` causes no changes in the `Year` and `Day` parts while on the second
example it rolls forward the 'Year'. On the last example we see that the `Day` part is different than the input. This is because
the resulting date would be an invalid one ( _**31st of February 2019**_ ). As a result of this scenario we fall back to the last
valid day of the given `Month` and `Year` combination.

-}
incrementMonth : Date -> Date
incrementMonth =
    Internal.incrementMonth


{-| Increments the `Day` in a given [Date](Calendar#Date). Will also increment `Month` and `Year` where applicable.

    -- date  == 25 Aug 2019
    incrementDay date -- 26 Aug 2019 : Date

    -- date2 == 31 Dec 2019
    incrementDay date2 -- 1 Jan 2020 : Date

-}
incrementDay : Date -> Date
incrementDay =
    Internal.incrementDay



-- Decrement values


{-| Decrements the `Year` in a given [Date](Calendar#Date) while preserving the `Month` and `Day` parts.

    -- date  == 31 Jan 2019
    decrementYear date -- 31 Jan 2018 : Date

    -- date2 == 29 Feb 2020
    decrementYear date2 -- 28 Feb 2019 : Date

**Note:** In the first example, decrementing the `Year` causes no changes in the `Month` and `Day` parts.
On the second example we see that the `Day` part is different than the input. This is because the resulting date
would be an invalid date ( _**29th of February 2019**_ ). As a result of this scenario we fall back to the last
valid day of the given `Month` and `Year` combination.

-}
decrementYear : Date -> Date
decrementYear =
    Internal.decrementYear


{-| Decrements the `Month` in a given [Date](Calendar#Date). It will also roll backwards to the previous year where applicable.

    -- date  == 15 Sep 2019
    decrementMonth date -- 15 Aug 2019 : Date

    -- date2 == 15 Jan 2020
    decrementMonth date2 -- 15 Dec 2019 : Date

    -- date3 == 31 Dec 2019
    decrementMonth date3 -- 30 Nov 2019 : Date

**Note:** In the first example, decrementing the `Month` causes no changes in the `Year` and `Day` parts while
on the second example it rolls backwards the `Year`. On the last example we see that the `Day` part is different
than the input. This is because the resulting date would be an invalid one ( _**31st of November 2019**_ ). As a result
of this scenario we fall back to the last valid day of the given `Month` and `Year` combination.

-}
decrementMonth : Date -> Date
decrementMonth =
    Internal.decrementMonth


{-| Decrements the `Day` in a given [Date](Calendar#Date). Will also decrement `Month` and `Year` where applicable.

    -- date  == 27 Aug 2019
    decrementDay date -- 26 Aug 2019 : Date

    -- date2 == 1 Jan 2020
    decrementDay date2 -- 31 Dec 2019 : Date

-}
decrementDay : Date -> Date
decrementDay =
    Internal.decrementDay



-- Compare values


{-| Compares the two given [Dates](Calendar#Date) and returns an [Order](https://package.elm-lang.org/packages/elm/core/latest/Basics#Order).

    -- past   == 25 Aug 2019
    -- future == 26 Aug 2019
    compare past past -- EQ : Order

    compare past future -- LT : Order

    compare future past -- GT : Order

-}
compare : Date -> Date -> Order
compare =
    Internal.compare



-- Utilities


{-| Returns an incrementally sorted [Date](Calendar#Date) list based on the **start** and **end** date parameters.
_**The resulting list will include both start and end dates**_.

    -- start == 26 Feb 2020
    -- end   == 1 Mar 2020

    getDateRange start end
    -- [ 26 Feb 2020, 27 Feb 2020, 28 Feb 2020, 29 Feb 2020, 1  Mar 2020 ] : List Date

    getDateRange end start
    -- [ 26 Feb 2020, 27 Feb 2020, 28 Feb 2020, 29 Feb 2020, 1  Mar 2020 ] : List Date

-}
getDateRange : Date -> Date -> List Date
getDateRange =
    Internal.getDateRange


{-| Returns a list of [Dates](Calendar#Date) for the given `Year` and `Month` combination.

    -- date == 26 Aug 2019

    getDatesInMonth date
    -- [ 1 Aug 2019, 2 Aug 2019, 3 Aug 2019, ..., 29 Aug 2019, 30 Aug 2019, 31 Aug 2019 ] : List Date

-}
getDatesInMonth : Date -> List Date
getDatesInMonth =
    Internal.getDatesInMonth


{-| Returns the difference in days between two [Dates](Calendar#Date). We can have a negative difference of days as can be seen in the examples below.

    -- past   == 24 Aug 2019
    -- future == 26 Aug 2019
    getDayDiff past future -- 2  : Int

    getDayDiff future past -- -2 : Int

-}
getDayDiff : Date -> Date -> Int
getDayDiff =
    Internal.getDayDiff


{-| Returns a list with all the following months in a Calendar Year based on the `Month` argument provided.
The resulting list **will not include** the given `Month`.

    getFollowingMonths Aug -- [ Sep, Oct, Nov, Dec ] : List Month

    getFollowingMonths Dec -- [] : List Month

-}
getFollowingMonths : Month -> List Month
getFollowingMonths =
    Internal.getFollowingMonths


{-| Returns a list with all the preceding months in a Calendar Year based on the `Month` argument provided.
The resulting list **will not include** the given `Month`.

    getPrecedingMonths May -- [ Jan, Feb, Mar, Apr ] : List Month

    getPrecedingMonths Jan -- [] : List Month

-}
getPrecedingMonths : Month -> List Month
getPrecedingMonths =
    Internal.getPrecedingMonths


{-| Returns the weekday of a specific [Date](Calendar#Date).

    -- date == 26 Aug 2019
    getWeekday date -- Mon : Weekday

-}
getWeekday : Date -> Time.Weekday
getWeekday =
    Internal.getWeekday


{-| Checks if the `Year` part of the given [Date](Calendar#Date) is a leap year.

    -- date  == 25 Dec 2019
    isLeapYear date -- False

    -- date2 == 25 Dec 2020
    isLeapYear date2 -- True

-}
isLeapYear : Date -> Bool
isLeapYear =
    Internal.isLeapYear << Internal.getYear


{-| Sorts incrementally a list of [Dates](Calendar#Date).

    -- past   == 26 Aug 1920
    -- epoch  == 1 Jan 1970
    -- future == 25 Dec 2020

    sort [ future, past, epoch ]
    -- [ 26 Aug 1920, 1 Jan 1970, 25 Dec 2020 ] : List Date

-}
sort : List Date -> List Date
sort =
    Internal.sort



-- Constants


{-| Returns a list of all the `Months` in Calendar order.
-}
months : Array Month
months =
    Internal.months


{-| Returns the milliseconds in a day.
-}
millisInADay : Int
millisInADay =
    Internal.millisInADay
