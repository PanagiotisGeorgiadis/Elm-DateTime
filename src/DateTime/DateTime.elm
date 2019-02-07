module DateTime.DateTime exposing
    ( DateTime
    , fromPosix, fromRawParts, fromDateAndTime
    , toPosix, toMillis
    , getDate, getTime, getYear, getMonth, getDay, getHours, getMinutes, getSeconds, getMilliseconds
    , setYear, setMonth, setDay, setHours, setMinutes, setSeconds, setMilliseconds
    , incrementYear, incrementMonth, incrementDay, incrementHours, incrementMinutes, incrementSeconds, incrementMilliseconds
    , decrementYear, decrementMonth, decrementDay, decrementHours, decrementMinutes, decrementSeconds, decrementMilliseconds
    , compare, compareDates, compareTime
    , getWeekday, getDateRange, getDatesInMonth
    )

{-| A complete datetime type.

@docs DateTime


# Creating a `DateTime`

@docs fromPosix, fromRawParts, fromDateAndTime


# Conversions

@docs toPosix, toMillis


# Accessors

@docs getDate, getTime, getYear, getMonth, getDay, getHours, getMinutes, getSeconds, getMilliseconds


# Setters

@docs setYear, setMonth, setDay, setHours, setMinutes, setSeconds, setMilliseconds


# Incrementers

@docs incrementYear, incrementMonth, incrementDay, incrementHours, incrementMinutes, incrementSeconds, incrementMilliseconds


# Decrementers

@docs decrementYear, decrementMonth, decrementDay, decrementHours, decrementMinutes, decrementSeconds, decrementMilliseconds


# Comparers

@docs compare, compareDates, compareTime


# Utilities

@docs getWeekday, getDateRange, getDatesInMonth

-}

import DateTime.Calendar as Calendar
import DateTime.Clock as Clock
import DateTime.DateTime.Internal as Internal
import Time


{-| An instant in time, composed of a calendar date, clock time and time zone.
-}
type alias DateTime =
    Internal.DateTime



-- Constructors


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



-- Converters


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



-- Accessors


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



-- Setters


{-| Attempts to set the 'Year' part of a Calendar.Date in a DateTime.
-}
setYear : Int -> DateTime -> Maybe DateTime
setYear =
    Internal.setYear


{-| Attempts to set the 'Month' part of a Calendar.Date in a DateTime.
-}
setMonth : Time.Month -> DateTime -> Maybe DateTime
setMonth =
    Internal.setMonth


{-| Attempts to set the 'Day' part of a Calendar.Date in a DateTime.
-}
setDay : Int -> DateTime -> Maybe DateTime
setDay =
    Internal.setDay


{-| Attempts to set the 'Hours' part of a Clock.Time in a DateTime.
-}
setHours : Int -> DateTime -> Maybe DateTime
setHours =
    Internal.setHours


{-| Attempts to set the 'Minutes' part of a Clock.Time in a DateTime.
-}
setMinutes : Int -> DateTime -> Maybe DateTime
setMinutes =
    Internal.setMinutes


{-| Attempts to set the 'Seconds' part of a Clock.Time in a DateTime.
-}
setSeconds : Int -> DateTime -> Maybe DateTime
setSeconds =
    Internal.setSeconds


{-| Attempts to set the 'Milliseconds' part of a Clock.Time in a DateTime.
-}
setMilliseconds : Int -> DateTime -> Maybe DateTime
setMilliseconds =
    Internal.setMilliseconds



-- Incrementers


{-| Returns a new 'DateTime' with an updated year value.
-}
incrementYear : DateTime -> DateTime
incrementYear =
    Internal.incrementYear


{-| Returns a new 'DateTime' with an updated month value.
-}
incrementMonth : DateTime -> DateTime
incrementMonth =
    Internal.incrementMonth


{-| Increments the 'Day' in a given 'Date'. Will also increment 'Month' && 'Year'
--- if applicable.

> date = fromRawParts { day = 31, month = Dec, year = 2018 } { hours = 0, minutes = 0, seconds = 0, milliseconds = 0 }
> incrementDay date
> DateTime { date = { day = Day 1, month = Jan, year = Year 2019 }, time = { hours = 0, minutes = 0, seconds = 0, milliseconds = 0 } }
>
> date2 = fromRawParts { day = 29, month = Feb, year = 2020 } { hours = 0, minutes = 0, seconds = 0, milliseconds = 0 }
> incrementDay date2
> DateTime { date = { day = Day 1, month = Mar, year = Year 2020 }, time = { hours = 0, minutes = 0, seconds = 0, milliseconds = 0 } }
>
> date3 = fromRawParts { day = 24, month = Dec, year = 2018 } { hours = 0, minutes = 0, seconds = 0, milliseconds = 0 }
> incrementDay date3
> DateTime { date = { day = Day 25, month = Dec, year = Year 2018 }, time = { hours = 0, minutes = 0, seconds = 0, milliseconds = 0 } }

-}
incrementDay : DateTime -> DateTime
incrementDay =
    Internal.incrementDay


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



-- Decrementers


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


{-| Decrements the 'Day' in a given 'Date'. Will also decrement 'Month' && 'Year'
--- if applicable.

> date = fromRawParts { day = 1, month = Jan, year = 2019 } { hours = 0, minutes = 0, seconds = 0, milliseconds = 0 }
> decrementDay date
> DateTime { date = { day = Day 31, month = Dec, year = Year 2018 }, time = { hours = 0, minutes = 0, seconds = 0, milliseconds = 0 } }
>
> date2 = fromRawParts { day = 1, month = Mar, year = 2020 } { hours = 0, minutes = 0, seconds = 0, milliseconds = 0 }
> decrementDay date2
> DateTime { date = { day = Day 29, month = Feb, year = Year 2020 }, time = { hours = 0, minutes = 0, seconds = 0, milliseconds = 0 } }
>
> date3 = fromRawParts { day = 26, month = Dec, year = 2018 } { hours = 0, minutes = 0, seconds = 0, milliseconds = 0 }
> decrementDay date3
> DateTime { date = { day = Day 25, month = Dec, year = Year 2018 }, time = { hours = 0, minutes = 0, seconds = 0, milliseconds = 0 } }

-}
decrementDay : DateTime -> DateTime
decrementDay =
    Internal.decrementDay


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



-- Comparers


{-| Compares two DateTimes and returns their 'Order'.
-}
compare : DateTime -> DateTime -> Order
compare =
    Internal.compare


{-| Returns the 'Order' of the 'Date' part of two DateTimes.
-}
compareDates : DateTime -> DateTime -> Order
compareDates =
    Internal.compareDates


{-| Returns the 'Order' of the 'Time' part of two DateTimes.
-}
compareTime : DateTime -> DateTime -> Order
compareTime =
    Internal.compareTime



-- Utilities


{-| Extract the weekday from a `DateTime`.

> getWeekday (fromPosix (Time.millisToPosix 0))
> Thu : Time.Weekday

-}
getWeekday : DateTime -> Time.Weekday
getWeekday =
    Internal.getWeekday


{-| Returns a list of Dates that belong in the current month of the 'DateTime'.
-}
getDatesInMonth : DateTime -> List DateTime
getDatesInMonth =
    Internal.getDatesInMonth


{-| Returns a List of dates based on the start and end 'DateTime' given as parameters.
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
getDateRange : DateTime -> DateTime -> List DateTime
getDateRange start end =
    Internal.getDateRange start end
