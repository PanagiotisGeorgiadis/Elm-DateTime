module DateTime.DateTime.Internal exposing
    ( DateTime(..)
    , InternalDateTime
    , compareDates
    , compareTime
    , decrementDay
    , decrementHours
    , decrementMilliseconds
    , decrementMinutes
    , decrementMonth
    , decrementSeconds
    , decrementYear
    , fromDateAndTime
    , fromPosix
    , fromRawParts
    , getDate
    , getDateRange
    , getDatesInMonth
    , getDay
    , getHours
    , getMilliseconds
    , getMinutes
    , getMonth
    , getSeconds
    , getTime
    , getWeekday
    , getYear
    , incrementDay
    , incrementHours
    , incrementMilliseconds
    , incrementMinutes
    , incrementMonth
    , incrementSeconds
    , incrementYear
    , rollDayBackwards
    , rollDayForward
    , toMillis
    , toPosix
    )

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


{-| Create a `DateTime` from a 'Calendar.Date' and 'Clock.Time'.
-}
fromDateAndTime : Calendar.Date -> Clock.Time -> DateTime
fromDateAndTime date time =
    DateTime
        { date = date
        , time = time
        }


{-| Converts a 'DateTime' to a posix time.

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


{-| Extract the calendar date from a `DateTime`.

> getDate (fromPosix (Time.millisToPosix 0))
> Date { day = Day 1, month = Jan, year = Year 1970 } : Calendar.Date

-- Can be exposed.

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
    Calendar.getWeekday dateTime.date


{-| Extract the clock time from a `DateTime`.

> getTime (fromPosix (Time.millisToPosix 0))
> { hour = Hour 0, millisecond = 0, minute = Minute 0, second = Second 0 } : Clock.Time

-- Can be exposed.

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
            DateTime { date = date_, time = Clock.midnight }
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
                , time = Clock.midnight
                }
        )
        (Calendar.getDateRange start.date end.date)


{-| Returns a new 'DateTime' with an updated year value.
-}
incrementYear : DateTime -> DateTime
incrementYear (DateTime { date, time }) =
    DateTime
        { date = Calendar.incrementYear date
        , time = time
        }


{-| Returns a new 'DateTime' with an updated year value.
-}
decrementYear : DateTime -> DateTime
decrementYear (DateTime { date, time }) =
    DateTime
        { date = Calendar.decrementYear date
        , time = time
        }


{-| Returns a new 'DateTime' with an updated month value.
-}
decrementMonth : DateTime -> DateTime
decrementMonth (DateTime { date, time }) =
    DateTime
        { date = Calendar.decrementMonth date
        , time = time
        }


{-| Returns a new 'DateTime' with an updated month value.
-}
incrementMonth : DateTime -> DateTime
incrementMonth (DateTime { date, time }) =
    DateTime
        { date = Calendar.incrementMonth date
        , time = time
        }


{-| Returns the 'Order' of the 'Date' part of a DateTime.
-}
compareDates : DateTime -> DateTime -> Order
compareDates (DateTime lhs) (DateTime rhs) =
    Calendar.compareDates lhs.date rhs.date


{-| Returns the 'Order' of the 'Time' part of a DateTime.
-}
compareTime : DateTime -> DateTime -> Order
compareTime (DateTime lhs) (DateTime rhs) =
    Clock.compareTime lhs.time rhs.time



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
decrementDay (DateTime { date, time }) =
    DateTime
        { date = Calendar.decrementDay date
        , time = time
        }


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
incrementDay (DateTime { date, time }) =
    DateTime
        { date = Calendar.incrementDay date
        , time = time
        }


{-| Increments the 'Hours' in a given 'Date'. Will also increment 'Day', 'Month', 'Year' where applicable.
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


{-| Increments the 'Minutes' in a given 'Date'. Will also increment 'Hours', 'Day', 'Month', 'Year' where applicable.
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


{-| Increments the 'Seconds' in a given 'Date'. Will also increment 'Minutes', 'Hours', 'Day', 'Month', 'Year' where applicable.
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


{-| Increments the 'Milliseconds' in a given 'Date'. Will also increment 'Seconds', 'Minutes', 'Hours', 'Day', 'Month', 'Year' where applicable.
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


{-| Decides if we should 'roll' the Calendar.Date forward due to a Clock.Time change.
-}
rollDayForward : Bool -> Calendar.Date -> Calendar.Date
rollDayForward shouldRoll date =
    if shouldRoll then
        Calendar.incrementDay date

    else
        date


{-| Decrements the 'Hours' in a given 'Date'. Will also decrement 'Day', 'Month', 'Year' where applicable.
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


{-| Decrements the 'Minutes' in a given 'Date'. Will also decrement 'Hours', 'Day', 'Month', 'Year' where applicable.
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


{-| Decrements the 'Seconds' in a given 'Date'. Will also decrement 'Minutes', 'Hours', 'Day', 'Month', 'Year' where applicable.
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


{-| Decrements the 'Milliseconds' in a given 'Date'. Will also decrement 'Seconds', 'Minutes', 'Hours', 'Day', 'Month', 'Year' where applicable.
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


{-| Decides if we should 'roll' the Calendar.Date backwards due to a Clock.Time change.
-}
rollDayBackwards : Bool -> Calendar.Date -> Calendar.Date
rollDayBackwards shouldRoll date =
    if shouldRoll then
        Calendar.decrementDay date

    else
        date
