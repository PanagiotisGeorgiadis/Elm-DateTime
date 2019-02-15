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

{-| The `DateTime` module was introduced in order to keep track of both the
[Date](DateTime-Calendar#Date) and [Time](DateTime-Clock#Time). The `DateTime`
consists of a `Day`, `Month`, `Year`, `Hours`, `Minutes`, `Seconds` and `Milliseconds`.
You can construct a `DateTime` either by using a [Posix](https://package.elm-lang.org/packages/elm/time/latest/Time#Posix)
or by using an existing [Date](DateTime-Calendar#Date) and [Time](DateTime-Clock#Time) combination. Otherwise
you can _**attempt**_ to construct a `DateTime` by using a combination of a
[RawDate](DateTime-Calendar#RawDate) and a [RawClock](DateTime-Clock#RawClock).

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
    -- DateTime { date = Date { day = Day 1, month = Jan, year = Year 1970 }, time = Time { hours = Hour 0, minutes = Minute 0, seconds = Second 0, milliseconds = Millisecond 0 } } : DateTime

    fromPosix (Time.millisToPosix 1566795954000)
    -- DateTime { date = Date { day = Day 26, month = Aug, year = Year 2019 }, time = Time { hours = Hour 5, minutes = Minute 5, seconds = Second 54, milliseconds = Millisecond 0 } } : DateTime

-}
fromPosix : Time.Posix -> DateTime
fromPosix =
    Internal.fromPosix


{-| Attempts to construct a new `DateTime` object from its raw constituent parts. Returns `Nothing` if
any parts or their combination would result in an invalid [DateTime](DateTime-DateTime#DateTime)

    fromRawParts { day = 26, month = Aug, year = 2019 } { hours = 12, minutes = 30, seconds = 45, milliseconds = 0 }
    -- Just (DateTime { date = Date { day = Day 26, month = Aug, year = Year 2019 }, time = Time { hours = Hour 12, minutes = Minute 30, seconds = Second 45, milliseconds = Millisecond 0 }}) : Maybe DateTime

    fromRawParts { day = 29, month = Feb, year = 2019 } { hours = 16, minutes = 30, seconds = 45, milliseconds = 0 }
    -- Nothing : Maybe DateTime

    fromRawParts { day = 15, month = Nov, year = 2019 } { hours = 24, minutes = 20, seconds = 40, milliseconds = 0 }
    -- Nothing : Maybe DateTime

-}
fromRawParts : Calendar.RawDate -> Clock.RawTime -> Maybe DateTime
fromRawParts rawDate rawTime =
    Internal.fromRawParts rawDate rawTime


{-| Create a `DateTime` from a [Date](DateTime-Calendar#Date) and [Time](DateTime-Clock#Time).

    -- date == 26 Aug 2019
    -- time == 12:30:45.000

    fromDateAndTime date time
    -- DateTime { date = Date { day = Day 26, month = Aug, year = Year 2019 }, time = Time { hours = Hour 12, minutes = Minute 30, seconds = Second 45, milliseconds = Millisecond 0 } } : DateTime

-}
fromDateAndTime : Calendar.Date -> Clock.Time -> DateTime
fromDateAndTime =
    Internal.fromDateAndTime



-- Converters


{-| Converts a `DateTime` to a posix time. The result is relative to the [Epoch](https://en.wikipedia.org/wiki/Unix_time).
This basically means that **if the DateTime provided is after the Epoch** the result will be a **positive posix time.** Otherwise the
result will be a **negative posix time**.

    -- dateTime == 25 Dec 2019 19:23:45.000
    toPosix dateTime -- Posix 1577301825000 : Posix

    -- dateTime2 == 1 Jan 1970 00:00:00.000 : Posix
    toPosix dateTime2 -- Posix 0

    -- dateTime3 == 25 Dec 1920 19:23:45.000
    toPosix dateTime3 -- Posix -1546835775000 : Posix

-}
toPosix : DateTime -> Time.Posix
toPosix =
    Internal.toPosix


{-| Convers a `DateTime` to the equivalent milliseconds. The result is relative to the [Epoch](https://en.wikipedia.org/wiki/Unix_time).
This basically means that **if the DateTime provided is after the Epoch** the result will be a **positive number** representing the milliseconds
that have elapsed since the Epoch. Otherwise the result will be a negative number representing the milliseconds required in order to reach the Epoch.

    -- dateTime == 25 Dec 2019 19:23:45.000
    toMillis dateTime -- 1577301825000 : Int

    -- dateTime2 == 1 Jan 1970 00:00:00.000
    toMillis dateTime2 -- 0 : Int

    -- dateTime3 == 25 Dec 1920 19:23:45.000
    toMillis dateTime3 -- -1546835775000 : Int

-}
toMillis : DateTime -> Int
toMillis =
    Internal.toMillis



-- Accessors


{-| Extract the [Calendar Date](DateTime-Calendar#Date) from a `DateTime`.

    -- dateTime == 25 Dec 2019 16:45:30.000
    getDate dateTime -- 25 Dec 2019 : Calendar.Date

-}
getDate : DateTime -> Calendar.Date
getDate =
    Internal.getDate


{-| Extract the [Clock Time](DateTime-Clock#Time) from a `DateTime`.

    -- dateTime == 25 Dec 2019 16:45:30.000
    getTime dateTime -- 16:45:30.000 : Clock.Time

-}
getTime : DateTime -> Clock.Time
getTime =
    Internal.getTime


{-| Extract the `Year` part of a `DateTime` as an Int.

    -- dateTime == 25 Dec 2019 16:45:30.000
    getYear dateTime -- 2019 : Int

-}
getYear : DateTime -> Int
getYear =
    Internal.getYear


{-| Extract the `Month` part of a `DateTime` as a [Month](https://package.elm-lang.org/packages/elm/time/latest/Time#Month).

    -- dateTime == 25 Dec 2019 16:45:30.000
    getMonth dateTime -- Dec : Time.Month

-}
getMonth : DateTime -> Time.Month
getMonth =
    Internal.getMonth


{-| Extract the `Day` part of `DateTime` as an Int.

    -- dateTime == 25 Dec 2019 16:45:30.000
    getDay dateTime -- 25 : Int

-}
getDay : DateTime -> Int
getDay =
    Internal.getDay


{-| Extract the `Hour` part of `DateTime` as an Int.

    -- dateTime == 25 Dec 2019 16:45:30.000
    getHours dateTime -- 16 : Int

-}
getHours : DateTime -> Int
getHours =
    Internal.getHours


{-| Extract the `Minute` part of `DateTime` as an Int.

    -- dateTime == 25 Dec 2019 16:45:30.000
    getMinutes dateTime -- 45 : Int

-}
getMinutes : DateTime -> Int
getMinutes =
    Internal.getMinutes


{-| Extract the `Second` part of `DateTime` as an Int.

    -- dateTime == 25 Dec 2019 16:45:30.000
    getSeconds dateTime -- 30 : Int

-}
getSeconds : DateTime -> Int
getSeconds =
    Internal.getSeconds


{-| Extract the `Millisecond` part of `DateTime` as an Int.

    -- dateTime == 25 Dec 2019 16:45:30.000
    getMilliseconds dateTime -- 0 : Int

-}
getMilliseconds : DateTime -> Int
getMilliseconds =
    Internal.getMilliseconds



-- Setters


{-| Attempts to set the `Year` part of a [Calendar.Date](DateTime-Calendar#Date) in a `DateTime`.

    -- dateTime == 29 Feb 2020 15:30:30.000
    setYear 2024 dateTime -- Just (29 Feb 2024 15:30:30.000) : Maybe DateTime

    setYear 2019 dateTime -- Nothing : Maybe DateTime

-}
setYear : Int -> DateTime -> Maybe DateTime
setYear =
    Internal.setYear


{-| Attempts to set the `Month` part of a [Calendar.Date](DateTime-Calendar#Date) in a `DateTime`.

    -- dateTime == 31 Jan 2019 15:30:30.000
    setMonth Aug dateTime -- Just (31 Aug 2019 15:30:30.000) : Maybe DateTime

    setMonth Apr dateTime -- Nothing : Maybe DateTime

-}
setMonth : Time.Month -> DateTime -> Maybe DateTime
setMonth =
    Internal.setMonth


{-| Attempts to set the `Day` part of a [Calendar.Date](DateTime-Calendar#Date) in a `DateTime`.

    -- dateTime == 31 Jan 2019 15:30:30.000
    setDay 25 dateTime -- Just (25 Jan 2019 15:30:30.000) : Maybe DateTime

    setDay 32 dateTime -- Nothing : Maybe DateTime

-}
setDay : Int -> DateTime -> Maybe DateTime
setDay =
    Internal.setDay


{-| Attempts to set the `Hours` part of a [Clock.Time](DateTime-Clock#Time) in a DateTime.

    -- dateTime == 2 Jul 2019 12:00:00.000
    setHours 23 dateTime -- Just (2 Jul 2019 23:00:00.000) : Maybe DateTime

    setHours 24 dateTime -- Nothing : Maybe DateTime

-}
setHours : Int -> DateTime -> Maybe DateTime
setHours =
    Internal.setHours


{-| Attempts to set the `Minutes` part of a [Clock.Time](DateTime-Clock#Time) in a DateTime.

    -- dateTime == 2 Jul 2019 12:00:00.000
    setMinutes 36 dateTime -- Just (2 Jul 2019 12:36:00.000) : Maybe DateTime

    setMinutes 60 dateTime -- Nothing : Maybe DateTime

-}
setMinutes : Int -> DateTime -> Maybe DateTime
setMinutes =
    Internal.setMinutes


{-| Attempts to set the `Seconds` part of a [Clock.Time](DateTime-Clock#Time) in a DateTime.

    -- dateTime == 2 Jul 2019 12:00:00.000
    setSeconds 20 dateTime -- Just (2 Jul 2019 12:00:20.000) : Maybe DateTime

    setSeconds 60 dateTime -- Nothing : Maybe DateTime

-}
setSeconds : Int -> DateTime -> Maybe DateTime
setSeconds =
    Internal.setSeconds


{-| Attempts to set the `Milliseconds` part of a [Clock.Time](DateTime-Clock#Time) in a DateTime.

    -- dateTime == 2 Jul 2019 12:00:00.000
    setMilliseconds 589 dateTime -- Just (2 Jul 2019 12:00:00.589) : Maybe DateTime

    setMilliseconds 1000 dateTime -- Nothing : Maybe DateTime

-}
setMilliseconds : Int -> DateTime -> Maybe DateTime
setMilliseconds =
    Internal.setMilliseconds



-- Incrementers


{-| Increments the `Year` in a given [DateTime](DateTime-DateTime#DateTime) while preserving the `Month`, and `Day` parts.
_The [Time](DateTime-Clock#Time) related parts will remain the same._

    -- dateTime == 31 Jan 2019 15:30:45.100
    incrementYear dateTime -- 31 Jan 2020 15:30:45.100 : DateTime

    -- dateTime2 == 29 Feb 2020 15:30:45.100
    incrementYear dateTime2 -- 28 Feb 2021 15:30:45.100 : DateTime

**Note:** In the first example, incrementing the `Year` causes no changes in the `Month` and `Day` parts.
On the second example we see that the `Day` part is different than the input. This is because the resulting date in the `DateTime`
would be an invalid date ( _**29th of February 2021**_ ). As a result of this scenario we fall back to the last valid day
of the given `Month` and `Year` combination.

-}
incrementYear : DateTime -> DateTime
incrementYear =
    Internal.incrementYear


{-| Increments the `Month` in a given [DateTime](DateTime-DateTime#DateTime). It will also roll over to the next year where applicable.
_The [Time](DateTime-Clock#Time) related parts will remain the same._

    -- dateTime == 15 Sep 2019 15:30:45.100
    incrementMonth dateTime -- 15 Oct 2019 15:30:45.100 : DateTime

    -- dateTime2 == 15 Dec 2019 15:30:45.100
    incrementMonth dateTime2 -- 15 Jan 2020 15:30:45.100 : DateTime

    -- dateTime3 == 31 Jan 2019 15:30:45.100
    incrementMonth dateTime3 -- 28 Feb 2019 15:30:45.100 : DateTime

**Note:** In the first example, incrementing the `Month` causes no changes in the `Year` and `Day` parts while on the second
example it rolls forward the 'Year'. On the last example we see that the `Day` part is different than the input. This is because
the resulting date would be an invalid one ( _**31st of February 2019**_ ). As a result of this scenario we fall back to the last
valid day of the given `Month` and `Year` combination.

-}
incrementMonth : DateTime -> DateTime
incrementMonth =
    Internal.incrementMonth


{-| Increments the `Day` in a given [DateTime](DateTime-DateTime#DateTime). Will also increment `Month` and `Year` where applicable.

    -- dateTime == 25 Aug 2019 15:30:45.100
    incrementDay dateTime -- 26 Aug 2019 15:30:45.100 : DateTime

    -- dateTime2 == 31 Dec 2019 15:30:45.100
    incrementDay dateTime2 -- 1 Jan 2020 15:30:45.100 : DateTime

-}
incrementDay : DateTime -> DateTime
incrementDay =
    Internal.incrementDay


{-| Increments the `Hours` in a given [DateTime](DateTime-DateTime#DateTime). Will also increment `Day`, `Month`, `Year` where applicable.

    -- dateTime == 25 Aug 2019 15:30:45.100
    incrementHours dateTime -- 25 Aug 2019 16:30:45.100 : DateTime

    -- dateTime2 == 31 Dec 2019 23:00:00.000
    incrementHours dateTime2 -- 1 Jan 2020 00:00:00.000 : DateTime

-}
incrementHours : DateTime -> DateTime
incrementHours =
    Internal.incrementHours


{-| Increments the `Minutes` in a given [DateTime](DateTime-DateTime#DateTime). Will also increment `Hours`, `Day`, `Month`, `Year` where applicable.

    -- dateTime == 25 Aug 2019 15:30:45.100
    incrementMinutes dateTime -- 25 Aug 2019 15:31:45.100 : DateTime

    -- dateTime2 == 31 Dec 2019 23:59:00.000
    incrementMinutes dateTime2 -- 1 Jan 2020 00:00:00.000 : DateTime

-}
incrementMinutes : DateTime -> DateTime
incrementMinutes =
    Internal.incrementMinutes


{-| Increments the `Seconds` in a given [DateTime](DateTime-DateTime#DateTime). Will also increment `Minutes`, `Hours`, `Day`, `Month`, `Year` where applicable.

    -- dateTime == 25 Aug 2019 15:30:45.100
    incrementSeconds dateTime -- 25 Aug 2019 15:30:46.100 : DateTime

    -- dateTime2 == 31 Dec 2019 23:59:59.000
    incrementSeconds dateTime2 -- 1 Jan 2020 00:00:00.000 : DateTime

-}
incrementSeconds : DateTime -> DateTime
incrementSeconds =
    Internal.incrementSeconds


{-| Increments the `Milliseconds` in a given [DateTime](DateTime-DateTime#DateTime). Will also increment `Seconds`, `Minutes`, `Hours`, `Day`, `Month`, `Year` where applicable.

    -- dateTime == 25 Aug 2019 15:30:45.100
    incrementMilliseconds dateTime -- 25 Aug 2019 15:30:45:101 : DateTime

    -- dateTime2 == 31 Dec 2019 23:59:59.999
    incrementMilliseconds dateTime2 -- 1 Jan 2020 00:00:00.000 : DateTime

-}
incrementMilliseconds : DateTime -> DateTime
incrementMilliseconds =
    Internal.incrementMilliseconds



-- Decrementers


{-| Decrements the `Year` in a given [DateTime](DateTime-DateTime#DateTime) while preserving the `Month` and `Day`.
_The [Time](DateTime-Clock#Time) related parts will remain the same._

    dt = fromRawParts { day = 31, month = Jan, year = 2019 } { hours = 15, minutes = 30, seconds = 45, milliseconds = 100 }
    Maybe.map decrementYear dt -- Just (DateTime { date = Date { day = Day 31, month = Jan, year = Year 2018 }, time = Time { hours = Hour 15, minutes = Minute 30, seconds = Second 45, milliseconds = Millisecond 100 } })

    dt2 = fromRawParts { day = 29, month = Feb, year = 2020 } { hours = 15, minutes = 30, seconds = 45, milliseconds = 100 }
    Maybe.map decrementYear dt2 -- Just (DateTime { date = Date { day = Day 28, month = Feb, year = Year 2019 }, time = Time { hours = Hour 15, minutes = Minute 30, seconds = Second 45, milliseconds = Millisecond 100 } })

**Note:** In the first example, decrementing the `Year` causes no changes in the `Month` and `Day` parts.
On the second example we see that the `Day` part is different than the input. This is because the resulting date in the `DateTime`
would be an invalid date ( _**29th of February 2019**_ ). As a result of this scenario we fall back to the last valid day
of the given `Month` and `Year` combination.

-}
decrementYear : DateTime -> DateTime
decrementYear =
    Internal.decrementYear


{-| Decrements the `Month` in a given [DateTime](DateTime-DateTime#DateTime). It will also roll backwards to the previous year where applicable.
_The [Time](DateTime-Clock#Time) related parts will remain the same._

    dt = fromRawParts { day = 15, month = Sep, year = 2019 } { hours = 15, minutes = 30, seconds = 45, milliseconds = 100 }
    Maybe.map decrementMonth dt -- Just (DateTime { date = Date { day = Day 15, month = Aug, year = Year 2019 }, time = Time { hours = Hour 15, minutes = Minute 30, seconds = Second 45, milliseconds = Millisecond 100 } })

    dt2 = fromRawParts { day = 15, month = Jan, year = 2020 } { hours = 15, minutes = 30, seconds = 45, milliseconds = 100 }
    Maybe.map decrementMonth dt2 -- Just (DateTime { date = Date { day = Day 15, month = Dec, year = Year 2019 }, time = Time { hours = Hour 15, minutes = Minute 30, seconds = Second 45, milliseconds = Millisecond 100 } })

    dt3 = fromRawParts { day = 31, month = Dec, year = 2019 } { hours = 15, minutes = 30, seconds = 45, milliseconds = 100 }
    Maybe.map decrementMonth dt3 -- Just (DateTime { date = Date { day = Day 30, month = Nov, year = Year 2019 }, time = Time { hours = Hour 15, minutes = Minute 30, seconds = Second 45, milliseconds = Millisecond 100 } })

**Note:** In the first example, decrementing the `Month` causes no changes in the `Year` and `Day` parts while
on the second example it rolls backwards the `Year`. On the last example we see that the `Day` part is different
than the input. This is because the resulting date would be an invalid one ( _**31st of November 2019**_ ). As a result
of this scenario we fall back to the last valid day of the given `Month` and `Year` combination.

-}
decrementMonth : DateTime -> DateTime
decrementMonth =
    Internal.decrementMonth


{-| Decrements the `Day` in a given [DateTime](DateTime-DateTime#DateTime). Will also decrement `Month` and `Year` where applicable.

    dt = fromRawParts { day = 27, month = Aug, year = 2019 } { hours = 15, minutes = 30, seconds = 45, milliseconds = 100 }
    Maybe.map decrementDay dt -- Just (DateTime { date = Date { day = Day 26, month = Aug, year = Year 2019 }, time = Time { hours = Hour 15, minutes = Minute 30, seconds = Second 45, milliseconds = Millisecond 100 } })

    dt2 = fromRawParts { day = 1, month = Jan, year = 2020 } { hours = 15, minutes = 30, seconds = 45, milliseconds = 100 }
    Maybe.map decrementDay dt2 -- Just (DateTime { date = Date { day = Day 31, month = Dec, year = Year 2019 }, time = Time { hours = Hour 15, minutes = Minute 30, seconds = Second 45, milliseconds = Millisecond 100 } })

-}
decrementDay : DateTime -> DateTime
decrementDay =
    Internal.decrementDay


{-| Decrements the `Hours` in a given [DateTime](DateTime-DateTime#DateTime). Will also decrement `Day`, `Month`, `Year` where applicable.

    dt = fromRawParts { day = 25, month = Aug, year = 2019 } { hours = 15, minutes = 30, seconds = 45, milliseconds = 100 }
    Maybe.map decrementHours dt -- Just (DateTime { date = Date { day = Day 25, month = Aug, year = Year 2019 }, time = Time { hours = Hour 14, minutes = Minute 30, seconds = Second 45, milliseconds = Millisecond 100 } })

    dt2 = fromRawParts { day = 1, month = Jan, year = 2020 } { hours = 0, minutes = 0, seconds = 0, milliseconds = 0 }
    Maybe.map decrementHours dt2 -- Just (DateTime { date = Date { day = Day 31, month = Dec, year = Year 2019 }, time = Time { hours = Hour 23, minutes = Minute 0, seconds = Second 0, milliseconds = Millisecond 0 } })

-}
decrementHours : DateTime -> DateTime
decrementHours =
    Internal.decrementHours


{-| Decrements the `Minutes` in a given [DateTime](DateTime-DateTime#DateTime). Will also decrement `Hours`, `Day`, `Month`, `Year` where applicable.

    dt = fromRawParts { day = 25, month = Aug, year = 2019 } { hours = 15, minutes = 30, seconds = 45, milliseconds = 100 }
    Maybe.map decrementMinutes dt -- Just (DateTime { date = Date { day = Day 25, month = Aug, year = Year 2019 }, time = Time { hours = Hour 15, minutes = Minute 29, seconds = Second 45, milliseconds = Millisecond 100 } })

    dt2 = fromRawParts { day = 1, month = Jan, year = 2020 } { hours = 0, minutes = 0, seconds = 0, milliseconds = 0 }
    Maybe.map decrementMinutes dt2 -- Just (DateTime { date = Date { day = Day 31, month = Dec, year = Year 2019 }, time = Time { hours = Hour 23, minutes = Minute 59, seconds = Second 0, milliseconds = Millisecond 0 } })

-}
decrementMinutes : DateTime -> DateTime
decrementMinutes =
    Internal.decrementMinutes


{-| Decrements the `Seconds` in a given [DateTime](DateTime-DateTime#DateTime). Will also decrement `Minutes`, `Hours`, `Day`, `Month`, `Year` where applicable.

    dt = fromRawParts { day = 25, month = Aug, year = 2019 } { hours = 15, minutes = 30, seconds = 45, milliseconds = 100 }
    Maybe.map decrementSeconds dt -- Just (DateTime { date = Date { day = Day 25, month = Aug, year = Year 2019 }, time = Time { hours = Hour 15, minutes = Minute 30, seconds = Second 44, milliseconds = Millisecond 100 } })

    dt2 = fromRawParts { day = 1, month = Jan, year = 2020 } { hours = 0, minutes = 0, seconds = 0, milliseconds = 0 }
    Maybe.map decrementSeconds dt2 -- Just (DateTime { date = Date { day = Day 31, month = Dec, year = Year 2019 }, time = Time { hours = Hour 23, minutes = Minute 59, seconds = Second 59, milliseconds = Millisecond 0 } })

-}
decrementSeconds : DateTime -> DateTime
decrementSeconds =
    Internal.decrementSeconds


{-| Decrements the `Milliseconds` in a given [DateTime](DateTime-DateTime#DateTime). Will also decrement `Seconds`, `Minutes`, `Hours`, `Day`, `Month`, `Year` where applicable.

    dt = fromRawParts { day = 25, month = Aug, year = 2019 } { hours = 15, minutes = 30, seconds = 45, milliseconds = 100 }
    Maybe.map decrementMilliseconds dt -- Just (DateTime { date = Date { day = Day 25, month = Aug, year = Year 2019 }, time = Time { hours = Hour 15, minutes = Minute 30, seconds = Second 45, milliseconds = Millisecond 99 } })

    dt2 = fromRawParts { day = 1, month = Jan, year = 2020 } { hours = 0, minutes = 0, seconds = 0, milliseconds = 0 }
    Maybe.map decrementMilliseconds dt2 -- Just (DateTime { date = Date { day = Day 31, month = Dec, year = Year 2019 }, time = Time { hours = Hour 23, minutes = Minute 59, seconds = Second 59, milliseconds = Millisecond 999 } })

-}
decrementMilliseconds : DateTime -> DateTime
decrementMilliseconds =
    Internal.decrementMilliseconds



-- Comparers


{-| Compares the two given [DateTimes](DateTime-DateTime#DateTime) and returns an [Order](https://package.elm-lang.org/packages/elm/core/latest/Basics#Order).

    past = fromRawParts { day = 25, month = Aug, year = 2019 } { hours = 12, minutes = 15, seconds = 45, milliseconds = 250 }
    future = fromRawParts { day = 26, month = Aug, year = 2019 } { hours = 12, minutes = 15, seconds = 45, milliseconds = 250 }

    Maybe.map2 compare past past   -- Just EQ
    Maybe.map2 compare past future -- Just LT
    Maybe.map2 compare future past -- Just GT

-}
compare : DateTime -> DateTime -> Order
compare =
    Internal.compare


{-| Compares the [Date](DateTime-Calendar#Date) part of two given [DateTime](DateTime-DateTime#DateTime) and returns an [Order](https://package.elm-lang.org/packages/elm/core/latest/Basics#Order).

    past = fromRawParts { day = 25, month = Aug, year = 2019 } { hours = 12, minutes = 15, seconds = 45, milliseconds = 250 }
    future = fromRawParts { day = 26, month = Aug, year = 2019 } { hours = 12, minutes = 15, seconds = 45, milliseconds = 250 }

    Maybe.map2 compare past past   -- Just EQ
    Maybe.map2 compare past future -- Just LT
    Maybe.map2 compare future past -- Just GT

-}
compareDates : DateTime -> DateTime -> Order
compareDates =
    Internal.compareDates


{-| Compares the [Time](DateTime-Clock#Time) part of two given [DateTime](DateTime-DateTime#DateTime) and returns an [Order](https://package.elm-lang.org/packages/elm/core/latest/Basics#Order).

    past = fromRawParts { day = 25, month = Aug, year = 2019 } { hours = 12, minutes = 15, seconds = 45, milliseconds = 250 }
    future = fromRawParts { day = 25, month = Aug, year = 2019 } { hours = 13, minutes = 15, seconds = 45, milliseconds = 250 }

    Maybe.map2 compare past past   -- Just EQ
    Maybe.map2 compare past future -- Just LT
    Maybe.map2 compare future past -- Just GT

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


{-| Returns a list of [DateTimes](DateTime-DateTime#DateTime) for the given `Year` and `Month` combination.
The `Time` parts of the resulting list will be equal to the `Time` portion of the [DateTime](DateTime-DateTime#DateTime)
that was provided.

    dt = fromRawParts { day = 26, month = Aug, year = 2019 } { hours = 21, minutes = 0, seconds = 0, milliseconds = 0 }

    Maybe.map getDatesInMonth dt
    -- Just
    --   [ DateTime { date = Date { day = Day 1, month = Aug, year = Year 2019 }, time = Time { hours = Hour 21, minutes = Minute 0, seconds = Second 0, milliseconds = Millisecond 0 } }
    --   , DateTime { date = Date { day = Day 2, month = Aug, year = Year 2019 }, time = Time { hours = Hour 21, minutes = Minute 0, seconds = Second 0, milliseconds = Millisecond 0 } }
    --   , DateTime { date = Date { day = Day 3, month = Aug, year = Year 2019 }, time = Time { hours = Hour 21, minutes = Minute 0, seconds = Second 0, milliseconds = Millisecond 0 } }
    --   ...
    --   , DateTime { date = Date { day = Day 29, month = Aug, year = Year 2019 }, time = Time { hours = Hour 21, minutes = Minute 0, seconds = Second 0, milliseconds = Millisecond 0 } }
    --   , DateTime { date = Date { day = Day 30, month = Aug, year = Year 2019 }, time = Time { hours = Hour 21, minutes = Minute 0, seconds = Second 0, milliseconds = Millisecond 0 } }
    --   , DateTime { date = Date { day = Day 13, month = Aug, year = Year 2019 }, time = Time { hours = Hour 21, minutes = Minute 0, seconds = Second 0, milliseconds = Millisecond 0 } }
    --   ]

-}
getDatesInMonth : DateTime -> List DateTime
getDatesInMonth =
    Internal.getDatesInMonth


{-| Returns an incrementally sorted [DateTime](DateTime-DateTime#DateTime) list based on the **start** and **end** `DateTime` parameters.
The `Time` parts of the resulting list will be equal to the `Time` argument that was provided.
_**The resulting list will include both start and end dates**_.

    start = fromRawParts { day = 26, month = Feb, year = 2020 } { hours = 12, minutes = 30, seconds = 45, milliseconds = 0 }
    end = fromRawParts { day = 1, month = Mar, year = 2020 } { hours = 16, minutes = 30, seconds = 45, milliseconds = 0 }
    defaultTime = Clock.fromRawParts { hours = 21, minutes = 0, seconds = 0, milliseconds = 0 }

    Maybe.map3 getDateRange start end defaultTime
    -- Just
    --   [ DateTime { date = Date { day = Day 26, month = Feb, year = Year 2020 }, time = Time { hours = Hour 21, minutes = Minute 0, seconds = Second 0, milliseconds = Millisecond 0 } }
    --   , DateTime { date = Date { day = Day 27, month = Feb, year = Year 2020 }, time = Time { hours = Hour 21, minutes = Minute 0, seconds = Second 0, milliseconds = Millisecond 0 } }
    --   , DateTime { date = Date { day = Day 28, month = Feb, year = Year 2020 }, time = Time { hours = Hour 21, minutes = Minute 0, seconds = Second 0, milliseconds = Millisecond 0 } }
    --   , DateTime { date = Date { day = Day 29, month = Feb, year = Year 2020 }, time = Time { hours = Hour 21, minutes = Minute 0, seconds = Second 0, milliseconds = Millisecond 0 } }
    --   , DateTime { date = Date { day = Day 1, month = Mar, year = Year 2020 }, time = Time { hours = Hour 21, minutes = Minute 0, seconds = Second 0, milliseconds = Millisecond 0 } }
    --   ]

-}
getDateRange : DateTime -> DateTime -> Clock.Time -> List DateTime
getDateRange =
    Internal.getDateRange


{-| Sorts incrementally a list of [DateTime](DateTime-DateTime#DateTime).

    dt = fromRawParts { day = 26, month = Aug, year = 1920 } { hours = 12, minutes = 30, seconds = 45, milliseconds = 0 }
    dt2 = fromRawParts { day = 26, month = Aug, year = 1920 } { hours = 21, minutes = 0, seconds = 0, milliseconds = 0 }
    dt3 = fromRawParts { day = 1, month = Jan, year = 1970 } { hours = 0, minutes = 0, seconds = 0, milliseconds = 0 }
    dt4 = fromRawParts { day = 1, month = Jan, year = 1970 } { hours = 14, minutes = 40, seconds = 20, milliseconds = 120 }
    dt5 = fromRawParts { day = 25, month = Dec, year = 2020 } { hours = 14, minutes = 40, seconds = 20, milliseconds = 120 }
    dt6 = fromRawParts { day = 25, month = Dec, year = 2020 } { hours = 14, minutes = 40, seconds = 20, milliseconds = 150 }

    sort (List.filterMap identity [ dt4, dt2, dt6, dt5, dt, dt3 ])
    -- [ DateTime { date = Date { day = Day 26, month = Aug, year = Year 1920 }, time = Time { hours = Hour 12, minutes = Minute 30, seconds = Second 45, milliseconds = Millisecond 0 } }
    -- , DateTime { date = Date { day = Day 26, month = Aug, year = Year 1920 }, time = Time { hours = Hour 21, minutes = Minute 0, seconds = Second 0, milliseconds = Millisecond 0 } }
    -- , DateTime { date = Date { day = Day 1, month = Jan, year = Year 1970 }, time = Time { hours = Hour 0, minutes = Minute 0, seconds = Second 0, milliseconds = Millisecond 0 } }
    -- , DateTime { date = Date { day = Day 1, month = Jan, year = Year 1970 }, time = Time { hours = Hour 14, minutes = Minute 40, seconds = Second 20, milliseconds = Millisecond 120 } }
    -- , DateTime { date = Date { day = Day 25, month = Dec, year = Year 2020 }, time = Time { hours = Hour 14, minutes = Minute 40, seconds = Second 20, milliseconds = Millisecond 120 } }
    -- , DateTime { date = Date { day = Day 25, month = Dec, year = Year 2020 }, time = Time { hours = Hour 14, minutes = Minute 40, seconds = Second 20, milliseconds = Millisecond 150 } }
    -- ]

-}
sort : List DateTime -> List DateTime
sort =
    Internal.sort
