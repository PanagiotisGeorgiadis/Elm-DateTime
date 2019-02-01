module DateTime.DateTime.Internal exposing
    ( DateTime(..)
    , fromPosix, fromRawParts
    , toPosix
    , getYear, getMonth, getMonthInt, getDay, getWeekday, getHours, getMinutes, getSeconds, getMilliseconds
    , getNextMonth, getPreviousMonth, getDateRange, getDatesInMonth, getPreviousDay, getNextDay
    , compareDates, compareTime
    , InternalDateTime, daysSinceEpoch, fromUtcDateAndTime, getDate, getTime, toMillis, yearsSinceEpoch
    )

{-| A complete datetime type.

@docs DateTime


# Creating a `DateTime`

@docs fromPosix, fromRawParts


# Conversions

@docs toPosix


# Accessors

@docs getYear, getMonth, getMonthInt, getDay, getWeekday, getHours, getMinutes, getSeconds, getMilliseconds


# Calendar Accessors

@docs getNextMonth, getPreviousMonth, getDateRange, getDatesInMonth, getPreviousDay, getNextDay


# Utilities

@docs getDayDiff


# Comparers

@docs compareDates, compareTime

-}

import Array
import DateTime.Calendar as Calendar
import DateTime.Calendar.Internal as Calendar_
import DateTime.Clock as Clock
import DateTime.Clock.Internal as Clock_
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
        { date = Calendar_.fromPosix timePosix
        , time = Clock_.fromPosix timePosix
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

-- Internal use only

-}
getDate : DateTime -> Calendar.Date
getDate (DateTime { date }) =
    date


{-| Returns the 'Year' from a 'DateTime' as an Int.

> getYear (fromPosix (Time.millisToPosix 0))
> 1970 : Int

-}
getYear : DateTime -> Int
getYear =
    Calendar.getYear << getDate


