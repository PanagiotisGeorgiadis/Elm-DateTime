module DateTime.Calendar exposing
    ( Date, RawDate
    , fromRawYearMonthDay
    , getDay, getMonth, getYear
    , toMillis, monthToInt
    , getNextDay, getNextMonth, incrementYear
    , getPreviousDay, getPreviousMonth, decrementYear
    , compareDates, isLeapYear, weekdayFromDate, getDatesInMonth, getDateRange, lastDayOf, getDayDiff
    , months, millisInADay
    )

{-| A calendar date.


# Type definition

@docs Date, Day, Month, Year, RawDate


# Creating values

@docs fromRawYearMonthDay


# Accessors

@docs getDay, getMonth, getYear


# Converters

@docs toMillis, monthToInt


# Incrementers

@docs getNextDay, getNextMonth, incrementYear


# Decrementers

@docs getPreviousDay, getPreviousMonth, decrementYear


# Utilities

@docs compareDates, isLeapYear, weekdayFromDate, getDatesInMonth, getDateRange, lastDayOf, getDayDiff


# Constants

@docs months, millisInADay

-}

import Array exposing (Array)
import DateTime.Calendar.Internal as Internal exposing (Day, Month, Year)
import Time


{-| A full (Gregorian) calendar date.
-}
type alias Date =
    Internal.Date


type alias RawDate =
    Internal.RawDate


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


{-| Extract the `Day` part of a `Date`.

> getDay (fromPosix (Time.millisToPosix 0))
> Day 1 : Day

-}
getDay : Date -> Int
getDay =
    Internal.dayToInt << Internal.getDay


{-| Comparison on a Date level.
--- Compares two given dates and gives an Order

> date = (fromPosix (Time.millisToPosix 0)) -- 1 Jan 1970
> laterDate = (fromPosix (Time.millisToPosix 10000000000)) -- 26 Apr 1970

> compareDates date laterDate
> LT : Order
>
> compareDates laterDate date
> GT : Order
>
> compareDates laterDate date
> EQ : Order

-}
compareDates : Date -> Date -> Order
compareDates lhs rhs =
    Internal.compareDates lhs rhs


{-| Construct a `Date` from its (raw) constituent parts.
Returns `Nothing` if any parts or their combination would form an invalid date.

> fromRawYearMonthDay { rawDay = 11, rawMonth = 12, rawYear = 2018 }
> Just (Date { day = Day 11, month = Dec, year = Year 2018 }) : Maybe Date
>
> fromRawYearMonthDay { rawDay = 29, rawMonth = 2, rawYear = 2019 }
> Nothing : Maybe Date
>
> fromRawYearMonthDay { rawDay = 29, rawMonth = 2, rawYear = 2020 }
> Just (Date { day = Day 11, month = Feb, year = Year 2020 }) : Maybe Date

-}
fromRawYearMonthDay : RawDate -> Maybe Date
fromRawYearMonthDay =
    Internal.fromRawYearMonthDay


{-| Construct a `Date` from its constituent Year and Month by using its raw day.
Returns `Nothing` if any parts or their combination would form an invalid date.

> fromRawDay (Year 2018) Dec 25
> Just (Date { day = Day 25, month = Dec, year = Year 2018 }) : Maybe Date
>
> fromRawDay (Year 2019) Feb 29
> Nothing : Maybe Date
>
> fromRawDay (Year 2020) Feb 29
> Just (Date { day = Day 11, month = Feb, year = Year 2020 }) : Maybe Date

-}
months : Array Month
months =
    Internal.months


{-| Gets next month from the given date. It preserves the day and year as is (where applicable).
--- If the day of the given date is out of bounds for the next month
--- then we return the maxDay for that month.

> date = fromRawYearMonthDay { rawDay = 31, rawMonth = 12 rawYear = 2018 }
>
> getNextMonth date
> Date { day = Day 31, rawMonth = 1, rawYear = 2019 } : Date
>
> getNextMonth (getNextMonth date)
> Date { day = Day 28, rawMonth = 28, rawYear = 2019 } : Date

-}
getNextMonth : Date -> Date
getNextMonth =
    Internal.getNextMonth


{-| Gets previous month from the given date. It preserves the day and year as is (where applicable).
--- If the day of the given date is out of bounds for the previous month then
--- we return the maxDay for that month.

> date = fromRawYearMonthDay { rawDay = 31, rawMonth = 1 rawYear = 2019 }
>
> getPreviousMonth date
> Date { day = Day 31, rawMonth = 12, rawYear = 2018 } : Date
>
> getNextMonth (getNextMonth date)
> Date { day = Day 30, rawMonth = 11, rawYear = 2018 } : Date

-}
getPreviousMonth : Date -> Date
getPreviousMonth =
    Internal.getPreviousMonth


{-| Checks if the given year is a leap year.

> isLeapYear 2019
> False
>
> isLeapYear 2020
> True

-}
isLeapYear : Year -> Bool
isLeapYear =
    Internal.isLeapYear


{-| Get the last day of the given `Year` and `Month`.

> lastDayOf (Year 2018) Dec
> 31
>
> lastDayOf (Year 2019) Feb
> 28
>
> lastDayOf (Year 2020) Feb
> 29

-}
lastDayOf : Year -> Month -> Day
lastDayOf year month =
    Internal.lastDayOf year month


