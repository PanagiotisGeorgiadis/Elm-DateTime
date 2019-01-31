module DateTime.Calendar exposing
    ( Date, Day, Month, Year, RawDate
    , fromPosix, fromRawYearMonthDay
    , getDay, getMonth, getYear
    , toMillis, toPosix, dayToInt, monthToInt, yearToInt
    , getNextDay, getNextMonth, incrementYear
    , getPreviousDay, getPreviousMonth, decrementYear
    , compareDates, isLeapYear, weekdayFromDate, getDatesInMonth, getDateRange, months, lastDayOf, getDayDiff
    , millisInADay
    )

{-| A calendar date.


# Type definition

@docs Date, Day, Month, Year, RawDate


# Creating values

@docs fromPosix, fromRawYearMonthDay


# Accessors

@docs getDay, getMonth, getYear


# Converters

@docs toMillis, toPosix, dayToInt, monthToInt, yearToInt


# Incrementers

@docs getNextDay, getNextMonth, incrementYear


# Decrementers

@docs getPreviousDay, getPreviousMonth, decrementYear


# Utilities

@docs compareDates, isLeapYear, weekdayFromDate, getDatesInMonth, getDateRange, months, lastDayOf, getDayDiff


# Constants

@docs millisInADay

-}

import Array exposing (Array)
import DateTime.Calendar.Internal as Internal
import Time


{-| A full (Gregorian) calendar date.
-}
type alias Date =
    Internal.Date


type alias Year =
    Internal.Year


type alias Month =
    Internal.Month


type alias Day =
    Internal.Day


type alias RawDate =
    Internal.RawDate


{-| Extract the `Year` part of a `Date`.

> getYear (fromPosix (Time.millisToPosix 0))
> Year 1970 : Year

-- Can be exposed

-}
getYear : Date -> Year
getYear =
    Internal.getYear


{-| Extract the Int value of a 'Year'.

> date = fromPosix (Time.millisToPosix 0)
> yearToInt (getYear date)
> 1970 : Int

-- Can be exposed

-}
yearToInt : Year -> Int
yearToInt =
    Internal.yearToInt


{-| Attempt to construct a 'Year' from an Int value.
--- Currently the validity of the year is based on
--- the integer being greater than zero. ( year > 0 )

> yearFromInt 1970
> Just (Year 1970) : Maybe Year
>
> yearFromInt -1
> Nothing : Maybe Year

-- Internal use only

-}
yearFromInt : Int -> Maybe Year
yearFromInt =
    Internal.yearFromInt


{-| Extract the `Month` part of a `Date`.

> getMonth (fromPosix (Time.millisToPosix 0))
> Jan : Month

-- Can be exposed

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

-- Can be exposed

-}
monthToInt : Month -> Int
monthToInt =
    Internal.monthToInt


{-| Attempt to construct a 'Month' from an Int value.
--- Currently the validity of the month is based on
--- the integer having a value between one and twelve. ( 1 ≥ month ≥ 12 )

> monthFromInt 1
> Just Jan : Maybe Month
>
> monthFromInt 12
> Just Dec : Maybe Month
>
> monthFromInt -1
> Nothing : Maybe Month

-- Internal, not to be exposed

-}
monthFromInt : Int -> Maybe Month
monthFromInt =
    Internal.monthFromInt


{-| Extract the `Day` part of a `Date`.

> getDay (fromPosix (Time.millisToPosix 0))
> Day 1 : Day

-- Can be exposed

-}
getDay : Date -> Day
getDay =
    Internal.getDay


{-| Extract the Int part of a 'Day'.

> date = fromPosix (Time.millisToPosix 0)
> dayToInt (getDay date)
> 1 : Int

-- Can be exposed

-}
dayToInt : Day -> Int
dayToInt =
    Internal.dayToInt


