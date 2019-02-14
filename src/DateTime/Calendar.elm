module DateTime.Calendar exposing
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

{-| The `Calendar` module was introduced in order to keep track of the `Calendar Date` concept.
It has no knowledge of `Time` therefore it can only represent a [Date](DateTime-Calendar#Date)
which consists of a `Day`, a `Month` and a `Year`. You can construct a `Calendar Date` either
from a [Posix](https://package.elm-lang.org/packages/elm/time/latest/Time#Posix) time or by
using its [Raw constituent parts](DateTime-Calendar#RawDate). You can use a `Date` and the
Calendar's utilities as a standalone or you can combine a `Date` and a `Time` in order to
get a `DateTime` which can then be converted into a [Posix](https://package.elm-lang.org/packages/elm/time/latest/Time#Posix) time.


# Type definition

@docs Date, RawDate


# Creating values

@docs fromPosix, fromRawParts


# Converters

@docs toMillis, monthToInt


# Accessors

@docs getYear, getMonth, getDay


# Setters

@docs setYear, setMonth, setDay


# Incrementers

@docs incrementYear, incrementMonth, incrementDay


# Decrementers

@docs decrementYear, decrementMonth, decrementDay


# Comparers

@docs compare


# Utilities

@docs getDateRange, getDatesInMonth, getDayDiff, getFollowingMonths, getPrecedingMonths, getWeekday, isLeapYear, sort


# Constants

@docs months, millisInADay

-}

import Array exposing (Array)
import DateTime.Calendar.Internal as Internal
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



-- Constructors


{-| Construct a [Date](DateTime-Calendar#Date) from a [Posix](https://package.elm-lang.org/packages/elm/time/latest/Time#Posix) time.
You can construct a `Posix` time from milliseconds using the [millisToPosix](https://package.elm-lang.org/packages/elm/time/latest/Time#millisToPosix)
function located in the [elm/time](https://package.elm-lang.org/packages/elm/time/latest/) package.

    fromPosix (Time.millisToPosix 0)
    -- Date { day = Day 1, month = Jan, year = Year 1970 }

    fromPosix (Time.millisToPosix 1566795954000)
    -- Date { day = Day 26, month = Aug, year = Year 2019 }

    fromPosix (Time.millisToPosix 1566777600000)
    -- Date { day = Day 26, month = Aug, year = Year 2019 }

Notice that in the second and third examples the timestamps that are used are different but the resulting [Dates](DateTime-Calendar#Date) are identical.
This is because the [Calendar](DateTime-Calendar) module doesn't have any knowledge of `Time` which means that if we attempt to convert both of these dates back [toMillis](DateTime-Calendar#toMillis)
they will result in the same milliseconds. It is recommended using the [fromPosix](DateTime-DateTime#fromPosix) function provided in the [DateTime](DateTime-DateTime)
module if you need to preserve both `Date` and `Time`.

-}
fromPosix : Time.Posix -> Date
fromPosix =
    Internal.fromPosix


{-| Attempt to construct a [Date](DateTime-Calendar#Date) from its (raw) constituent parts.
Returns `Nothing` if any parts or their combination would form an invalid date.

    fromRawParts { day = 25, month = Dec, year = 2019 }
    -- Just (Date { day = Day 25, month = Dec, year = Year 2019 })

    fromRawParts { day = 29, month = Feb, year = 2019 }
    -- Nothing

-}
fromRawParts : RawDate -> Maybe Date
fromRawParts =
    Internal.fromRawParts



-- Converters


{-| Transforms a [Date](DateTime-Calendar#Date) into milliseconds.

    date = fromRawParts { day = 25, month = Dec, year = 2019 }
    Maybe.map toMillis date
    -- Just 1577232000000

    want = 1566795954000
    got = toMillis (fromPosix (Time.millisToPosix want))
    want == got -- False

Notice that transforming a **date** to milliseconds will always get you midnight hours.
The first example above will return a timestamp that equals to **Wed 25th of December 2019 00:00:00.000**
and the second example will return a timestamp that equals to **26th of August 2019 00:00:00.000** even though
the timestamp we provided in the [fromPosix](DateTime-Calendar#fromPosix) was equal to **26th of August 2019 05:05:54.000**

-}
toMillis : Date -> Int
toMillis =
    Internal.toMillis


{-| Convert a given [Month](https://package.elm-lang.org/packages/elm/time/latest/Time#Month) to an integer starting from 1.

    monthToInt Jan -- 1

    monthToInt Aug -- 8

-}
monthToInt : Month -> Int
monthToInt =
    Internal.monthToInt



-- Accessors


{-| Extract the `Year` part of a [Date](DateTime-Calendar#Date).

    -- date == 25th December 2019
    getYear date -- 2019

-}
getYear : Date -> Int
getYear =
    Internal.yearToInt << Internal.getYear


{-| Extract the `Month` part of a [Date](DateTime-Calendar#Date).

    date = fromRawParts { day = 25, month = Dec, year = 2019 }
    Maybe.map getMonth date -- Just Dec

-}
getMonth : Date -> Month
getMonth =
    Internal.getMonth


{-| Extract the `Day` part of a [Date](DateTime-Calendar#Date).

    date = fromRawParts { day = 25, month = Dec, year = 2019 }
    Maybe.map getDay date -- Just 25

-}
getDay : Date -> Int
getDay =
    Internal.dayToInt << Internal.getDay



-- Setters


{-| Attempts to set the `Year` part of a [Date](DateTime-Calendar#Date).

    date = fromRawParts { day = 29, month = Feb, year = 2020 }

    Maybe.andThen (setYear 2024) date -- Just (Date { day = Day 29, month = Feb, year = Year 2024 })
    Maybe.andThen (setYear 2019) date -- Nothing

-}
setYear : Int -> Date -> Maybe Date
setYear =
    Internal.setYear


{-| Attempts to set the `Month` part of a [Date](DateTime-Calendar#Date).

    date = fromRawParts { day = 31, month = Jan, year = 2019 }

    Maybe.andThen (setMonth Aug) date -- Just (Date { day = Day 31, month = Aug, year = Year 2019 })
    Maybe.andThen (setMonth Apr) date -- Nothing

-}
setMonth : Month -> Date -> Maybe Date
setMonth =
    Internal.setMonth


{-| Attempts to set the `Day` part of a [Date](DateTime-Calendar#Date).

    date = fromRawParts { day = 31, month = Jan, year = 2019 }

    Maybe.andThen (setDay 25) date -- Just (Date { day = Day 25, month = Jan, year = 2019 })
    Maybe.andThen (setDay 32) date -- Nothing

-}
setDay : Int -> Date -> Maybe Date
setDay =
    Internal.setDay



-- Incrementers


{-| Increments the `Year` in a given [Date](DateTime-Calendar#Date) while preserving the `Month` and `Day` parts.

    date = fromRawParts { day = 31, month = Jan, year = 2019 }
    Maybe.map incrementYear date -- Just (Date { day = Day 31, month = Jan, year = Year 2020 })

    date2 = fromRawParts { day = 29, month = Feb, year = 2020 }
    Maybe.map incrementYear date2 -- Just (Date { day = Day 28, month = Feb, year = Year 2021 })

**Note:** In the first example, incrementing the `Year` causes no changes in the `Month` and `Day` parts.
On the second example we see that the `Day` part is different than the input. This is because the resulting date
would be an invalid date ( _**29th of February 2021**_ ). As a result of this scenario we fall back to the last valid day
of the given `Month` and `Year` combination.

-}
incrementYear : Date -> Date
incrementYear =
    Internal.incrementYear


{-| Increments the `Month` in a given [Date](DateTime-Calendar#Date). It will also roll over to the next year where applicable.

    date = fromRawParts { day = 15, month = Sep, year = 2019 }
    Maybe.map incrementMonth date -- Just (Date { day = Day 15, month = Oct, year = Year 2019 })

    date2 = fromRawParts { day = 15, month = Dec, year = 2019 }
    Maybe.map incrementMonth date2 -- Just (Date { day = Day 15, month = Jan, year = Year 2020 })

    date3 = fromRawParts { day = 31, month = Jan, year = 2019 }
    Maybe.map incrementMonth date3 -- Just (Date { day = 28, month = Feb, year = Year 2019 })

**Note:** In the first example, incrementing the `Month` causes no changes in the `Year` and `Day` parts while on the second
example it rolls forward the 'Year'. On the last example we see that the `Day` part is different than the input. This is because
the resulting date would be an invalid one ( _**31st of February 2019**_ ). As a result of this scenario we fall back to the last
valid day of the given `Month` and `Year` combination.

-}
incrementMonth : Date -> Date
incrementMonth =
    Internal.incrementMonth


{-| Increments the `Day` in a given [Date](DateTime-Calendar#Date). Will also increment `Month` and `Year` where applicable.

    date = fromRawParts { day = 25, month = Aug, year = 2019 }
    Maybe.map incrementDay date -- Just (Date { day = 26, month = Aug, year = Year 2019 })

    date2 = fromRawParts { day = 31, month = Dec, year = 2019 }
    Maybe.map incrementDay date2 -- Just (Date { day = 1, month = Jan, year = Year 2020 })

-}
incrementDay : Date -> Date
incrementDay =
    Internal.incrementDay



-- Decrementers


{-| Decrements the `Year` in a given [Date](DateTime-Calendar#Date) while preserving the `Month` and `Day` parts.

    date = fromRawParts { day = 31, month = Jan, year = 2019 }
    Maybe.map decrementYear date -- Just (Date { day = Day 31, month = Jan, year = Year 2018 })

    date2 = fromRawParts { day = 29, month = Feb, year = 2020 }
    Maybe.map decrementYear date2 -- Just (Date { day = Day 28, month = Feb, year = Year 2019 })

**Note:** In the first example, decrementing the `Year` causes no changes in the `Month` and `Day` parts.
On the second example we see that the `Day` part is different than the input. This is because the resulting date
would be an invalid date ( _**29th of February 2019**_ ). As a result of this scenario we fall back to the last
valid day of the given `Month` and `Year` combination.

-}
decrementYear : Date -> Date
decrementYear =
    Internal.decrementYear


{-| Decrements the `Month` in a given [Date](DateTime-Calendar#Date). It will also roll backwards to the previous year where applicable.

    date = fromRawParts { day = 15, month = Sep, year = 2019 }
    Maybe.map decrementMonth date -- Just (Date { day = Day 15, month = Aug, year = Year 2019 })

    date2 = fromRawParts { day = 15, month = Jan, year = 2020 }
    Maybe.map decrementMonth date2 -- Just (Date { day = Day 15, month = Dec, year = Year 2019 })

    date3 = fromRawParts { day = 31, month = Dec, year = 2019 }
    Maybe.map decrementMonth date3 -- Just (Date { day = Day 30, month = Nov, year = Year 2019 })

**Note:** In the first example, decrementing the `Month` causes no changes in the `Year` and `Day` parts while
on the second example it rolls backwards the `Year`. On the last example we see that the `Day` part is different
than the input. This is because the resulting date would be an invalid one ( _**31st of November 2019**_ ). As a result
of this scenario we fall back to the last valid day of the given `Month` and `Year` combination.

-}
decrementMonth : Date -> Date
decrementMonth =
    Internal.decrementMonth


{-| Decrements the `Day` in a given [Date](DateTime-Calendar#Date). Will also decrement `Month` and `Year` where applicable.

    date = fromRawParts { day = 27, month = Aug, year = 2019 }
    Maybe.map decrementDay date -- Just (Date { day = Day 26, month = Aug, year = Year 2019 })

    date2 = fromRawParts { day = 1, month = Jan, year = 2020 }
    Maybe.map decrementDay date2 -- Just (Date { day = Day 31, month = Dec, year = Year 2019 })

-}
decrementDay : Date -> Date
decrementDay =
    Internal.decrementDay



-- Comparers


{-| Compares the two given [Dates](DateTime-Calendar#Date) and returns an [Order](https://package.elm-lang.org/packages/elm/core/latest/Basics#Order).

    past = fromRawParts { day = 25, month = Aug, year = 2019 }
    future = fromRawParts { day = 26, month = Aug, year = 2019 }

    Maybe.map2 compare past past   -- Just EQ
    Maybe.map2 compare past future -- Just LT
    Maybe.map2 compare future past -- Just GT

-}
compare : Date -> Date -> Order
compare =
    Internal.compare



-- Utilities


{-| Returns an incrementally sorted [Date](DateTime-Calendar#Date) list based on the **start** and **end** date parameters.
_**The resulting list will include both start and end dates**_.

    start = fromRawParts { day = 26, month = Feb, year = 2020 }
    end = fromRawParts { day = 1, month = Mar, year = 2020 }

    Maybe.map2 getDateRange start end
    -- Just
    --   [ Date { day = Day 26, month = Feb, year = Year 2020 }
    --   , Date { day = Day 27, month = Feb, year = Year 2020 }
    --   , Date { day = Day 28, month = Feb, year = Year 2020 }
    --   , Date { day = Day 29, month = Feb, year = Year 2020 }
    --   , Date { day = Day 1, month = Mar, year = Year 2020 }
    --   ]

-}
getDateRange : Date -> Date -> List Date
getDateRange =
    Internal.getDateRange


{-| Returns a list of [Dates](DateTime-Calendar#Date) for the given `Year` and `Month` combination.

    date = fromRawParts { day = 26, month = Aug, year = 2019 }
    Maybe.map getDatesInMonth date

    -- Just
    --   [ Date { day = 1, month = Aug, year = Year 2020 }
    --   , Date { day = 2, month = Aug, year = Year 2020 }
    --   , Date { day = 3, month = Aug, year = Year 2020 }
    --   ...
    --   , Date { day = 29, month = Aug, year = Year 2020 }
    --   , Date { day = 30, month = Aug, year = Year 2020 }
    --   , Date { day = 31, month = Aug, year = Year 2020 }
    --   ]

-}
getDatesInMonth : Date -> List Date
getDatesInMonth =
    Internal.getDatesInMonth


{-| Returns the difference in days between two [Dates](DateTime-Calendar#Date). We can have a negative difference of days as can be seen in the examples below.

    past = fromRawParts { day = 24, month = Aug, year = 2019 }
    future = fromRawParts { day = 26, month = Aug, year = 2019 }

    Maybe.map2 getDayDiff past future -- Just 2
    Maybe.map2 getDayDiff future past -- Just -2

-}
getDayDiff : Date -> Date -> Int
getDayDiff =
    Internal.getDayDiff


{-| Returns a list with all the following months in a Calendar Year based on the `Month` argument provided.
The resulting list **will not include** the given `Month`.

    getFollowingMonths Aug -- [ Sep, Oct, Nov, Dec ]

    getFollowingMonths Dec -- []

-}
getFollowingMonths : Month -> List Month
getFollowingMonths =
    Internal.getFollowingMonths


{-| Returns a list with all the preceding months in a Calendar Year based on the `Month` argument provided.
The resulting list **will not include** the given `Month`.

    getPrecedingMonths May -- [ Jan, Feb, Mar, Apr ]

    getPrecedingMonths Jan -- []

-}
getPrecedingMonths : Month -> List Month
getPrecedingMonths =
    Internal.getPrecedingMonths


{-| Returns the weekday of a specific [Date](DateTime-Calendar#Date).

    date = fromRawParts { day = 26, month = Aug, year = 2019 }
    Maybe.map getWeekday date -- Just Mon

-}
getWeekday : Date -> Time.Weekday
getWeekday =
    Internal.getWeekday


{-| Checks if the `Year` part of the given [Date](DateTime-Calendar#Date) is a leap year.

    date = fromRawParts { day = 25, month = Dec, year = 2019 }
    Maybe.map isLeapYear date -- Just False

    date2 = fromRawParts { day = 25, month = Dec, year = 2020 }
    Maybe.map isLeapYear date2 -- Just True

-}
isLeapYear : Date -> Bool
isLeapYear =
    Internal.isLeapYear << Internal.getYear


{-| Sorts incrementally a list of [Dates](DateTime-Calendar#Date).

    past = fromRawParts { day = 26, month = Aug, year = 1920 }
    epoch = fromRawParts { day = 1, month = Jan, year = 1970 }
    future = fromRawParts { day = 25, month = Dec, year = 2020 }

    sort (List.filterMap identity [ future, past, epoch ])
    -- [ Date { day = Day 26, month = Aug, year = Year 1920 }
    -- , Date { day = Day 1, month = Jan, year = Year 1970 }
    -- , Date { day = Day 25, month = Dec, year = Year 2020 }
    -- ]

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
