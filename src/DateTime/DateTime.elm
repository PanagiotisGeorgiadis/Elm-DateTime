module DateTime.DateTime exposing
    ( DateTime
    , fromPosix, fromRawParts, fromDateAndTime
    , toPosix, toMillis
    , getYear, getMonth, getDay, getWeekday, getHours, getMinutes, getSeconds, getMilliseconds
    , getDateRange, getDatesInMonth
    , incrementYear, incrementMonth, incrementDay
    , decrementYear, decrementMonth, decrementDay
    , compareDates, compareTime
    )

{-| A complete datetime type.

@docs DateTime


# Creating a `DateTime`

@docs fromPosix, fromRawParts, fromDateAndTime


# Conversions

@docs toPosix, toMillis


# Accessors

@docs getYear, getMonth, getDay, getWeekday, getHours, getMinutes, getSeconds, getMilliseconds


# Calendar Accessors

@docs getDateRange, getDatesInMonth


# Incrementers

@docs incrementYear, incrementMonth, incrementDay, incrementHours, incrementMinutes, incrementSeconds, incrementMilliseconds


# Decrementers

@docs decrementYear, decrementMonth, decrementDay, decrementHours, decrementMinutes, decrementSeconds, decrementMilliseconds


# Utilities

@docs getDayDiff


# Comparers

@docs compareDates, compareTime

-}

import DateTime.Calendar as Calendar
import DateTime.Clock as Clock
import DateTime.DateTime.Internal as Internal
import Time


{-| An instant in time, composed of a calendar date, clock time and time zone.
-}
type alias DateTime =
    Internal.DateTime


{-| Create a `DateTime` from a time zone and posix time.

> fromPosix (Time.millisToPosix 0) |> year
> Year 1970 : Year

-}
fromPosix : Time.Posix -> DateTime
fromPosix =
    Internal.fromPosix


{-| Attempts to construct a new DateTime object from its raw constituent parts.
-}
fromRawParts : Calendar.RawDate -> Clock.RawTime -> Maybe DateTime
fromRawParts rawDate rawTime =
    Internal.fromRawParts rawDate rawTime


{-| Create a `DateTime` from a 'Date' and 'Time'.
-}
fromDateAndTime : Calendar.Date -> Clock.Time -> DateTime
fromDateAndTime =
    Internal.fromDateAndTime


{-| Converts a 'DateTime' to a posix time.

> toPosix (fromPosix (Time.millisToPosix 0))
> Posix 0 : Time.Posix

-}
toPosix : DateTime -> Time.Posix
toPosix =
    Internal.toPosix


{-| Convers a 'DateTime' to the equivalent milliseconds since epoch.

> toMillis (fromPosix (Time.millisToPosix 0))
> 0 : Int

-}
toMillis : DateTime -> Int
toMillis =
    Internal.toMillis


{-| Returns the 'Year' from a 'DateTime' as an Int.

> getYear (fromPosix (Time.millisToPosix 0))
> 1970 : Int

-}
getYear : DateTime -> Int
getYear =
    Internal.getYear