{-| Attempt to construct a 'Day' from an Int value.
--- Currently the validity of the day is based on
--- the validity of the 'Date' object being created.
--- This means that given a valid year & month we check
--- for the 'Date' max day. Then the given Int needs to be
--- greater than 0 and less than the max day for the given year && month.
--- ( 1 ≥ day ≥ maxValidDay )

> dayFromInt (Year 2018) Dec 25
> Just (Day 25) : Maybe Day
>
> dayFromInt (Year 2019) Feb 29
> Nothing : Maybe Day
>
> dayFromInt (Year 2020) Feb 29
> Just (Day 29) : Maybe Day

-- Internal, not to be exposed

-}
dayFromInt : Year -> Month -> Int -> Maybe Day
dayFromInt year month day =
    Internal.dayFromInt year month day


{-| Construct a `Date` from its constituent parts.
--- Returns `Nothing` if the combination would form an invalid date.

> fromYearMonthDay (Year 2018) Dec (Day 25)
> Just (Date { year = (Year 2018), month = Dec, day = (Day 25)})
>
> fromYearMonthDay (Year 2019) Feb (Day 29)
> Nothing
>
> fromYearMonthDay (Year 2020) Feb (Day 29)
> Just (Date { day = Day 29, month = Feb, year = Year 2020 }) : Maybe Date

-- Internal, not to be exposed

-}
fromYearMonthDay : Year -> Month -> Day -> Maybe Date
fromYearMonthDay y m d =
    Internal.fromYearMonthDay y m d


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

-- Can be exposed

-}
compareDates : Date -> Date -> Order
compareDates lhs rhs =
    Internal.compareDates lhs rhs


{-| Comparison on a Day level.
--- Compares two given days and gives an Order

> compareDays (Day 28) (Day 29)
> LT : Order
>
> compareDays (Day 28) (Day 15)
> GT : Order
>
> compareDays (Day 15) (Day 15)
> EQ : Order

-- Internal, not to be exposed

-}
compareDays : Day -> Day -> Order
compareDays lhs rhs =
    Internal.compareDays lhs rhs


{-| Comparison on a Month level.
--- Compares two given months and gives an Order

> compareMonths Jan Feb
> LT : Order
>
> compareMonths Dec Feb
> GT : Order
>
> compareMonths Aug Aug
> EQ : Order

-- Internal, not to be exposed

-}
compareMonths : Month -> Month -> Order
compareMonths lhs rhs =
    Internal.compareMonths lhs rhs


{-| Comparison on a Year level.
--- Compares two given years and gives an Order

> compareYears 2016 2017
> LT : Order
>
> compareYears 2017 2016
> GT : Order
>
> compareYears 2015 2015
> EQ : Order

-- Internal, not to be exposed

-}
compareYears : Year -> Year -> Order
compareYears lhs rhs =
    Internal.compareYears lhs rhs


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

-- Can be exposed.

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

-- Internal, not to be exposed

-}
fromRawDay : Year -> Month -> Int -> Maybe Date
fromRawDay year month rawDay =
    Internal.fromRawDay year month rawDay


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

-- Internal, not to be exposed

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

-- Can Be Exposed

-}
getNextMonth : Date -> Date
getNextMonth =
    Internal.getNextMonth


{-| Gets next month from the given month.

> getNextMonth\_ Dec
> Jan : Month
>
> getNextMonth\_ Nov
> Dec : Month

-- Internal, not to be exposed

-}
getNextMonth_ : Month -> Month
getNextMonth_ =
    Internal.getNextMonth_


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

-- Can Be Exposed

-}
getPreviousMonth : Date -> Date
getPreviousMonth =
    Internal.getPreviousMonth


{-| Gets next month from the given month.

> getNextMonth\_ Jan
> Dec : Month
>
> getNextMonth\_ Dec
> Nov : Month

-- Internal, not to be exposed

-}
getPreviousMonth_ : Month -> Month
getPreviousMonth_ =
    Internal.getPreviousMonth_


{-| Gets the list of the preceding months from the given month.
--- It doesn't include the given month in the resulting list.

> getPrecedingMonths Aug
> [ Jan, Feb, Mar, Apr, May, Jun, Jul ]
>
> getPrecedingMonths Jan
> []

-- Internal, not to be exposed

-}
getPrecedingMonths : Month -> List Month
getPrecedingMonths =
    Internal.getPrecedingMonths