{-| Returns the 'Month' from a 'DateTime' as a [Month](https://package.elm-lang.org/packages/elm/time/latest/Time#Month).

> getMonth (fromPosix (Time.millisToPosix 0))
> Jan : Int

-}
getMonth : DateTime -> Time.Month
getMonth =
    Calendar.getMonth << getDate


{-| Returns the 'Month' from a 'DateTime' as an Int starting from 1.

> getMonth (fromPosix (Time.millisToPosix 0))
> Jan : Int

-}
getMonthInt : DateTime -> Int
getMonthInt =
    Calendar.monthToInt << Calendar.getMonth << getDate


{-| Returns the 'Day' from a 'DateTime' as an Int.

> getDay (fromPosix (Time.millisToPosix 0))
> 1 : Int

-}
getDay : DateTime -> Int
getDay =
    Calendar.getDay << getDate


{-| Extract the weekday from a `DateTime`.

> getWeekday (fromPosix (Time.millisToPosix 0))
> Thu : Time.Weekday

-}
getWeekday : DateTime -> Time.Weekday
getWeekday (DateTime dateTime) =
    Calendar.weekdayFromDate dateTime.date


{-| Extract the clock time from a `DateTime`.

> getTime (fromPosix (Time.millisToPosix 0))
> { hour = Hour 0, millisecond = 0, minute = Minute 0, second = Second 0 } : Clock.Time

-- Internal use only

-}
getTime : DateTime -> Clock.Time
getTime (DateTime { time }) =
    time


{-| Returns the 'Hour' from a 'DateTime' as an Int.

> getHours (fromPosix (Time.millisToPosix 0))
> 0 : Int

-}
getHours : DateTime -> Int
getHours =
    Clock.getHours << getTime


{-| Returns the 'Minute' from a 'DateTime' as an Int.

> getMinutes (fromPosix (Time.millisToPosix 0))
> 0 : Int

-}
getMinutes : DateTime -> Int
getMinutes =
    Clock.getMinutes << getTime


{-| Returns the 'Second' from a 'DateTime' as an Int.

> getSeconds (fromPosix (Time.millisToPosix 0))
> 0 : Int

-}
getSeconds : DateTime -> Int
getSeconds =
    Clock.getSeconds << getTime


{-| Returns the 'Millisecond' from a 'DateTime' as an Int.

> getMilliseconds (fromPosix (Time.millisToPosix 0))
> 0 : Int

-}
getMilliseconds : DateTime -> Int
getMilliseconds =
    Clock.getMilliseconds << getTime



-- NEW STUFF


{-| Returns a list of Dates that belong in the current month of the 'DateTime'.
-}
getDatesInMonth : DateTime -> List DateTime
getDatesInMonth (DateTime { date }) =
    List.map
        (\date_ ->
            DateTime { date = date_, time = Clock.zero }
        )
        (Calendar.getDatesInMonth date)


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
getDateRange (DateTime start) (DateTime end) =
    List.map
        (\date ->
            DateTime
                { date = date
                , time = Clock.zero
                }
        )
        (Calendar.getDateRange start.date end.date)


{-| Attempts to construct a new DateTime object from its raw constituent parts.
-}
fromRawParts : Calendar.RawDate -> Clock.RawTime -> Maybe DateTime
fromRawParts rawDate rawTime =
    Maybe.andThen
        (\date ->
            Maybe.andThen
                (\t ->
                    Just (DateTime { date = date, time = t })
                )
                (Clock.fromRawParts rawTime)
        )
        (Calendar.fromRawYearMonthDay rawDate)


{-| Returns a new 'DateTime' with an updated month value.
-}
getPreviousMonth : DateTime -> DateTime
getPreviousMonth (DateTime { date, time }) =
    DateTime
        { date = Calendar.getPreviousMonth date
        , time = time
        }


{-| Returns a new 'DateTime' with an updated month value.
-}
getNextMonth : DateTime -> DateTime
getNextMonth (DateTime { date, time }) =
    DateTime
        { date = Calendar.getNextMonth date
        , time = time
        }


compareDates : DateTime -> DateTime -> Order
compareDates (DateTime lhs) (DateTime rhs) =
    Calendar.compareDates lhs.date rhs.date


compareTime : DateTime -> DateTime -> Order
compareTime (DateTime lhs) (DateTime rhs) =
    Clock.compareTime lhs.time rhs.time



-- getDayDiff : DateTime -> DateTime -> Int
-- getDayDiff (DateTime startDate) (DateTime endDate) =
--     Calendar.getDayDiff startDate.date endDate.date


{-| Decrements the 'Day' in a given 'Date'. Will also decrement 'Month' && 'Year'
--- if applicable.

> date = fromRawParts { rawDay = 1, rawMonth = 1, rawYear = 2019 } { hours = 0, minutes = 0, seconds = 0, milliseconds = 0 }
> getPreviousDay date
> DateTime { date = { day = Day 31, month = Dec, year = Year 2018 }, time = { hours = 0, minutes = 0, seconds = 0, milliseconds = 0 } }
>
> date2 = fromRawParts { rawDay = 1, rawMonth = 3, rawYear 2020 } { hours = 0, minutes = 0, seconds = 0, milliseconds = 0 }
> getPreviousDay date2
> DateTime { date = { day = Day 29, month = Feb, year = Year 2020 }, time = { hours = 0, minutes = 0, seconds = 0, milliseconds = 0 } }
>
> date3 = fromRawParts { rawDay = 26, rawMonth = 12, rawYear 2018 } { hours = 0, minutes = 0, seconds = 0, milliseconds = 0 }
> getPreviousDay date3
> DateTime { date = { day = Day 25, month = Dec, year = Year 2018 }, time = { hours = 0, minutes = 0, seconds = 0, milliseconds = 0 } }

-}
getPreviousDay : DateTime -> DateTime
getPreviousDay (DateTime { date, time }) =
    DateTime
        { date = Calendar.getPreviousDay date
        , time = time
        }


{-| Increments the 'Day' in a given 'Date'. Will also increment 'Month' && 'Year'
--- if applicable.

> date = fromRawParts { rawDay = 31, rawMonth = 12, rawYear = 2018 } { hours = 0, minutes = 0, seconds = 0, milliseconds = 0 }
> getNextDay date
> DateTime { date = { day = Day 1, month = Jan, year = Year 2019 }, time = { hours = 0, minutes = 0, seconds = 0, milliseconds = 0 } }
>
> date2 = fromRawParts { rawDay = 29, rawMonth = 2, rawYear 2020 } { hours = 0, minutes = 0, seconds = 0, milliseconds = 0 }
> getNextDay date2
> DateTime { date = { day = Day 1, month = Mar, year = Year 2020 }, time = { hours = 0, minutes = 0, seconds = 0, milliseconds = 0 } }
>
> date3 = fromRawParts { rawDay = 24, rawMonth = 12, rawYear 2018 } { hours = 0, minutes = 0, seconds = 0, milliseconds = 0 }
> getNextDay date3
> DateTime { date = { day = Day 25, month = Dec, year = Year 2018 }, time = { hours = 0, minutes = 0, seconds = 0, milliseconds = 0 } }

-}
getNextDay : DateTime -> DateTime
getNextDay (DateTime { date, time }) =
    DateTime
        { date = Calendar.getNextDay date
        , time = time
        }
