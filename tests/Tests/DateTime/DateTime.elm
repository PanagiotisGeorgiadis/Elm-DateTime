module Tests.DateTime.DateTime exposing
    ( DateTime(..)
    , fromPosix
    , getDate, getYear, getMonth, getDay, getWeekday, getTime, getHours, getMinutes, getSeconds, getMilliseconds
    , toPosix
    , getYearInt, getMonthInt, getDayInt, getHoursInt, getMinutesInt, getSecondsInt, getMillisecondsInt
    ,  InternalDateTime
      , daysSinceEpoch
        -- NEW

    )

{-| A complete datetime type.

@docs DateTime


# Creating a `DateTime`

@docs fromPosix, fromUtcDateAndTime


# Accessors

@docs getDate, getYear, getMonth, getDay, getWeekday, getTime, getHours, getMinutes, getSeconds, getMilliseconds


# Conversions

@docs toPosix


# NEW STUFF

@docs getYearInt, getMonthInt, getDayInt, getHoursInt, getMinutesInt, getSecondsInt, getMillisecondsInt

-}

import Array
import DateTime.Calendar as Calendar exposing (Day, Year)
import DateTime.Clock as Clock
import Time


{-| An instant in time, composed of a calendar date, clock time and time zone.
-}
type DateTime
    = DateTime InternalDateTime


type alias InternalDateTime =
    { date : Calendar.Date
    , time : Clock.Time
    }


{-| Create a `DateTime` from a time zone and posix time.

> fromPosix (Time.millisToPosix 0) |> year
> Year 1970 : Year

-}
fromPosix : Time.Posix -> DateTime
fromPosix timePosix =
    DateTime
        { date = Calendar.fromPosix timePosix
        , time = Clock.fromPosix timePosix
        }


{-| Get back a posix time.

> toPosix (fromPosix (Time.millisToPosix 0))
> Posix 0 : Time.Posix

-}
toPosix : DateTime -> Time.Posix
toPosix =
    Time.millisToPosix << toMillis


{-| Convers a 'DateTime' to the equivalent milliseconds since epoch.

> toMillis (fromPosix (Time.millisToPosix 0))
> 0 : Int

-}
toMillis : DateTime -> Int
toMillis (DateTime { date, time }) =
    Calendar.toMillis date + Clock.toMillis time


{-| Create a `DateTime` from a UTC date and time.
--- Think about this one
--- Update: I think that we don't need this function here since we can
--- always get the milliseconds from a DateTime and update them as we like
--- and then create a new date fromPosix.
--- Also all the operations like incrementing & decrementing are available
--- in Calendar or Time level.

-- fromUtcDateAndTime : Calendar.Date -> Clock.Time -> DateTime
-- fromUtcDateAndTime calendarDate clockTime =
-- let
-- posix : Time.Posix
-- posix =
-- Time.millisToPosix <|
-- daysToMillis (daysSinceEpoch calendarDate)
-- + Clock.toMillis clockTime
-- in
-- DateTime
-- { date = calendarDate
-- , time = clockTime
-- }

-}
fromUtcDateAndTime : Calendar.Date -> Clock.Time -> Maybe DateTime
fromUtcDateAndTime date time =
    Nothing


{-| Do we need that one ?
--- I think not...
-- yearsSinceEpoch : DateTime -> Int
-- yearsSinceEpoch (DateTime { date }) =
-- List.length <| List.range 1970 (Calendar.yearToInt (Calendar.getYear date))
-}
yearsSinceEpoch : DateTime -> Maybe Int
yearsSinceEpoch dateTime =
    Nothing


{-| Do we need that one ?
--- I think not...
-- daysSinceEpoch : DateTime -> Int
-- daysSinceEpoch (DateTime { date }) =
-- Calendar.toMillis date // Calendar.millisInADay
-}
daysSinceEpoch : DateTime -> Maybe Int
daysSinceEpoch dateTime =
    Nothing


{-| Extract the calendar date from a `DateTime`.

> getDate (fromPosix (Time.millisToPosix 0))
> Date { day = Day 1, month = Jan, year = Year 1970 } : Calendar.Date

--- Think if you want to expose that ????????
--- I think not with a first thought because why would the consumer want to access the date ?

-}
getDate : DateTime -> Calendar.Date
getDate (DateTime { date }) =
    date


{-| Extract the calendar year from a `DateTime`.

> getYear (fromPosix (Time.millisToPosix 0))
> Year 1970 : Year

-}
getYear : DateTime -> Year
getYear =
    getDate >> Calendar.getYear


{-| Extract the calendar month from a `DateTime`.

> getMonth (fromPosix (Time.millisToPosix 0))
> Jan : Month

-}
getMonth : DateTime -> Time.Month
getMonth =
    getDate >> Calendar.getMonth


{-| Extract the calendar day from a `DateTime`.

> getDay (fromPosix (Time.millisToPosix 0))
> Day 1 : Day

-}
getDay : DateTime -> Day
getDay =
    getDate >> Calendar.getDay


{-| Extract the weekday from a `DateTime`.

> getWeekday (fromPosix (Time.millisToPosix 0))
> Thu : Time.Weekday

-}
getWeekday : DateTime -> Time.Weekday
getWeekday (DateTime dateTime) =
    -- Time.toWeekday dateTime.zone dateTime.posix
    Calendar.weekdayFromDate dateTime.date


{-| Extract the clock time from a `DateTime`.

> getTime (fromPosix (Time.millisToPosix 0))
> { hour = Hour 0, millisecond = 0, minute = Minute 0, second = Second 0 } : Clock.Time

--- Think if you want to expose that ????????
--- I think not with a first thought.

-}
getTime : DateTime -> Clock.Time
getTime (DateTime { time }) =
    time


{-| Extract the clock hour from a `DateTime`.

> getHours (fromPosix (Time.millisToPosix 0))
> Hour 0 : Hour

-}
getHours : DateTime -> Clock.Hour
getHours =
    getTime >> Clock.getHours


{-| Extract the clock minute from a `DateTime`.

> getMinutes (fromPosix (Time.millisToPosix 0))
> Minute 0 : Minute

-}
getMinutes : DateTime -> Clock.Minute
getMinutes =
    getTime >> Clock.getMinutes


{-| Extract the clock second from a `DateTime`.

> getSeconds (fromPosix (Time.millisToPosix 0))
> Second 0 : Second

-}
getSeconds : DateTime -> Clock.Second
getSeconds =
    getTime >> Clock.getSeconds


{-| Extract the clock second from a `DateTime`.

> millisecond (fromPosix (Time.millisToPosix 0))
> 0 : Int

-}
getMilliseconds : DateTime -> Clock.Millisecond
getMilliseconds =
    getTime >> Clock.getMilliseconds



-- NEW STUFF


getYearInt : DateTime -> Int
getYearInt =
    Calendar.yearToInt << Calendar.getYear << getDate


getMonthInt : DateTime -> Int
getMonthInt =
    Calendar.monthToInt << Calendar.getMonth << getDate


getDayInt : DateTime -> Int
getDayInt =
    Calendar.dayToInt << Calendar.getDay << getDate


getHoursInt : DateTime -> Int
getHoursInt =
    Clock.hoursToInt << Clock.getHours << getTime


getMinutesInt : DateTime -> Int
getMinutesInt =
    Clock.minutesToInt << Clock.getMinutes << getTime


getSecondsInt : DateTime -> Int
getSecondsInt =
    Clock.secondsToInt << Clock.getSeconds << getTime


getMillisecondsInt : DateTime -> Int
getMillisecondsInt =
    Clock.millisecondsToInt << Clock.getMilliseconds << getTime
