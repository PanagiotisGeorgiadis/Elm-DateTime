module DateTime.Internal exposing
    ( DateTime(..)
    , fromPosix, fromRawParts, fromDateAndTime
    , toPosix, toMillis
    , getDate, getTime, getYear, getMonth, getDay, getHours, getMinutes, getSeconds, getMilliseconds
    , setDate, setTime, setYear, setMonth, setDay, setHours, setMinutes, setSeconds, setMilliseconds
    , incrementYear, incrementMonth, incrementDay, incrementHours, incrementMinutes, incrementSeconds, incrementMilliseconds
    , decrementYear, decrementMonth, decrementDay, decrementHours, decrementMinutes, decrementSeconds, decrementMilliseconds
    , compare, compareDates, compareTime
    , getDateRange, getDatesInMonth, getDayDiff, getWeekday, isLeapYear, sort
    , rollDayBackwards, rollDayForward
    )

{-| The [DateTime](DateTime#) module was introduced in order to keep track of both the
[Date](Calendar#Date) and [Time](Clock#Time). The `DateTime`
consists of a `Day`, `Month`, `Year`, `Hours`, `Minutes`, `Seconds` and `Milliseconds`.
You can construct a `DateTime` either by using a [Posix](https://package.elm-lang.org/packages/elm/time/latest/Time#Posix)
or by using an existing [Date](Calendar#Date) and [Time](Clock#Time) combination. Otherwise
you can _**attempt**_ to construct a `DateTime` by using a combination of a
[RawDate](Calendar#RawDate) and a [RawClock](Clock#RawClock).

@docs DateTime


# Creating a `DateTime`

@docs fromPosix, fromRawParts, fromDateAndTime


# Conversions

@docs toPosix, toMillis


# Accessors

@docs getDate, getTime, getYear, getMonth, getDay, getHours, getMinutes, getSeconds, getMilliseconds


# Setters

@docs setDate, setTime, setYear, setMonth, setDay, setHours, setMinutes, setSeconds, setMilliseconds


# Increment values

@docs incrementYear, incrementMonth, incrementDay, incrementHours, incrementMinutes, incrementSeconds, incrementMilliseconds


# Decrement values

@docs decrementYear, decrementMonth, decrementDay, decrementHours, decrementMinutes, decrementSeconds, decrementMilliseconds


# Compare values

@docs compare, compareDates, compareTime


# Utilities

@docs getDateRange, getDatesInMonth, getDayDiff, getWeekday, isLeapYear, sort


# Exposed for Testing Purposes

@docs rollDayBackwards, rollDayForward

-}

import Array
import Calendar
import Calendar.Internal as Calendar_
import Clock
import Clock.Internal as Clock_
import Time


{-| An instant in time, composed of a calendar date, clock time and time zone.
-}
type DateTime
    = DateTime InternalDateTime


{-| The internal representation of `DateTime` and its constituent parts.
-}
type alias InternalDateTime =
    { date : Calendar.Date
    , time : Clock.Time
    }



-- Creating a `DateTime`


{-| Create a `DateTime` from a [Posix](https://package.elm-lang.org/packages/elm/time/latest/Time#Posix) time.

    fromPosix (Time.millisToPosix 0)
    -- DateTime { date = Date { day = Day 1, month = Jan, year = Year 1970 }, time = Time { hours = Hour 0, minutes = Minute 0, seconds = Second 0, milliseconds = Millisecond 0 } } : DateTime

    fromPosix (Time.millisToPosix 1566795954000)
    -- DateTime { date = Date { day = Day 26, month = Aug, year = Year 2019 }, time = Time { hours = Hour 5, minutes = Minute 5, seconds = Second 54, milliseconds = Millisecond 0 } } : DateTime

-}
fromPosix : Time.Posix -> DateTime
fromPosix timePosix =
    DateTime
        { date = Calendar_.fromPosix timePosix
        , time = Clock_.fromPosix timePosix
        }


{-| Attempts to construct a new `DateTime` object from its raw constituent parts. Returns `Nothing` if
any parts or their combination would result in an invalid [DateTime](DateTime#DateTime).

    fromRawParts { day = 26, month = Aug, year = 2019 } { hours = 12, minutes = 30, seconds = 45, milliseconds = 0 }
    -- Just (DateTime { date = Date { day = Day 26, month = Aug, year = Year 2019 }, time = Time { hours = Hour 12, minutes = Minute 30, seconds = Second 45, milliseconds = Millisecond 0 }}) : Maybe DateTime

    fromRawParts { day = 29, month = Feb, year = 2019 } { hours = 16, minutes = 30, seconds = 45, milliseconds = 0 }
    -- Nothing : Maybe DateTime

    fromRawParts { day = 15, month = Nov, year = 2019 } { hours = 24, minutes = 20, seconds = 40, milliseconds = 0 }
    -- Nothing : Maybe DateTime

-}
fromRawParts : Calendar.RawDate -> Clock.RawTime -> Maybe DateTime
fromRawParts rawDate rawTime =
    Maybe.map2
        (\date time ->
            DateTime (InternalDateTime date time)
        )
        (Calendar.fromRawParts rawDate)
        (Clock.fromRawParts rawTime)


{-| Create a [DateTime](DateTime#DateTime) by combining a [Date](Calendar#Date) and [Time](Clock#Time).

    -- date == 26 Aug 2019
    -- time == 12:30:45.000

    fromDateAndTime date time
    -- DateTime { date = Date { day = Day 26, month = Aug, year = Year 2019 }, time = Time { hours = Hour 12, minutes = Minute 30, seconds = Second 45, milliseconds = Millisecond 0 } } : DateTime

-}
fromDateAndTime : Calendar.Date -> Clock.Time -> DateTime
fromDateAndTime date time =
    DateTime
        { date = date
        , time = time
        }



-- Conversions


{-| Converts a `DateTime` to a posix time. The result is relative to the [Epoch](https://en.wikipedia.org/wiki/Unix_time).
This basically means that **if the DateTime provided is after the Epoch** the result will be a **positive posix time.** Otherwise the
result will be a **negative posix time**.

    -- dateTime  == 25 Dec 2019 19:23:45.000
    toPosix dateTime -- Posix 1577301825000 : Posix

    -- dateTime2 == 1 Jan 1970 00:00:00.000 : Posix
    toPosix dateTime2 -- Posix 0

    -- dateTime3 == 8 Jan 1920 04:36:15.000
    toPosix dateTime3 -- Posix -1577301825000 : Posix

-}
toPosix : DateTime -> Time.Posix
toPosix =
    Time.millisToPosix << toMillis


{-| Convers a `DateTime` to the equivalent milliseconds. The result is relative to the [Epoch](https://en.wikipedia.org/wiki/Unix_time).
This basically means that **if the DateTime provided is after the Epoch** the result will be a **positive number** representing the milliseconds
that have elapsed since the Epoch. Otherwise the result will be a negative number representing the milliseconds required in order to reach the Epoch.

    -- dateTime  == 25 Dec 2019 19:23:45.000
    toMillis dateTime -- 1577301825000 : Int

    -- dateTime2 == 1 Jan 1970 00:00:00.000
    toMillis dateTime2 -- 0 : Int

    -- dateTime3 == 8 Jan 1920 04:36:15.000
    toMillis dateTime3 -- -1577301825000 : Int

-}
toMillis : DateTime -> Int
toMillis (DateTime { date, time }) =
    Calendar.toMillis date + Clock.toMillis time



-- Accessors


{-| Extract the [Date](Calendar#Date) from a `DateTime`.

    -- dateTime == 25 Dec 2019 16:45:30.000
    getDate dateTime -- 25 Dec 2019 : Calendar.Date

-}
getDate : DateTime -> Calendar.Date
getDate (DateTime { date }) =
    date


{-| Extract the [Time](Clock#Time) from a `DateTime`.

    -- dateTime == 25 Dec 2019 16:45:30.000
    getTime dateTime -- 16:45:30.000 : Clock.Time

-}
getTime : DateTime -> Clock.Time
getTime (DateTime { time }) =
    time


{-| Extract the `Year` part of a `DateTime` as an Int.

    -- dateTime == 25 Dec 2019 16:45:30.000
    getYear dateTime -- 2019 : Int

-}
getYear : DateTime -> Int
getYear =
    Calendar.getYear << getDate


{-| Extract the `Month` part of a `DateTime` as a [Month](https://package.elm-lang.org/packages/elm/time/latest/Time#Month).

    -- dateTime == 25 Dec 2019 16:45:30.000
    getMonth dateTime -- Dec : Time.Month

-}
getMonth : DateTime -> Time.Month
getMonth =
    Calendar.getMonth << getDate


{-| Extract the `Day` part of `DateTime` as an Int.

    -- dateTime == 25 Dec 2019 16:45:30.000
    getDay dateTime -- 25 : Int

-}
getDay : DateTime -> Int
getDay =
    Calendar.getDay << getDate


{-| Extract the `Hour` part of `DateTime` as an Int.

    -- dateTime == 25 Dec 2019 16:45:30.000
    getHours dateTime -- 16 : Int

-}
getHours : DateTime -> Int
getHours =
    Clock.getHours << getTime


{-| Extract the `Minute` part of `DateTime` as an Int.

    -- dateTime == 25 Dec 2019 16:45:30.000
    getMinutes dateTime -- 45 : Int

-}
getMinutes : DateTime -> Int
getMinutes =
    Clock.getMinutes << getTime


{-| Extract the `Second` part of `DateTime` as an Int.

    -- dateTime == 25 Dec 2019 16:45:30.000
    getSeconds dateTime -- 30 : Int

-}
getSeconds : DateTime -> Int
getSeconds =
    Clock.getSeconds << getTime


{-| Extract the `Millisecond` part of `DateTime` as an Int.

    -- dateTime == 25 Dec 2019 16:45:30.000
    getMilliseconds dateTime -- 0 : Int

-}
getMilliseconds : DateTime -> Int
getMilliseconds =
    Clock.getMilliseconds << getTime



-- Setters


{-| Sets the `Date` part of a [DateTime#DateTime].

    -- date == 26 Aug 2019
    -- dateTime == 25 Dec 2019 16:45:30.000
    setDate date dateTime -- 26 Aug 2019 16:45:30.000

-}
setDate : Calendar.Date -> DateTime -> DateTime
setDate date (DateTime { time }) =
    DateTime
        { date = date
        , time = time
        }


{-| Sets the `Time` part of a [DateTime#DateTime].

    -- dateTime == 25 Dec 2019 16:45:30.000
    setTime Clock.midnight dateTime -- 25 Dec 2019 00:00:00.000

-}
setTime : Clock.Time -> DateTime -> DateTime
setTime time (DateTime { date }) =
    DateTime
        { date = date
        , time = time
        }


{-| Attempts to set the `Year` part of a [Calendar.Date](Calendar#Date) in a `DateTime`.

    -- dateTime == 29 Feb 2020 15:30:30.000
    setYear 2024 dateTime -- Just (29 Feb 2024 15:30:30.000) : Maybe DateTime

    setYear 2019 dateTime -- Nothing : Maybe DateTime

-}
setYear : Int -> DateTime -> Maybe DateTime
setYear year dateTime =
    Maybe.map (\y -> setDate y dateTime) <|
        Calendar.setYear year (getDate dateTime)


{-| Attempts to set the `Month` part of a [Calendar.Date](Calendar#Date) in a `DateTime`.

    -- dateTime == 31 Jan 2019 15:30:30.000
    setMonth Aug dateTime -- Just (31 Aug 2019 15:30:30.000) : Maybe DateTime

    setMonth Apr dateTime -- Nothing : Maybe DateTime

-}
setMonth : Time.Month -> DateTime -> Maybe DateTime
setMonth month dateTime =
    Maybe.map (\m -> setDate m dateTime) <|
        Calendar.setMonth month (getDate dateTime)


{-| Attempts to set the `Day` part of a [Calendar.Date](Calendar#Date) in a `DateTime`.

    -- dateTime == 31 Jan 2019 15:30:30.000
    setDay 25 dateTime -- Just (25 Jan 2019 15:30:30.000) : Maybe DateTime

    setDay 32 dateTime -- Nothing : Maybe DateTime

-}
setDay : Int -> DateTime -> Maybe DateTime
setDay day dateTime =
    Maybe.map (\d -> setDate d dateTime) <|
        Calendar.setDay day (getDate dateTime)


{-| Attempts to set the `Hours` part of a [Clock.Time](Clock#Time) in a DateTime.

    -- dateTime == 2 Jul 2019 12:00:00.000
    setHours 23 dateTime -- Just (2 Jul 2019 23:00:00.000) : Maybe DateTime

    setHours 24 dateTime -- Nothing : Maybe DateTime

-}
setHours : Int -> DateTime -> Maybe DateTime
setHours hours dateTime =
    Maybe.map (\h -> setTime h dateTime) <|
        Clock.setHours hours (getTime dateTime)


{-| Attempts to set the `Minutes` part of a [Clock.Time](Clock#Time) in a DateTime.

    -- dateTime == 2 Jul 2019 12:00:00.000
    setMinutes 36 dateTime -- Just (2 Jul 2019 12:36:00.000) : Maybe DateTime

    setMinutes 60 dateTime -- Nothing : Maybe DateTime

-}
setMinutes : Int -> DateTime -> Maybe DateTime
setMinutes minutes dateTime =
    Maybe.map (\m -> setTime m dateTime) <|
        Clock.setMinutes minutes (getTime dateTime)


{-| Attempts to set the `Seconds` part of a [Clock.Time](Clock#Time) in a DateTime.

    -- dateTime == 2 Jul 2019 12:00:00.000
    setSeconds 20 dateTime -- Just (2 Jul 2019 12:00:20.000) : Maybe DateTime

    setSeconds 60 dateTime -- Nothing : Maybe DateTime

-}
setSeconds : Int -> DateTime -> Maybe DateTime
setSeconds seconds dateTime =
    Maybe.map (\s -> setTime s dateTime) <|
        Clock.setSeconds seconds (getTime dateTime)


{-| Attempts to set the `Milliseconds` part of a [Clock.Time](Clock#Time) in a DateTime.

    -- dateTime == 2 Jul 2019 12:00:00.000
    setMilliseconds 589 dateTime -- Just (2 Jul 2019 12:00:00.589) : Maybe DateTime

    setMilliseconds 1000 dateTime -- Nothing : Maybe DateTime

-}
setMilliseconds : Int -> DateTime -> Maybe DateTime
setMilliseconds milliseconds dateTime =
    Maybe.map (\m -> setTime m dateTime) <|
        Clock.setMilliseconds milliseconds (getTime dateTime)



-- Increment values


{-| Increments the `Year` in a given [DateTime](DateTime#DateTime) while preserving the `Month`, and `Day` parts.
_The [Time](Clock#Time) related parts will remain the same._

    -- dateTime  == 31 Jan 2019 15:30:45.100
    incrementYear dateTime -- 31 Jan 2020 15:30:45.100 : DateTime

    -- dateTime2 == 29 Feb 2020 15:30:45.100
    incrementYear dateTime2 -- 28 Feb 2021 15:30:45.100 : DateTime

**Note:** In the first example, incrementing the `Year` causes no changes in the `Month` and `Day` parts.
On the second example we see that the `Day` part is different than the input. This is because the resulting date in the `DateTime`
would be an invalid date ( _**29th of February 2021**_ ). As a result of this scenario we fall back to the last valid day
of the given `Month` and `Year` combination.

-}
incrementYear : DateTime -> DateTime
incrementYear (DateTime { date, time }) =
    DateTime
        { date = Calendar.incrementYear date
        , time = time
        }


{-| Increments the `Month` in a given [DateTime](DateTime#DateTime). It will also roll over to the next year where applicable.
_The [Time](Clock#Time) related parts will remain the same._

    -- dateTime  == 15 Sep 2019 15:30:45.100
    incrementMonth dateTime -- 15 Oct 2019 15:30:45.100 : DateTime

    -- dateTime2 == 15 Dec 2019 15:30:45.100
    incrementMonth dateTime2 -- 15 Jan 2020 15:30:45.100 : DateTime

    -- dateTime3 == 30 Jan 2019 15:30:45.100
    incrementMonth dateTime3 -- 28 Feb 2019 15:30:45.100 : DateTime

**Note:** In the first example, incrementing the `Month` causes no changes in the `Year` and `Day` parts while on the second
example it rolls forward the 'Year'. On the last example we see that the `Day` part is different than the input. This is because
the resulting date would be an invalid one ( _**31st of February 2019**_ ). As a result of this scenario we fall back to the last
valid day of the given `Month` and `Year` combination.

-}
incrementMonth : DateTime -> DateTime
incrementMonth (DateTime { date, time }) =
    DateTime
        { date = Calendar.incrementMonth date
        , time = time
        }


{-| Increments the `Day` in a given [DateTime](DateTime#DateTime). Will also increment `Month` and `Year` where applicable.

    -- dateTime  == 25 Aug 2019 15:30:45.100
    incrementDay dateTime -- 26 Aug 2019 15:30:45.100 : DateTime

    -- dateTime2 == 31 Dec 2019 15:30:45.100
    incrementDay dateTime2 -- 1 Jan 2020 15:30:45.100 : DateTime

-}
incrementDay : DateTime -> DateTime
incrementDay (DateTime { date, time }) =
    DateTime
        { date = Calendar.incrementDay date
        , time = time
        }


{-| Increments the `Hours` in a given [DateTime](DateTime#DateTime). Will also increment `Day`, `Month`, `Year` where applicable.

    -- dateTime  == 25 Aug 2019 15:30:45.100
    incrementHours dateTime -- 25 Aug 2019 16:30:45.100 : DateTime

    -- dateTime2 == 31 Dec 2019 23:00:00.000
    incrementHours dateTime2 -- 1 Jan 2020 00:00:00.000 : DateTime

-}
incrementHours : DateTime -> DateTime
incrementHours (DateTime { date, time }) =
    let
        ( updatedTime, shouldRoll ) =
            Clock.incrementHours time
    in
    DateTime
        { date = rollDayForward shouldRoll date
        , time = updatedTime
        }


{-| Increments the `Minutes` in a given [DateTime](DateTime#DateTime). Will also increment `Hours`, `Day`, `Month`, `Year` where applicable.

    -- dateTime  == 25 Aug 2019 15:30:45.100
    incrementMinutes dateTime -- 25 Aug 2019 15:31:45.100 : DateTime

    -- dateTime2 == 31 Dec 2019 23:59:00.000
    incrementMinutes dateTime2 -- 1 Jan 2020 00:00:00.000 : DateTime

-}
incrementMinutes : DateTime -> DateTime
incrementMinutes (DateTime { date, time }) =
    let
        ( updatedTime, shouldRoll ) =
            Clock.incrementMinutes time
    in
    DateTime
        { date = rollDayForward shouldRoll date
        , time = updatedTime
        }


{-| Increments the `Seconds` in a given [DateTime](DateTime#DateTime). Will also increment `Minutes`, `Hours`, `Day`, `Month`, `Year` where applicable.

    -- dateTime  == 25 Aug 2019 15:30:45.100
    incrementSeconds dateTime -- 25 Aug 2019 15:30:46.100 : DateTime

    -- dateTime2 == 31 Dec 2019 23:59:59.000
    incrementSeconds dateTime2 -- 1 Jan 2020 00:00:00.000 : DateTime

-}
incrementSeconds : DateTime -> DateTime
incrementSeconds (DateTime { date, time }) =
    let
        ( updatedTime, shouldRoll ) =
            Clock.incrementSeconds time
    in
    DateTime
        { date = rollDayForward shouldRoll date
        , time = updatedTime
        }


{-| Increments the `Milliseconds` in a given [DateTime](DateTime#DateTime). Will also increment `Seconds`, `Minutes`, `Hours`, `Day`, `Month`, `Year` where applicable.

    -- dateTime  == 25 Aug 2019 15:30:45.100
    incrementMilliseconds dateTime -- 25 Aug 2019 15:30:45:101 : DateTime

    -- dateTime2 == 31 Dec 2019 23:59:59.999
    incrementMilliseconds dateTime2 -- 1 Jan 2020 00:00:00.000 : DateTime

-}
incrementMilliseconds : DateTime -> DateTime
incrementMilliseconds (DateTime { date, time }) =
    let
        ( updatedTime, shouldRoll ) =
            Clock.incrementMilliseconds time
    in
    DateTime
        { date = rollDayForward shouldRoll date
        , time = updatedTime
        }



-- Decrement values


{-| Decrements the `Year` in a given [DateTime](DateTime#DateTime) while preserving the `Month` and `Day`.
_The [Time](Clock#Time) related parts will remain the same._

    -- dateTime  == 31 Jan 2019 15:30:45.100
    decrementYear dateTime -- 31 Jan 2018 15:30:45.100 : DateTime

    -- dateTime2 == 29 Feb 2020 15:30:45.100
    decrementYear dateTime2 -- 28 Feb 2019 15:30:45.100 : DateTime

**Note:** In the first example, decrementing the `Year` causes no changes in the `Month` and `Day` parts.
On the second example we see that the `Day` part is different than the input. This is because the resulting date in the `DateTime`
would be an invalid date ( _**29th of February 2019**_ ). As a result of this scenario we fall back to the last valid day
of the given `Month` and `Year` combination.

-}
decrementYear : DateTime -> DateTime
decrementYear (DateTime { date, time }) =
    DateTime
        { date = Calendar.decrementYear date
        , time = time
        }


{-| Decrements the `Month` in a given [DateTime](DateTime#DateTime). It will also roll backwards to the previous year where applicable.
_The [Time](Clock#Time) related parts will remain the same._

    -- dateTime  == 15 Sep 2019 15:30:45.100
    decrementMonth dateTime -- 15 Aug 2019 15:30:45.100 : DateTime

    -- dateTime2 == 15 Jan 2020 15:30:45.100
    decrementMonth dateTime2 -- 15 Dec 2019 15:30:45.100 : DateTime

    -- dateTime3 == 31 Dec 2019 15:30:45.100
    decrementMonth dateTime3 -- 30 Nov 2019 15:30:45.100 : DateTime

**Note:** In the first example, decrementing the `Month` causes no changes in the `Year` and `Day` parts while
on the second example it rolls backwards the `Year`. On the last example we see that the `Day` part is different
than the input. This is because the resulting date would be an invalid one ( _**31st of November 2019**_ ). As a result
of this scenario we fall back to the last valid day of the given `Month` and `Year` combination.

-}
decrementMonth : DateTime -> DateTime
decrementMonth (DateTime { date, time }) =
    DateTime
        { date = Calendar.decrementMonth date
        , time = time
        }


{-| Decrements the `Day` in a given [DateTime](DateTime#DateTime). Will also decrement `Month` and `Year` where applicable.

    -- dateTime  == 27 Aug 2019 15:30:45.100
    decrementDay dateTime -- 26 Aug 2019 15:30:45.100 : DateTime

    -- dateTime2 == 1 Jan 2020 15:30:45.100
    decrementDay dateTime2 -- 31 Dec 2019 15:30:45.100 : DateTime

-}
decrementDay : DateTime -> DateTime
decrementDay (DateTime { date, time }) =
    DateTime
        { date = Calendar.decrementDay date
        , time = time
        }


{-| Decrements the `Hours` in a given [DateTime](DateTime#DateTime). Will also decrement `Day`, `Month`, `Year` where applicable.

    -- dateTime  == 25 Aug 2019 15:30:45.100
    decrementHours dateTime -- 25 Aug 2019 14:30:45.100 : DateTime

    -- dateTime2 == 1 Jan 2020 00:00:00.000
    decrementHours dateTime2 -- 31 Dec 2019 23:00:00.000 : DateTime

-}
decrementHours : DateTime -> DateTime
decrementHours (DateTime { date, time }) =
    let
        ( updatedTime, shouldRoll ) =
            Clock.decrementHours time
    in
    DateTime
        { date = rollDayBackwards shouldRoll date
        , time = updatedTime
        }


{-| Decrements the `Minutes` in a given [DateTime](DateTime#DateTime). Will also decrement `Hours`, `Day`, `Month`, `Year` where applicable.

    -- dateTime  == 25 Aug 2019 15:30:45.100
    decrementMinutes dateTime -- 25 Aug 2019 15:29:45.100 : DateTime

    -- dateTime2 == 1 Jan 2020 00:00:00.000
    decrementMinutes dateTime2 -- 31 Dec 2019 23:59:00.000 : DateTime

-}
decrementMinutes : DateTime -> DateTime
decrementMinutes (DateTime { date, time }) =
    let
        ( updatedTime, shouldRoll ) =
            Clock.decrementMinutes time
    in
    DateTime
        { date = rollDayBackwards shouldRoll date
        , time = updatedTime
        }


{-| Decrements the `Seconds` in a given [DateTime](DateTime#DateTime). Will also decrement `Minutes`, `Hours`, `Day`, `Month`, `Year` where applicable.

    -- dateTime  == 25 Aug 2019 15:30:45.100
    decrementSeconds dateTime -- 25 Aug 2019 15:30:44.100 : DateTime

    -- dateTime2 == 1 Jan 2020 00:00:00.000
    decrementSeconds dateTime2 -- 31 Dec 2019 23:59:59.000 : DateTime

-}
decrementSeconds : DateTime -> DateTime
decrementSeconds (DateTime { date, time }) =
    let
        ( updatedTime, shouldRoll ) =
            Clock.decrementSeconds time
    in
    DateTime
        { date = rollDayBackwards shouldRoll date
        , time = updatedTime
        }


{-| Decrements the `Milliseconds` in a given [DateTime](DateTime#DateTime). Will also decrement `Seconds`, `Minutes`, `Hours`, `Day`, `Month`, `Year` where applicable.

    -- dateTime  == 25 Aug 2019 15:30:45.100
    decrementMilliseconds dateTime -- 25 Aug 2019 15:30:45.099 : DateTime

    -- dateTime2 == 1 Jan 2020 00:00:00.000
    decrementMilliseconds dateTime2 -- 31 Dec 2019 23:59:59.999 : DateTime

-}
decrementMilliseconds : DateTime -> DateTime
decrementMilliseconds (DateTime { date, time }) =
    let
        ( updatedTime, shouldRoll ) =
            Clock.decrementMilliseconds time
    in
    DateTime
        { date = rollDayBackwards shouldRoll date
        , time = updatedTime
        }



-- Compare values


{-| Compares the two given [DateTimes](DateTime#DateTime) and returns an [Order](https://package.elm-lang.org/packages/elm/core/latest/Basics#Order).

    -- past   == 25 Aug 2019 12:15:45.250
    -- future == 26 Aug 2019 12:15:45.250
    compare past past -- EQ : Order

    compare past future -- LT : Order

    compare future past -- GT : Order

-}
compare : DateTime -> DateTime -> Order
compare (DateTime lhs) (DateTime rhs) =
    case Calendar.compare lhs.date rhs.date of
        EQ ->
            Clock.compare lhs.time rhs.time

        ord ->
            ord


{-| Compares the [Date](Calendar#Date) part of two given [DateTime](DateTime#DateTime) and returns an [Order](https://package.elm-lang.org/packages/elm/core/latest/Basics#Order).

    -- dateTime  == 25 Aug 2019 12:15:45.250
    -- dateTime2 == 25 Aug 2019 21:00:00.000
    -- dateTime3 == 26 Aug 2019 12:15:45.250
    compare dateTime dateTime2 -- EQ : Order

    compare dateTime dateTime3 -- LT : Order

    compare dateTime3 dateTime2 -- GT : Order

-}
compareDates : DateTime -> DateTime -> Order
compareDates (DateTime lhs) (DateTime rhs) =
    Calendar.compare lhs.date rhs.date


{-| Compares the [Time](Clock#Time) part of two given [DateTime](DateTime#DateTime) and returns an [Order](https://package.elm-lang.org/packages/elm/core/latest/Basics#Order).

    -- dateTime  == 25 Aug 2019 12:15:45.250
    -- dateTime2 == 25 Aug 2019 21:00:00.000
    -- dateTime3 == 26 Aug 2019 12:15:45.250
    compare dateTime dateTime3 -- EQ : Order

    compare dateTime dateTime2 -- LT : Order

    compare dateTime2 dateTime3 -- GT : Order

-}
compareTime : DateTime -> DateTime -> Order
compareTime (DateTime lhs) (DateTime rhs) =
    Clock.compare lhs.time rhs.time



-- Utilities


{-| Returns an incrementally sorted [DateTime](DateTime#DateTime) list based on the **start** and **end** `DateTime` parameters.
The `Time` parts of the resulting list will be equal to the `Time` argument that was provided.
_**The resulting list will include both start and end dates**_.

    -- start       == 26 Feb 2020 12:30:45.000
    -- end         == 1  Mar 2020 16:30:45.000
    -- defaultTime == 21:00:00.000

    getDateRange start end defaultTime
    -- [ 26 Feb 2020 21:00:00.000, 27 Feb 2020 21:00:00.000, 28 Feb 2020 21:00:00.000, 29 Feb 2020 21:00:00.000, 1 Mar 2020 21:00:00.000 ] : List DateTime

-}
getDateRange : DateTime -> DateTime -> Clock.Time -> List DateTime
getDateRange (DateTime start) (DateTime end) time =
    List.map
        (\date ->
            DateTime { date = date, time = time }
        )
        (Calendar.getDateRange start.date end.date)


{-| Returns a list of [DateTimes](DateTime#DateTime) for the given `Year` and `Month` combination.
The `Time` parts of the resulting list will be equal to the `Time` portion of the [DateTime](DateTime#DateTime)
that was provided.

    -- dateTime == 26 Aug 2019 21:00:00.000

    getDatesInMonth dateTime
    --   [ 1  Aug 2019  21:00:00.000
    --   , 2  Aug 2019  21:00:00.000
    --   , 3  Aug 2019  21:00:00.000
    --   ...
    --   , 29 Aug 2019 21:00:00.000
    --   , 30 Aug 2019 21:00:00.000
    --   , 31 Aug 2019 21:00:00.000
    --   ] : List DateTime

-}
getDatesInMonth : DateTime -> List DateTime
getDatesInMonth (DateTime { date, time }) =
    List.map
        (\date_ ->
            DateTime { date = date_, time = time }
        )
        (Calendar.getDatesInMonth date)


{-| Returns the difference in days between two [DateTimes](DateTime#DateTime).
We can have a negative difference of days as can be seen in the examples below.

    -- dateTime  == 24 Aug 2019 12:00:00.000
    -- dateTime2 == 24 Aug 2019 21:00:00.000
    -- dateTime3 == 26 Aug 2019 15:45:00.000
    getDayDiff dateTime dateTime2 -- 0 : Int

    getDayDiff dateTime dateTime3 -- 2  : Int

    getDayDiff dateTime3 dateTime -- -2 : Int

-}
getDayDiff : DateTime -> DateTime -> Int
getDayDiff (DateTime lhs) (DateTime rhs) =
    Calendar.getDayDiff lhs.date rhs.date


{-| Returns the weekday of a specific [DateTime](DateTime#DateTime).

    -- dateTime == 26 Aug 2019 12:30:45.000
    getWeekday dateTime -- Mon : Weekday

-}
getWeekday : DateTime -> Time.Weekday
getWeekday (DateTime dateTime) =
    Calendar.getWeekday dateTime.date


{-| Checks if the `Year` part of the given [DateTime](DateTime#DateTime) is a leap year.

    -- dateTime  == 25 Dec 2019 21:00:00.000
    isLeapYear dateTime -- False

    -- dateTime2 == 25 Dec 2020 12:00:00.000
    isLeapYear dateTime2 -- True

-}
isLeapYear : DateTime -> Bool
isLeapYear (DateTime { date, time }) =
    Calendar.isLeapYear date


{-| Sorts incrementally a list of [DateTime](DateTime#DateTime).

    -- dateTime  == 26 Aug 1920 12:30:45.000
    -- dateTime2 == 26 Aug 1920 21:00:00.000
    -- dateTime3 == 1  Jan 1970 00:00:00.000
    -- dateTime4 == 1  Jan 1970 14:40:20.120
    -- dateTime5 == 25 Dec 2020 14:40:20.120
    -- dateTime6 == 25 Dec 2020 14:40:20.150

    sort [ dateTime4, dateTime2, dateTime6, dateTime5, dateTime, dateTime3 ]
    -- [ 26 Aug 1920 12:30:45.000
    -- , 26 Aug 1920 21:00:00.000
    -- , 1  Jan 1970 00:00:00.000
    -- , 1  Jan 1970 14:40:20.120
    -- , 25 Dec 2020 14:40:20.120
    -- , 25 Dec 2020 14:40:20.120
    -- ] : List DateTime

-}
sort : List DateTime -> List DateTime
sort =
    List.sortBy toMillis


{-| Helper function that decides if we should 'roll' the Calendar.Date forward due to a Clock.Time change.
-}
rollDayForward : Bool -> Calendar.Date -> Calendar.Date
rollDayForward shouldRoll date =
    if shouldRoll then
        Calendar.incrementDay date

    else
        date


{-| Helper function that decides if we should 'roll' the Calendar.Date backwards due to a Clock.Time change.
-}
rollDayBackwards : Bool -> Calendar.Date -> Calendar.Date
rollDayBackwards shouldRoll date =
    if shouldRoll then
        Calendar.decrementDay date

    else
        date
