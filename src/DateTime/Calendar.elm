module DateTime.Calendar exposing
    ( Date, RawDate
    , fromRawParts
    , toMillis, monthToInt
    , getDay, getMonth, getYear
    , setDay, setMonth, setYear
    , incrementDay, incrementMonth, incrementYear
    , decrementDay, decrementMonth, decrementYear
    , compare
    , getDateRange, getDatesInMonth, getDayDiff, getFollowingMonths, getPrecedingMonths, getWeekday, isLeapYear, sort
    , months, millisInADay
    )

{-| A calendar date.


# Type definition

@docs Date, RawDate


# Creating values

@docs fromRawParts


# Converters

@docs toMillis, monthToInt


# Accessors

@docs getDay, getMonth, getYear


# Setters

@docs setDay, setMonth, setYear


# Incrementers

@docs incrementDay, incrementMonth, incrementYear


# Decrementers

@docs decrementDay, decrementMonth, decrementYear


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


{-| A full (Gregorian) calendar date.
-}
type alias Date =
    Internal.Date


type alias RawDate =
    Internal.RawDate



-- Constructors


{-| Construct a `Date` from its (raw) constituent parts.
Returns `Nothing` if any parts or their combination would form an invalid date.

> fromRawParts { day = 11, month = Dec, year = 2018 }
> Just (Date { day = Day 11, month = Dec, year = Year 2018 }) : Maybe Date
>
> fromRawParts { day = 29, month = Feb, year = 2019 }
> Nothing : Maybe Date
>
> fromRawParts { day = 29, month = Feb, year = 2020 }
> Just (Date { day = Day 29, month = Feb, year = Year 2020 }) : Maybe Date

-}
fromRawParts : RawDate -> Maybe Date
fromRawParts =
    Internal.fromRawParts



-- Converters


{-| Transforms a 'Date' into milliseconds
-}
toMillis : Date -> Int
toMillis =
    Internal.toMillis


{-| Convert a given month to an integer starting from 1.

> monthToInt Jan
> 1 : Int
>
> monthToInt Aug
> 8 : Int

-}
monthToInt : Month -> Int
monthToInt =
    Internal.monthToInt



-- Accessors


{-| Extract the `Year` part of a `Date`.

> getYear (fromPosix (Time.millisToPosix 0))
> Year 1970 : Year

-}
getYear : Date -> Int
getYear =
    Internal.yearToInt << Internal.getYear


{-| Extract the `Month` part of a `Date`.

> getMonth (fromPosix (Time.millisToPosix 0))
> Jan : Month

-}
getMonth : Date -> Month
getMonth =
    Internal.getMonth


{-| Extract the `Day` part of a `Date`.

> getDay (fromPosix (Time.millisToPosix 0))
> Day 1 : Day

-}
getDay : Date -> Int
getDay =
    Internal.dayToInt << Internal.getDay



-- Setters


{-| Attempts to set the 'Year' on an existing date
-}
setYear : Int -> Date -> Maybe Date
setYear =
    Internal.setYear


{-| Attempts to set the 'Month' on an existing date
-}
setMonth : Month -> Date -> Maybe Date
setMonth =
    Internal.setMonth


{-| Attempts to set the 'Day' on an existing date
-}
setDay : Int -> Date -> Maybe Date
setDay =
    Internal.setDay



-- Incrementers


{-| Increments the 'Year' in a given 'Date' while preserving the month and
--- day where applicable.

> date = fromRawParts { day = 31, month = Jan, year = 2019 }
> incrementYear date
> Date { day = Day 31, month = Jan, year = Year 2020 }
>
> date2 = fromRawParts { day = 29, month = Feb, year = 2020 }
> incrementYear date2
> Date { day = Day 28, month = Feb, year = Year 2021 }
>
> date3 = fromRawParts { day = 28, month = Feb, year = 2019 }
> incrementYear date3
> Date { day = Day 28, month = Feb, year = Year 2020 }

--------------------- Note ---------------------
--- Here we cannot rely on transforming the date
--- to millis and adding a year because of the
--- edge case restrictions such as current year
--- might be a leap year and the given date may
--- contain the 29th of February but on the next
--- year, February would only have 28 days.

-}
incrementYear : Date -> Date
incrementYear =
    Internal.incrementYear


{-| Gets next month from the given date. It preserves the day and year as is (where applicable).
--- If the day of the given date is out of bounds for the next month
--- then we return the maxDay for that month.

> date = fromRawParts { day = 31, month = Dec, year = 2018 }
>
> incrementMonth date
> Date { day = Day 31, month = Jan, year = 2019 } : Date
>
> incrementMonth (incrementMonth date)
> Date { day = Day 28, month = Feb, year = 2019 } : Date

-}
incrementMonth : Date -> Date
incrementMonth =
    Internal.incrementMonth


{-| Increments the 'Day' in a given 'Date'. Will also increment 'Month' && 'Year'
--- if applicable.

> date = fromRawParts { day = 31, month = Dec, year = 2018 }
> incrementDay date
> Date { day = Day 1, month = Jan, year = Year 2019 }
>
> date2 = fromRawParts { day = 29, month = Feb, year = 2020 }
> incrementDay date2
> Date { day = Day 1, month = Mar, year = Year 2020 }
>
> date3 = fromRawParts { day = 24, month = Dec, year = 2018 }
> incrementDay date3
> Date { day = Day 25, month = Dec, year = Year 2018 }

--------------------- Note ---------------------
--- Its safe to get the next day by using milliseconds
--- here because we are responsible for transforming the
--- given date to millis and parsing it from millis.
--- The incrementYear + incrementMonth are totally different
--- and they both have respectively different edge cases
--- and implementations.

-}
incrementDay : Date -> Date
incrementDay =
    Internal.incrementDay



-- Decrementers


{-| Decrements the 'Year' in a given 'Date' while preserving the month and
--- day where applicable.

> date = fromRawParts { day = 31, month = Jan, year = 2019 }
> decrementYear date
> Date { day = Day 31, month = Jan, year = Year 2018 }
>
> date2 = fromRawParts { day = 29, month = Feb, year = 2020 }
> decrementYear date2
> Date { day = Day 28, month = Feb, year = Year 2019 }
>
> date3 = fromRawParts { day = 28, month = Feb, year = 2019 }
> decrementYear date3
> Date { day = Day 28, month = Feb, year = Year 2018 }

--------------------- Note ---------------------
--- Here we cannot rely on transforming the date
--- to millis and removing a year because of the
--- edge case restrictions such as current year
--- might be a leap year and the given date may
--- contain the 29th of February but on the previous
--- year, February would only have 28 days.

-}
decrementYear : Date -> Date
decrementYear =
    Internal.decrementYear


{-| Gets previous month from the given date. It preserves the day and year as is (where applicable).
--- If the day of the given date is out of bounds for the previous month then
--- we return the maxDay for that month.

> date = fromRawParts { day = 31, month = Jan, year = 2019 }
>
> decrementMonth date
> Date { day = Day 31, month = Dec, year = 2018 } : Date
>
> decrementMonth (decrementMonth date)
> Date { day = Day 30, month = Nov, year = 2018 } : Date

-}
decrementMonth : Date -> Date
decrementMonth =
    Internal.decrementMonth


{-| Decrements the 'Day' in a given 'Date'. Will also decrement 'Month' && 'Year'
--- if applicable.

> date = fromRawParts { day = 1, month = Jan, year = 2019 }
> decrementDay date
> Date { day = Day 31, month = Dec, year = Year 2018 }
>
> date2 = fromRawParts { day = 1, month = Mar, year = 2020 }
> decrementDay date2
> Date { day = Day 29, month = Feb, year = Year 2020 }
>
> date3 = fromRawParts { day = 26, month = Dec, year = 2018 }
> decrementDay date3
> Date { day = Day 25, month = Dec, year = Year 2018 }

--------------------- Note ---------------------
--- Its safe to get the previous day by using milliseconds
--- here because we are responsible for transforming the
--- given date to millis and parsing it from millis.
--- The decrementYear + decrementMonth are totally different
--- and they both have respectively different edge cases
--- and implementations.

-}
decrementDay : Date -> Date
decrementDay =
    Internal.decrementDay



-- Comparers


{-| Comparison on a Date level.
--- Compares two given dates and gives an Order

> date = (fromPosix (Time.millisToPosix 0)) -- 1 Jan 1970
> laterDate = (fromPosix (Time.millisToPosix 10000000000)) -- 26 Apr 1970

> compare date laterDate
> LT : Order
>
> compare laterDate date
> GT : Order
>
> compare laterDate date
> EQ : Order

-}
compare : Date -> Date -> Order
compare =
    Internal.compare



-- Utilities


{-| Returns a List of dates based on the start and end 'Dates' given as parameters.
--- The resulting list includes both the start and end 'Dates'.
--- In the case of startDate > endDate the resulting list would still be
--- a valid sorted date range list.

> startDate = fromRawParts { day = 25, month = Feb, year = 2020 }
> endDate = fromRawParts { day = 1, month = Mar, year = 2020 }
> getDateRange startDate endDate
> [ Date { day = Day 25, month = Feb, year = Year 2020 }
> , Date { day = Day 26, month = Feb, year = Year 2020 }
> , Date { day = Day 27, month = Feb, year = Year 2020 }
> , Date { day = Day 28, month = Feb, year = Year 2020 }
> , Date { day = Day 29, month = Feb, year = Year 2020 }
> , Date { day = Day 1, month = Mar, year = Year 2020 }
> ]
>
> startDate2 = fromRawParts { day = 25, month = Feb, year = 2019 }
> endDate2 = fromRawParts { day = 1, month = Mar, year = 2019 }
> getDateRange startDate2 endDate2
> [ Date { day = Day 25, month = Feb, year = Year 2019 }
> , Date { day = Day 26, month = Feb, year = Year 2019 }
> , Date { day = Day 27, month = Feb, year = Year 2019 }
> , Date { day = Day 28, month = Feb, year = Year 2019 }
> , Date { day = Day 1, month = Mar, year = Year 2019 }
> ]

-}
getDateRange : Date -> Date -> List Date
getDateRange =
    Internal.getDateRange


{-| Returns a list of 'Dates' for the given 'Year' and 'Month' combination.

> getDatesInMonth (Year 2018) Dec
> [ Date { day = Day 1, month = Dec, year = Year 2018 }
> , Date { day = Day 2, month = Dec, year = Year 2018 }
> , Date { day = Day 3, month = Dec, year = Year 2018 }
> , Date { day = Day 4, month = Dec, year = Year 2018 }
> , Date { day = Day 5, month = Dec, year = Year 2018 }
> ...
> , Date { day = Day 29, month = Dec, year = Year 2018 }
> , Date { day = Day 30, month = Dec, year = Year 2018 }
> , Date { day = Day 31, month = Dec, year = Year 2018 }
> ]

-}
getDatesInMonth : Date -> List Date
getDatesInMonth =
    Internal.getDatesInMonth


{-| Returns the number of days between two 'Dates'.
-}
getDayDiff : Date -> Date -> Int
getDayDiff =
    Internal.getDayDiff


{-| Gets the list of the following months from the given month.
--- It doesn't include the given month in the resulting list.

> getFollowingMonths Aug
> [ Sep, Oct, Nov, Dec ]
>
> getFollowingMonths Dec
> []

-}
getFollowingMonths : Month -> List Month
getFollowingMonths =
    Internal.getFollowingMonths


{-| Gets the list of the preceding months from the given month.
--- It doesn't include the given month in the resulting list.

> getPrecedingMonths Aug
> [ Jan, Feb, Mar, Apr, May, Jun, Jul ]
>
> getPrecedingMonths Jan
> []

-}
getPrecedingMonths : Month -> List Month
getPrecedingMonths =
    Internal.getPrecedingMonths


{-| Returns the weekday of a specific 'Date'

> date = fromRawParts { day = 29, month = Feb, year = 2020 }
> getWeekday date
> Sat : Time.Weekday
>
> date2 = fromRawParts { day = 25, month = Nov, year = 2018 }
> getWeekday date2
> Tue : Time.Weekday

-}
getWeekday : Date -> Time.Weekday
getWeekday =
    Internal.getWeekday


{-| Checks if the given year is a leap year.

> isLeapYear 2019
> False
>
> isLeapYear 2020
> True

-}
isLeapYear : Date -> Bool
isLeapYear =
    Internal.isLeapYear << Internal.getYear


{-| Sorts a List of Dates.
-}
sort : List Date -> List Date
sort =
    Internal.sort



-- Constants


{-| Returns a list of all the Months in Calendar order.
-}
months : Array Month
months =
    Internal.months


{-| Returns the milliseconds in a day.
-}
millisInADay : Int
millisInADay =
    Internal.millisInADay