{-| Increments the 'Year' in a given 'Date' while preserving the month and
--- day where applicable.

> date = fromRawYearMonthDay { rawDay = 31, rawMonth = 1 rawYear = 2019 }
> incrementYear date
> Date { day = Day 31, month = Jan, year = Year 2020 }
>
> date2 = fromRawYearMonthDay { rawDay = 29, rawMonth = 2, rawYear 2020 }
> incrementYear date2
> Date { day = Day 28, month = Feb, year = Year 2021 }
>
> date3 = fromRawYearMonthDay { rawDay = 28, rawMonth = 2, rawYear 2019 }
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


{-| Decrements the 'Year' in a given 'Date' while preserving the month and
--- day where applicable.

> date = fromRawYearMonthDay { rawDay = 31, rawMonth = 1 rawYear = 2019 }
> decrementYear date
> Date { day = Day 31, month = Jan, year = Year 2018 }
>
> date2 = fromRawYearMonthDay { rawDay = 29, rawMonth = 2, rawYear 2020 }
> decrementYear date2
> Date { day = Day 28, month = Feb, year = Year 2019 }
>
> date3 = fromRawYearMonthDay { rawDay = 28, rawMonth = 2, rawYear 2019 }
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


{-| Transforms a 'Date' into milliseconds
-}
toMillis : Date -> Int
toMillis =
    Internal.toMillis


{-| Returns the milliseconds in a day.
-}
millisInADay : Int
millisInADay =
    Internal.millisInADay


{-| Returns the weekday of a specific 'Date'

> date = fromRawYearMonthDay { rawDay = 29, rawMonth = 2, rawYear = 2020 }
> weekdayFromDate date
> Sat : Time.Weekday
>
> date2 = fromRawYearMonthDay { rawDay = 25, rawMonth = 11, rawYear = 2018 }
> weekdayFromDate date2
> Tue : Time.Weekday

-}
weekdayFromDate : Date -> Time.Weekday
weekdayFromDate =
    Internal.weekdayFromDate


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


{-| Increments the 'Day' in a given 'Date'. Will also increment 'Month' && 'Year'
--- if applicable.

> date = fromRawYearMonthDay { rawDay = 31, rawMonth = 12, rawYear = 2018 }
> getNextDay date
> Date { day = Day 1, month = Jan, year = Year 2019 }
>
> date2 = fromRawYearMonthDay { rawDay = 29, rawMonth = 2, rawYear 2020 }
> getNextDay date2
> Date { day = Day 1, month = Mar, year = Year 2020 }
>
> date3 = fromRawYearMonthDay { rawDay = 24, rawMonth = 12, rawYear 2018 }
> getNextDay date3
> Date { day = Day 25, month = Dec, year = Year 2018 }

--------------------- Note ---------------------
--- Its safe to get the next day by using milliseconds
--- here because we are responsible for transforming the
--- given date to millis and parsing it from millis.
--- The getNextYear + getNextMonth are totally different
--- and they both have respectively different edge cases
--- and implementations.

-}
getNextDay : Date -> Date
getNextDay =
    Internal.getNextDay


{-| Decrements the 'Day' in a given 'Date'. Will also decrement 'Month' && 'Year'
--- if applicable.

> date = fromRawYearMonthDay { rawDay = 1, rawMonth = 1, rawYear = 2019 }
> getPreviousDay date
> Date { day = Day 31, month = Dec, year = Year 2018 }
>
> date2 = fromRawYearMonthDay { rawDay = 1, rawMonth = 3, rawYear 2020 }
> getPreviousDay date2
> Date { day = Day 29, month = Feb, year = Year 2020 }
>
> date3 = fromRawYearMonthDay { rawDay = 26, rawMonth = 12, rawYear 2018 }
> getPreviousDay date3
> Date { day = Day 25, month = Dec, year = Year 2018 }

--------------------- Note ---------------------
--- Its safe to get the previous day by using milliseconds
--- here because we are responsible for transforming the
--- given date to millis and parsing it from millis.
--- The getNextYear + getNextMonth are totally different
--- and they both have respectively different edge cases
--- and implementations.

-}
getPreviousDay : Date -> Date
getPreviousDay =
    Internal.getPreviousDay


{-| Returns a List of dates based on the start and end 'Dates' given as parameters.
--- The resulting list includes both the start and end 'Dates'.
--- In the case of startDate > endDate the resulting list would still be
--- a valid sorted date range list.

> startDate = fromRawYearMonthDay { rawDay = 25, rawMonth = 2, rawYear = 2020 }
> endDate = fromRawYearMonthDay { rawDay = 1, rawMonth = 3, rawYear = 2020 }
> getDateRange startDate endDate
> [ Date { day = Day 25, month = Feb, year = Year 2020 }
> , Date { day = Day 26, month = Feb, year = Year 2020 }
> , Date { day = Day 27, month = Feb, year = Year 2020 }
> , Date { day = Day 28, month = Feb, year = Year 2020 }
> , Date { day = Day 29, month = Feb, year = Year 2020 }
> , Date { day = Day 1, month = Mar, year = Year 2020 }
> ]
>
> startDate2 = fromRawYearMonthDay { rawDay = 25, rawMonth = 2, rawYear = 2019 }
> endDate2 = fromRawYearMonthDay { rawDay = 1, rawMonth = 3, rawYear = 2019 }
> getDateRange startDate2 endDate2
> [ Date { day = Day 25, month = Feb, year = Year 2019 }
> , Date { day = Day 26, month = Feb, year = Year 2019 }
> , Date { day = Day 27, month = Feb, year = Year 2019 }
> , Date { day = Day 28, month = Feb, year = Year 2019 }
> , Date { day = Day 1, month = Mar, year = Year 2019 }
> ]

-}
getDateRange : Date -> Date -> List Date
getDateRange startDate endDate =
    Internal.getDateRange startDate endDate


getDayDiff : Date -> Date -> Int
getDayDiff startDate endDate =
    Internal.getDayDiff startDate endDate
