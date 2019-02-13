module DateTime.DateTime exposing
    ( DateTime
    , fromPosix, fromRawParts, fromDateAndTime
    , toPosix, toMillis
    , getDate, getTime, getYear, getMonth, getDay, getHours, getMinutes, getSeconds, getMilliseconds
    , setYear, setMonth, setDay, setHours, setMinutes, setSeconds, setMilliseconds
    , incrementYear, incrementMonth, incrementDay, incrementHours, incrementMinutes, incrementSeconds, incrementMilliseconds
    , decrementYear, decrementMonth, decrementDay, decrementHours, decrementMinutes, decrementSeconds, decrementMilliseconds
    , compare, compareDates, compareTime
    , getWeekday, getDateRange, getDatesInMonth, sort
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

@docs getWeekday, getDateRange, getDatesInMonth, sort

-}

import DateTime.Calendar as Calendar
import DateTime.Clock as Clock
import DateTime.DateTime.Internal as Internal
import Time


{-| An instant in time, composed of a [Calendar Date](DateTime-Calendar#Date) and a [Clock Time](DateTime-Clock#Time).
-}
type alias DateTime =
    Internal.DateTime



-- Constructors


{-| Create a `DateTime` from a [Posix](https://package.elm-lang.org/packages/elm/time/latest/Time#Posix) time.

    fromPosix (Time.millisToPosix 0)
    -- DateTime { date = Date { day = Day 1, month = Jan, year = Year 1970 }, time = Time { hours = Hour 0, milliseconds = Millisecond 0, minutes = Minute 0, seconds = Second 0 } }

    fromPosix (Time.millisToPosix 1566795954000)
    -- DateTime { date = Date { day = Day 26, month = Aug, year = Year 2019 }, time = Time { hours = Hour 5, milliseconds = Millisecond 0, minutes = Minute 5, seconds = Second 54 } }

-}
fromPosix : Time.Posix -> DateTime
fromPosix =
    Internal.fromPosix


{-| Attempts to construct a new `DateTime` object from its raw constituent parts. Returns `Nothing` if
any parts or their combination would result in an invalid [DateTime](DateTime-DateTime#DateTime)

    fromRawParts { day = 26, month = Aug, year = 2019 } { hours = 12, minutes = 30, seconds = 45, milliseconds = 0 }
    -- Just (DateTime { date = Date { day = Day 26, month = Aug, year = Year 2019 }, time = Time { hours = Hour 12, milliseconds = Millisecond 0, minutes = Minute 30, seconds = Second 45 }})

    fromRawParts { day = 29, month = Feb, year = 2019 } { hours = 16, minutes = 30, seconds = 45, milliseconds = 0 }
    -- Nothing

    fromRawParts { day = 25, month = Feb, year = 2019 } { hours = 24, minutes = 20, seconds = 40, milliseconds = 0 }
    -- Nothing

-}
fromRawParts : Calendar.RawDate -> Clock.RawTime -> Maybe DateTime
fromRawParts rawDate rawTime =
    Internal.fromRawParts rawDate rawTime


{-| Create a `DateTime` from a [Date](DateTime-Calendar#Date) and [Time](DateTime-Clock#Time).

    rawDate = Calendar.fromRawParts { day = 26, month = Aug, year = 2019 }
    rawTime = Clock.fromRawParts { hours = 12, minutes = 30, seconds = 45, milliseconds = 0 }

    Maybe.map2 fromDateAndTime rawDate rawTime
    -- DateTime { date = Date { day = Day 26, month = Aug, year = Year 2019 }, time = Time { hours = Hour 12, milliseconds = Millisecond 0, minutes = Minute 30, seconds = Second 45 } }

-}
fromDateAndTime : Calendar.Date -> Clock.Time -> DateTime
fromDateAndTime =
    Internal.fromDateAndTime



-- Converters


{-| Converts a `DateTime` to a posix time. The result is relative to the [Epoch](https://en.wikipedia.org/wiki/Unix_time).
This basically means that **if the DateTime provided is after the Epoch** the result will be a **positive posix time.** Otherwise the
result will be a negative posix time.

    dt = fromRawParts { day = 25, month = Dec, year = 2019 } { hours = 19, minutes = 23, seconds = 45, milliseconds = 0 }
    Maybe.map toPosix dt -- Just (Posix 1577301825000)

    dt2 = fromRawParts { day = 1, month = Jan, year = 1970 } { hours = 0, minutes = 0, seconds = 0, milliseconds = 0 }
    Maybe.map toPosix dt2 -- Just (Posix 0)

    dt3 = fromRawParts { day = 25, month = Dec, year = 1920 } { hours = 19, minutes = 23, seconds = 45, milliseconds = 0 }
    Maybe.map toPosix dt3 -- Just (Posix -1546835775000)

-}
toPosix : DateTime -> Time.Posix
toPosix =
    Internal.toPosix


{-| Convers a `DateTime` to the equivalent milliseconds. The result is relative to the [Epoch](https://en.wikipedia.org/wiki/Unix_time).
This basically means that **if the DateTime provided is after the Epoch** the result will be a **positive number** representing the milliseconds
that have elapsed since the Epoch. Otherwise the result will be a negative number representing the milliseconds required in order to reach the Epoch.

    dt = fromRawParts { day = 25, month = Dec, year = 2019 } { hours = 19, minutes = 23, seconds = 45, milliseconds = 0 }
    Maybe.map toMillis dt -- Just 1577301825000

    dt2 = fromRawParts { day = 1, month = Jan, year = 1970 } { hours = 0, minutes = 0, seconds = 0, milliseconds = 0 }
    Maybe.map toMillis dt2 -- Just 0

    dt3 = fromRawParts { day = 25, month = Dec, year = 1920 } { hours = 19, minutes = 23, seconds = 45, milliseconds = 0 }
    Maybe.map toMillis dt3 -- Just -1546835775000

-}
toMillis : DateTime -> Int
toMillis =
    Internal.toMillis



-- Accessors


{-| Extract the [Calendar Date](DateTime-Calendar#Date) from a `DateTime`.

    dt = fromRawParts { day = 25, month = Dec, year = 2019 } { hours = 16, minutes = 45, seconds = 30, milliseconds = 0 }
    Maybe.map getDate dt -- Just (Date { day = Day 25, month = Dec, year = Year 2019 })

-}
getDate : DateTime -> Calendar.Date
getDate =
    Internal.getDate


{-| Extract the [Clock Time](DateTime-Clock#Time) from a `DateTime`.

    dt = fromRawParts { day = 25, month = Dec, year = 2019 } { hours = 16, minutes = 45, seconds = 30, milliseconds = 0 }
    Maybe.map getTime dt -- Just (Time { hours = Hour 16, milliseconds = Millisecond 0, minutes = Minute 45, seconds = Second 30 })

-}
getTime : DateTime -> Clock.Time
getTime =
    Internal.getTime


{-| Extract the `Year` part of a `DateTime` as an Int.

    dt = fromRawParts { day = 25, month = Dec, year = 2019 } { hours = 16, minutes = 45, seconds = 30, milliseconds = 0 }
    Maybe.map getYear dt -- Just 2019

-}
getYear : DateTime -> Int
getYear =
    Internal.getYear


{-| Extract the `Month` part of a `DateTime` as a [Month](https://package.elm-lang.org/packages/elm/time/latest/Time#Month).

    dt = fromRawParts { day = 25, month = Dec, year = 2019 } { hours = 16, minutes = 45, seconds = 30, milliseconds = 0 }
    Maybe.map getMonth dt -- Just Dec

-}
getMonth : DateTime -> Time.Month
getMonth =
    Internal.getMonth


{-| Extract the `Day` part of `DateTime` as an Int.

    dt = fromRawParts { day = 25, month = Dec, year = 2019 } { hours = 16, minutes = 45, seconds = 30, milliseconds = 0 }
    Maybe.map getDay dt -- Just 25

-}
getDay : DateTime -> Int
getDay =
    Internal.getDay


{-| Extract the `Hour` part of `DateTime` as an Int.

    dt = fromRawParts { day = 25, month = Dec, year = 2019 } { hours = 16, minutes = 45, seconds = 30, milliseconds = 0 }
    Maybe.map getHours dt -- Just 16

-}
getHours : DateTime -> Int
getHours =
    Internal.getHours


{-| Extract the `Minute` part of `DateTime` as an Int.

    dt = fromRawParts { day = 25, month = Dec, year = 2019 } { hours = 16, minutes = 45, seconds = 30, milliseconds = 0 }
    Maybe.map getMinutes dt -- Just 45

-}
getMinutes : DateTime -> Int
getMinutes =
    Internal.getMinutes


{-| Extract the `Second` part of `DateTime` as an Int.

    dt = fromRawParts { day = 25, month = Dec, year = 2019 } { hours = 16, minutes = 45, seconds = 30, milliseconds = 0 }
    Maybe.map getSeconds dt -- Just 30

-}
getSeconds : DateTime -> Int
getSeconds =
    Internal.getSeconds


{-| Extract the `Millisecond` part of `DateTime` as an Int.

    dt = fromRawParts { day = 25, month = Dec, year = 2019 } { hours = 16, minutes = 45, seconds = 30, milliseconds = 0 }
    Maybe.map getMilliseconds dt -- Just 0

-}
getMilliseconds : DateTime -> Int
getMilliseconds =
    Internal.getMilliseconds



-- Setters


{-| Attempts to set the `Year` part of a [Calendar.Date](DateTime-Calendar#Date) in a `DateTime`.

    dt = fromRawParts { day = 29, month = Feb, year = 2020 } { hours = 15, minutes = 30, seconds = 30, milliseconds = 0 }

    Maybe.andThen (setYear 2024) dt -- Just (DateTime { date = Date { day = Day 29, month = Feb, year = Year 2024 }, time = Time { hours = Hour 15, milliseconds = Millisecond 0, minutes = Minute 30, seconds = Second 30 } })
    Maybe.andThen (setYear 2019) dt -- Nothing

-}
setYear : Int -> DateTime -> Maybe DateTime
setYear =
    Internal.setYear


{-| Attempts to set the `Month` part of a [Calendar.Date](DateTime-Calendar#Date) in a `DateTime`.

    dt = fromRawParts { day = 31, month = Jan, year = 2019 } { hours = 15, minutes = 30, seconds = 30, milliseconds = 0 }

    Maybe.andThen (setMonth Aug) dt -- Just (DateTime { date = Date { day = Day 31, month = Aug, year = Year 2019 }, time = Time { hours = Hour 15, milliseconds = Millisecond 0, minutes = Minute 30, seconds = Second 30 } })
    Maybe.andThen (setMonth Apr) dt -- Nothing

-}
setMonth : Time.Month -> DateTime -> Maybe DateTime
setMonth =
    Internal.setMonth


{-| Attempts to set the `Day` part of a [Calendar.Date](DateTime-Calendar#Date) in a `DateTime`.

    dt = fromRawParts { day = 31, month = Jan, year = 2019 } { hours = 15, minutes = 30, seconds = 30, milliseconds = 0 }

    Maybe.andThen (setDay 25) dt -- Just (DateTime { date = Date { day = Day 25, month = Jan, year = Year 2019 }, time = Time { hours = Hour 15, milliseconds = Millisecond 0, minutes = Minute 30, seconds = Second 30 } })
    Maybe.andThen (setDay 32) dt -- Nothing

-}
setDay : Int -> DateTime -> Maybe DateTime
setDay =
    Internal.setDay


{-| Attempts to set the `Hours` part of a [Clock.Time](DateTime-Clock#Time) in a DateTime.

    dt = fromRawParts { day = 2, month = Jul, year = 2019 } { hours = 12, minutes = 0, seconds = 0, milliseconds = 0 }

    Maybe.andThen (setHours 23) dt -- Just (DateTime { date = Date { day = Day 2, month = Jul, year = Year 2019 }, time = Time { hours = Hour 23, milliseconds = Millisecond 0, minutes = Minute 0, seconds = Second 0 } })
    Maybe.andThen (setHours 24) dt -- Nothing

-}
setHours : Int -> DateTime -> Maybe DateTime
setHours =
    Internal.setHours


{-| Attempts to set the `Minutes` part of a [Clock.Time](DateTime-Clock#Time) in a DateTime.

    dt = fromRawParts { day = 2, month = Jul, year = 2019 } { hours = 12, minutes = 0, seconds = 0, milliseconds = 0 }

    Maybe.andThen (setMinutes 36) dt -- Just (DateTime { date = Date { day = Day 2, month = Jul, year = Year 2019 }, time = Time { hours = Hour 12, milliseconds = Millisecond 0, minutes = Minute 36, seconds = Second 0 } })
    Maybe.andThen (setMinutes 60) dt -- Nothing

-}
setMinutes : Int -> DateTime -> Maybe DateTime
setMinutes =
    Internal.setMinutes


{-| Attempts to set the `Seconds` part of a [Clock.Time](DateTime-Clock#Time) in a DateTime.

    dt = fromRawParts { day = 2, month = Jul, year = 2019 } { hours = 12, minutes = 0, seconds = 0, milliseconds = 0 }

    Maybe.andThen (setSeconds 20) dt -- Just (DateTime { date = Date { day = Day 2, month = Jul, year = Year 2019 }, time = Time { hours = Hour 12, milliseconds = Millisecond 0, minutes = Minute 0, seconds = Second 20 } })
    Maybe.andThen (setSeconds 60) dt -- Nothing

-}
setSeconds : Int -> DateTime -> Maybe DateTime
setSeconds =
    Internal.setSeconds


{-| Attempts to set the `Milliseconds` part of a [Clock.Time](DateTime-Clock#Time) in a DateTime.

    dt = fromRawParts { day = 2, month = Jul, year = 2019 } { hours = 12, minutes = 0, seconds = 0, milliseconds = 0 }

    Maybe.andThen (setMilliseconds 589) dt -- Just (DateTime { date = Date { day = Day 2, month = Jul, year = Year 2019 }, time = Time { hours = Hour 12, milliseconds = Millisecond 589, minutes = Minute 0, seconds = Second 0 } })
    Maybe.andThen (setMilliseconds 1000) dt -- Nothing

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


{-| Returns the weekday of a specific [DateTime](DateTime-DateTime#DateTime).

    dt = fromRawParts { day = 26, month = Aug, year = 2019 } { hours = 12, minutes = 30, seconds = 45, milliseconds = 0 }
    Maybe.map getWeekday dt -- Just Mon

-}
getWeekday : DateTime -> Time.Weekday
getWeekday =
    Internal.getWeekday


{-| Returns a list of Dates that belong in the current month of the 'DateTime'.
-}
getDatesInMonth : DateTime -> Clock.Time -> List DateTime
getDatesInMonth =
    Internal.getDatesInMonth


{-| Returns a List of dates based on the start and end 'DateTime' given as parameters.
--- The resulting list includes both the start and end 'Dates'.
--- In the case of startDate > endDate the resulting list would still be
--- a valid sorted date range list.

> startDate = fromRawParts { day = 25, month = Feb, year = 2020 }
> endDate = fromRawParts { day = 1, month = Mar, year = 2020 }
> getDateRange startDate endDate Clock.midnight
> [ Date { day = Day 25, month = Feb, year = Year 2020 } { hours = 0, minutes = 0, seconds = 0, milliseconds = 0 }
> , Date { day = Day 26, month = Feb, year = Year 2020 } { hours = 0, minutes = 0, seconds = 0, milliseconds = 0 }
> , Date { day = Day 27, month = Feb, year = Year 2020 } { hours = 0, minutes = 0, seconds = 0, milliseconds = 0 }
> , Date { day = Day 28, month = Feb, year = Year 2020 } { hours = 0, minutes = 0, seconds = 0, milliseconds = 0 }
> , Date { day = Day 29, month = Feb, year = Year 2020 } { hours = 0, minutes = 0, seconds = 0, milliseconds = 0 }
> , Date { day = Day 1, month = Mar, year = Year 2020 } { hours = 0, minutes = 0, seconds = 0, milliseconds = 0 }
> ]
>
> startDate2 = fromRawParts { day = 25, month = Feb, year = 2019 }
> endDate2 = fromRawParts { day = 1, month = Mar, year = 2019 }
> getDateRange startDate2 endDate2 Clock.midnight
> [ Date { day = Day 25, month = Feb, year = Year 2019 } { hours = 0, minutes = 0, seconds = 0, milliseconds = 0 }
> , Date { day = Day 26, month = Feb, year = Year 2019 } { hours = 0, minutes = 0, seconds = 0, milliseconds = 0 }
> , Date { day = Day 27, month = Feb, year = Year 2019 } { hours = 0, minutes = 0, seconds = 0, milliseconds = 0 }
> , Date { day = Day 28, month = Feb, year = Year 2019 } { hours = 0, minutes = 0, seconds = 0, milliseconds = 0 }
> , Date { day = Day 1, month = Mar, year = Year 2019 } { hours = 0, minutes = 0, seconds = 0, milliseconds = 0 }
> ]

-}
getDateRange : DateTime -> DateTime -> Clock.Time -> List DateTime
getDateRange =
    Internal.getDateRange


{-| Sorts a List of 'DateTime' based on their posix timestamps.
-}
sort : List DateTime -> List DateTime
sort =
    Internal.sort