{-| Gets the list of the following months from the given month.
--- It doesn't include the given month in the resulting list.

> getFollowingMonths Aug
> [ Sep, Oct, Nov, Dec ]
>
> getFollowingMonths Dec
> []

-- Internal, not to be exposed

-}
getFollowingMonths : Month -> List Month
getFollowingMonths =
    Internal.getFollowingMonths


{-| Get a UTC `Date` from a time zone and posix time.

> fromPosix (Time.millisToPosix 0)
> Date { day = Day 1, month = Jan, year = Year 1970 } : Date

-- Can Be Exposed

-}
fromPosix : Time.Posix -> Date
fromPosix =
    Internal.fromPosix


{-| Checks if the given year is a leap year.

> isLeapYear 2019
> False
>
> isLeapYear 2020
> True

-- Can Be Exposed

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

-- Can be exposed

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

-- Can be exposed

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

-- Can be exposed

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


{-| Transforms a 'Date' to a Posix time.

-- Can be exposed

-}
toPosix : Date -> Time.Posix
toPosix =
    Internal.toPosix


{-| Transforms a 'Date' into milliseconds
-}
toMillis : Date -> Int
toMillis =
    Internal.toMillis


{-| Returns the milliseconds in a day.
-}
millisInADay : Int
millisInADay =
    1000 * 60 * 60 * 24


{-| Returns the milliseconds in a year.

-- Internal, not to be exposed

-}
millisInYear : Year -> Int
millisInYear =
    Internal.millisInYear


{-| Returns the year milliseconds since epoch.
--- This function is intended to be used along with millisSinceStartOfTheYear
--- and millisSinceStartOfTheMonth.

> millisSinceEpoch (Year 1970)
> 0
>
> millisSinceEpoch (Year 1971)
> 31536000000

-- Internal, not to be exposed

-}
millisSinceEpoch : Year -> Int
millisSinceEpoch =
    Internal.millisSinceEpoch


{-| Returns the month milliseconds since the start of a given year.
--- This function is intended to be used along with millisSinceEpoch
--- and millisSinceStartOfTheMonth.

> millisSinceStartOfTheYear (Year 2018) Time.Jan
> 0 : Int
>
> millisSinceStartOfTheYear (Year 2018) Time.Dec
> 28857600000 : Int

-- Internal, not to be exposed

-}
millisSinceStartOfTheYear : Year -> Month -> Int
millisSinceStartOfTheYear year month =
    Internal.millisSinceStartOfTheYear year month


{-| Returns the day milliseconds since the start of a given month.
--- This function is intended to be used along with millisSinceEpoch
--- and millisSinceStartOfTheYear.

> millisSinceStartOfTheMonth (Day 1)
> 0 : Int
>
> millisSinceStartOfTheMonth (Day 15)
> 1209600000 : Int

-- Internal, not to be exposed

-}
millisSinceStartOfTheMonth : Day -> Int
millisSinceStartOfTheMonth =
    Internal.millisSinceStartOfTheMonth


{-| Returns the weekday of a specific 'Date'

> date = fromRawYearMonthDay { rawDay = 29, rawMonth = 2, rawYear = 2020 }
> weekdayFromDate date
> Sat : Time.Weekday
>
> date2 = fromRawYearMonthDay { rawDay = 25, rawMonth = 11, rawYear = 2018 }
> weekdayFromDate date2
> Tue : Time.Weekday

-- Can be exposed

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

-- Can be exposed

-}
getDatesInMonth : Year -> Month -> List Date
getDatesInMonth year month =
    Internal.getDatesInMonth year month


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

-- Can be exposed

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

-- Can be exposed

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

-- Can be exposed

-}
getDateRange : Date -> Date -> List Date
getDateRange startDate endDate =
    Internal.getDateRange startDate endDate


{-| Internal helper function for getDateRange.

-- Internal, not to be exposed

-}
getDateRange_ : Int -> Date -> List Date -> List Date
getDateRange_ daysCount prevDate res =
    Internal.getDateRange_ daysCount prevDate res


getDayDiff : Date -> Date -> Int
getDayDiff startDate endDate =
    Internal.getDayDiff startDate endDate