{-| Returns the 'Month' from a 'DateTime' as a [Month](https://package.elm-lang.org/packages/elm/time/latest/Time#Month).

> getMonth (fromPosix (Time.millisToPosix 0))
> Jan : Int

-}
getMonth : DateTime -> Time.Month
getMonth =
    Internal.getMonth


{-| Returns the 'Day' from a 'DateTime' as an Int.

> getDay (fromPosix (Time.millisToPosix 0))
> 1 : Int

-}
getDay : DateTime -> Int
getDay =
    Internal.getDay


{-| Extract the weekday from a `DateTime`.

> getWeekday (fromPosix (Time.millisToPosix 0))
> Thu : Time.Weekday

-}
getWeekday : DateTime -> Time.Weekday
getWeekday =
    Internal.getWeekday


{-| Returns the 'Hour' from a 'DateTime' as an Int.

> getHours (fromPosix (Time.millisToPosix 0))
> 0 : Int

-}
getHours : DateTime -> Int
getHours =
    Internal.getHours


{-| Returns the 'Minute' from a 'DateTime' as an Int.

> getMinutes (fromPosix (Time.millisToPosix 0))
> 0 : Int

-}
getMinutes : DateTime -> Int
getMinutes =
    Internal.getMinutes


{-| Returns the 'Second' from a 'DateTime' as an Int.

> getSeconds (fromPosix (Time.millisToPosix 0))
> 0 : Int

-}
getSeconds : DateTime -> Int
getSeconds =
    Internal.getSeconds


{-| Returns the 'Millisecond' from a 'DateTime' as an Int.

> getMilliseconds (fromPosix (Time.millisToPosix 0))
> 0 : Int

-}
getMilliseconds : DateTime -> Int
getMilliseconds =
    Internal.getMilliseconds



-- NEW STUFF


{-| Returns a list of Dates that belong in the current month of the 'DateTime'.
-}
getDatesInMonth : DateTime -> List DateTime
getDatesInMonth =
    Internal.getDatesInMonth


{-| Returns a List of dates based on the start and end 'DateTime' given as parameters.
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
getDateRange : DateTime -> DateTime -> List DateTime
getDateRange start end =
    Internal.getDateRange start end


{-| Returns a new 'DateTime' with an updated year value.
-}
incrementYear : DateTime -> DateTime
incrementYear =
    Internal.incrementYear


{-| Returns a new 'DateTime' with an updated year value.
-}
decrementYear : DateTime -> DateTime
decrementYear =
    Internal.decrementYear


{-| Returns a new 'DateTime' with an updated month value.
-}
decrementMonth : DateTime -> DateTime
decrementMonth =
    Internal.decrementMonth


{-| Returns a new 'DateTime' with an updated month value.
-}
incrementMonth : DateTime -> DateTime
incrementMonth =
    Internal.incrementMonth


compareDates : DateTime -> DateTime -> Order
compareDates lhs rhs =
    Internal.compareDates lhs rhs


compareTime : DateTime -> DateTime -> Order
compareTime lhs rhs =
    Internal.compareTime lhs rhs



-- getDayDiff : DateTime -> DateTime -> Int
-- getDayDiff (DateTime startDate) (DateTime endDate) =
--     Calendar.getDayDiff startDate.date endDate.date


{-| Decrements the 'Day' in a given 'Date'. Will also decrement 'Month' && 'Year'
--- if applicable.

> date = fromRawParts { rawDay = 1, rawMonth = 1, rawYear = 2019 } { hours = 0, minutes = 0, seconds = 0, milliseconds = 0 }
> decrementDay date
> DateTime { date = { day = Day 31, month = Dec, year = Year 2018 }, time = { hours = 0, minutes = 0, seconds = 0, milliseconds = 0 } }
>
> date2 = fromRawParts { rawDay = 1, rawMonth = 3, rawYear 2020 } { hours = 0, minutes = 0, seconds = 0, milliseconds = 0 }
> decrementDay date2
> DateTime { date = { day = Day 29, month = Feb, year = Year 2020 }, time = { hours = 0, minutes = 0, seconds = 0, milliseconds = 0 } }
>
> date3 = fromRawParts { rawDay = 26, rawMonth = 12, rawYear 2018 } { hours = 0, minutes = 0, seconds = 0, milliseconds = 0 }
> decrementDay date3
> DateTime { date = { day = Day 25, month = Dec, year = Year 2018 }, time = { hours = 0, minutes = 0, seconds = 0, milliseconds = 0 } }

-}
decrementDay : DateTime -> DateTime
decrementDay =
    Internal.decrementDay


{-| Increments the 'Day' in a given 'Date'. Will also increment 'Month' && 'Year'
--- if applicable.

> date = fromRawParts { rawDay = 31, rawMonth = 12, rawYear = 2018 } { hours = 0, minutes = 0, seconds = 0, milliseconds = 0 }
> incrementDay date
> DateTime { date = { day = Day 1, month = Jan, year = Year 2019 }, time = { hours = 0, minutes = 0, seconds = 0, milliseconds = 0 } }
>
> date2 = fromRawParts { rawDay = 29, rawMonth = 2, rawYear 2020 } { hours = 0, minutes = 0, seconds = 0, milliseconds = 0 }
> incrementDay date2
> DateTime { date = { day = Day 1, month = Mar, year = Year 2020 }, time = { hours = 0, minutes = 0, seconds = 0, milliseconds = 0 } }
>
> date3 = fromRawParts { rawDay = 24, rawMonth = 12, rawYear 2018 } { hours = 0, minutes = 0, seconds = 0, milliseconds = 0 }
> incrementDay date3
> DateTime { date = { day = Day 25, month = Dec, year = Year 2018 }, time = { hours = 0, minutes = 0, seconds = 0, milliseconds = 0 } }

-}
incrementDay : DateTime -> DateTime
incrementDay =
    Internal.incrementDay


{-| Extract the calendar date from a `DateTime`.

> getDate (fromPosix (Time.millisToPosix 0))
> Date { day = Day 1, month = Jan, year = Year 1970 } : Calendar.Date

-}
getDate : DateTime -> Calendar.Date
getDate =
    Internal.getDate


{-| Extract the clock time from a `DateTime`.

> getTime (fromPosix (Time.millisToPosix 0))
> Time { hour = Hour 0, millisecond = 0, minute = Minute 0, second = Second 0 } : Clock.Time

-}
getTime : DateTime -> Clock.Time
getTime =
    Internal.getTime


{-| Increments the 'Hours' in a given 'Date'. Will also increment 'Day', 'Month', 'Year' where applicable.
-}
incrementHours : DateTime -> DateTime
incrementHours =
    Internal.incrementHours


{-| Increments the 'Minutes' in a given 'Date'. Will also increment 'Hours', 'Day', 'Month', 'Year' where applicable.
-}
incrementMinutes : DateTime -> DateTime
incrementMinutes =
    Internal.incrementMinutes


{-| Increments the 'Seconds' in a given 'Date'. Will also increment 'Minutes', 'Hours', 'Day', 'Month', 'Year' where applicable.
-}
incrementSeconds : DateTime -> DateTime
incrementSeconds =
    Internal.incrementSeconds


{-| Increments the 'Milliseconds' in a given 'Date'. Will also increment 'Seconds', 'Minutes', 'Hours', 'Day', 'Month', 'Year' where applicable.
-}
incrementMilliseconds : DateTime -> DateTime
incrementMilliseconds =
    Internal.incrementMilliseconds


{-| Decrements the 'Hours' in a given 'Date'. Will also decrement 'Day', 'Month', 'Year' where applicable.
-}
decrementHours : DateTime -> DateTime
decrementHours =
    Internal.decrementHours


{-| Decrements the 'Minutes' in a given 'Date'. Will also decrement 'Hours', 'Day', 'Month', 'Year' where applicable.
-}
decrementMinutes : DateTime -> DateTime
decrementMinutes =
    Internal.decrementMinutes


{-| Decrements the 'Seconds' in a given 'Date'. Will also decrement 'Minutes', 'Hours', 'Day', 'Month', 'Year' where applicable.
-}
decrementSeconds : DateTime -> DateTime
decrementSeconds =
    Internal.decrementSeconds


{-| Decrements the 'Milliseconds' in a given 'Date'. Will also decrement 'Seconds', 'Minutes', 'Hours', 'Day', 'Month', 'Year' where applicable.
-}
decrementMilliseconds : DateTime -> DateTime
decrementMilliseconds =
    Internal.decrementMilliseconds
