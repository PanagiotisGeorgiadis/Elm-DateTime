module DateTime.Clock exposing
    ( RawTime, Time, Hour, Minute, Second, Millisecond
    , fromRawParts, fromPosix
    , toMillis, hoursToInt, minutesToInt, secondsToInt, millisecondsToInt
    , getHours, getMinutes, getSeconds, getMilliseconds
    , incrementHours, incrementMinutes, incrementSeconds, incrementMilliseconds
    , decrementHours, decrementMinutes, decrementSeconds, decrementMilliseconds
    , compareTime, compareHours, compareMinutes, compareSeconds, compareMilliseconds
    , zero
    )

{-| A clock time.


# Type definition

@docs RawTime, Time, Hour, Minute, Second, Millisecond


# Creating values

@docs fromRawParts, fromPosix


# Conversions

@docs toMillis, hoursToInt, minutesToInt, secondsToInt, millisecondsToInt


# Getters

@docs getHours, getMinutes, getSeconds, getMilliseconds


# Incrementers

@docs incrementHours, incrementMinutes, incrementSeconds, incrementMilliseconds


# Decrementers

@docs decrementHours, decrementMinutes, decrementSeconds, decrementMilliseconds


# Comparers

@docs compareTime, compareHours, compareMinutes, compareSeconds, compareMilliseconds


# Constants

@docs zero

-}

import Time


{-| A clock time.
-}
type Time
    = Time InternalTime


{-| The internal representation of Time and its constituent parts.
-}
type alias InternalTime =
    { hours : Hour
    , minutes : Minute
    , seconds : Second
    , milliseconds : Millisecond
    }


type Hour
    = Hour Int


type Minute
    = Minute Int


type Second
    = Second Int


type Millisecond
    = Millisecond Int


{-| An 'abstract' representation of Time and its constituent parts based on Integers.
-}
type alias RawTime =
    { hours : Int
    , minutes : Int
    , seconds : Int
    , milliseconds : Int
    }


{-| Construct a clock `Time` from raw hour, minute, second, millisecond integers.

> fromRawParts { hours = 12, minutes = 30, seconds = 0, milliseconds = 0 }
> Just (Time { hours = Hours 12, minutes = Minutes 30, seconds = Second 0, milliseconds = Millisecond 0 }) : Maybe Time
>
> fromRawParts { hours = 12, minutes = 60, seconds = 0, milliseconds = 0 }
> Nothing : Maybe Time

-}
fromRawParts : RawTime -> Maybe Time
fromRawParts { hours, minutes, seconds, milliseconds } =
    hoursFromInt hours
        |> Maybe.andThen
            (\hours_ ->
                minutesFromInt minutes
                    |> Maybe.andThen
                        (\minutes_ ->
                            secondsFromInt seconds
                                |> Maybe.andThen
                                    (\seconds_ ->
                                        millisecondsFromInt milliseconds
                                            |> Maybe.andThen
                                                (\millis ->
                                                    Just
                                                        (Time
                                                            { hours = hours_
                                                            , minutes = minutes_
                                                            , seconds = seconds_
                                                            , milliseconds = millis
                                                            }
                                                        )
                                                )
                                    )
                        )
            )


{-| Attempt to construct a `Hour` from an `Int`.

> hoursFromInt 3
> Just (Hour 3) : Maybe Hour
> hoursFromInt 45
> Just (Hour 45) : Maybe Hour
> hoursFromInt 75
> Nothing : Maybe Hour

-- Internal use only

-}
hoursFromInt : Int -> Maybe Hour
hoursFromInt hours =
    if hours >= 0 && hours < 24 then
        Just (Hour hours)

    else
        Nothing


{-| Attempt to construct a `Minute` from an `Int`.

> minutesFromInt 3
> Just (Minute 3) : Maybe Minute
> minutesFromInt 45
> Just (Minute 45) : Maybe Minute
> minutesFromInt 75
> Nothing : Maybe Minute

-- Internal use only

-}
minutesFromInt : Int -> Maybe Minute
minutesFromInt minutes =
    if minutes >= 0 && minutes < 60 then
        Just (Minute minutes)

    else
        Nothing


{-| Attempt to construct a `Second` from an `Int`.

> secondsFromInt 3
> Just (Second 3) : Maybe Second
> secondsFromInt 45
> Just (Second 45) : Maybe Second
> secondsFromInt 75
> Nothing : Maybe Second

-- Internal use only

-}
secondsFromInt : Int -> Maybe Second
secondsFromInt seconds =
    if seconds >= 0 && seconds < 60 then
        Just (Second seconds)

    else
        Nothing


{-| Attempt to construct a `Millisecond` from an `Int`.

> millisecondsFromInt 300
> Just (Millisecond 300) : Maybe Millisecond
> millisecondsFromInt 450
> Just (Millisecond 450) : Maybe Millisecond
> millisecondsFromInt 1500
> Nothing : Maybe Millisecond

-- Internal use only

-}
millisecondsFromInt : Int -> Maybe Millisecond
millisecondsFromInt millis =
    if millis >= 0 && millis < 1000 then
        Just (Millisecond millis)

    else
        Nothing


{-| Get a clock `Time` from a time zone and posix time.

> fromPosix (Time.millisToPosix 0)
> { hour = Hour 0, minute = Minute 0, second = Second 0, millisecond = 0 } : Time
>
> fromPosix (Time.millisToPosix 1545328255284)
> { hour = Hour 17, minute = Minute 50, second = Second 55, millisecond = Millisecond 284 }

-}
fromPosix : Time.Posix -> Time
fromPosix posix =
    Time
        { hours = Hour (Time.toHour Time.utc posix)
        , minutes = Minute (Time.toMinute Time.utc posix)
        , seconds = Second (Time.toSecond Time.utc posix)
        , milliseconds = Millisecond (Time.toMillis Time.utc posix)
        }


{-| Convert a `Time` to milliseconds.

> Maybe.map toMillis (fromRawParts { hours = 12, minutes = 30, seconds = 0, milliseconds = 0 })
> Just 45000000 : Maybe Int

-}
toMillis : Time -> Int
toMillis (Time { hours, minutes, seconds, milliseconds }) =
    List.sum
        [ hoursToInt hours * 3600000
        , minutesToInt minutes * 60000
        , secondsToInt seconds * 1000
        , millisecondsToInt milliseconds
        ]


{-| Convert an `Hour` to an `Int`.

> Maybe.map hoursToInt (hoursFromInt 12)
> Just 12 : Maybe Int

-}
hoursToInt : Hour -> Int
hoursToInt (Hour hours) =
    hours


{-| Convert a `Minute` to an `Int`.

> Maybe.map minutesToInt (minutesFromInt 30)
> Just 30 : Maybe Int

-}
minutesToInt : Minute -> Int
minutesToInt (Minute minutes) =
    minutes


{-| Convert a `Second` to an `Int`.

> Maybe.map secondsToInt (secondsFromInt 30)
> Just 30 : Maybe Int

-}
secondsToInt : Second -> Int
secondsToInt (Second seconds) =
    seconds


{-| Convert a `Millisecond` to an `Int`.

> Maybe.map millisecondsToInt (millisecondsFromInt 500)
> Just 500 : Maybe Int

-}
millisecondsToInt : Millisecond -> Int
millisecondsToInt (Millisecond milliseconds) =
    milliseconds


{-| Returns the 'Hour' portion of a 'Time'
-}
getHours : Time -> Hour
getHours (Time { hours }) =
    hours


{-| Returns the 'Minute' portion of a 'Time'
-}
getMinutes : Time -> Minute
getMinutes (Time { minutes }) =
    minutes


{-| Returns the 'Second' portion of a 'Time'
-}
getSeconds : Time -> Second
getSeconds (Time { seconds }) =
    seconds


{-| Returns the 'Millisecond' portion of a 'Time'
-}
getMilliseconds : Time -> Millisecond
getMilliseconds (Time { milliseconds }) =
    milliseconds


{-| Increments an 'Hour' inside a 'Time'.

> time = fromRawParts { hours = 12, minutes = 15, seconds = 0, milliseconds = 0 }
> Maybe.map incrementHours time
> Just (Time { hours = Hour 13, minutes = Minute 15, seconds = Second 0, milliseconds = Millisecond 0 }, False) : Maybe (Time, Bool)

> time2 = fromRawParts { hours 23, minutes = 0, seconds = 0, milliseconds = 0 }
> Maybe.map incrementHours time2
> Just (Time { hours = Hour 0, minutes = Minute 0, seconds = Second 0, milliseconds = Millisecond 0}, True) : Maybe (Time, Bool)

--- The Time will keep on cycling around from 23:00 to 00:00 because it has
--- no knowledge of the 'Calendar' concept. It will also be returning a Bool
--- which is used in order to indicate if there has been a full cycle on the day.
--- The DateTime component will be accountable for changes in the calendar
--- when that is necessary.

-}
incrementHours : Time -> ( Time, Bool )
incrementHours (Time time) =
    let
        newHours =
            hoursToInt time.hours + 1
    in
    if newHours >= 24 then
        ( Time { time | hours = Hour 0 }
        , True
        )

    else
        ( Time { time | hours = Hour newHours }
        , False
        )


{-| Increments a 'Minute' inside a 'Time'.

> time = fromRawParts { hours = 12, minutes = 15, seconds = 0, milliseconds = 0 }
> Maybe.map incrementMinutes time
> Just (Time { hours = Hours 12, minutes = Minute 16, seconds = Second 0, milliseconds = Millisecond 0 }, False) : Maybe (Time, Bool)
>
> time2 = fromRawParts { hours = 23, minutes = 59, seconds = 0, milliseconds = 0 }
> Maybe.map incrementMinutes time2
> Just (Time { hours = Hours 0, minutes = Minute 0, seconds = Second 0, milliseconds = Millisecond 0 }, True) : Maybe (Time, Bool)

-}
incrementMinutes : Time -> ( Time, Bool )
incrementMinutes (Time time) =
    let
        newMinutes =
            minutesToInt time.minutes + 1
    in
    if newMinutes >= 60 then
        incrementHours (Time { time | minutes = Minute 0 })

    else
        ( Time { time | minutes = Minute newMinutes }
        , False
        )


{-| Increments a 'Second' inside a 'Time'.

> time = fromRawParts { hours = 12, minutes = 15, seconds = 0, milliseconds = 0 }
> Maybe.map incrementSeconds time
> Just (Time { hours = Hour 12, minutes = Minute 15, seconds = Second 1, milliseconds = Millisecond 0 }, False) : Maybe (Time, Bool)
>
> time2 = fromRawParts { hours = 23, minutes = 59, seconds = 59, milliseconds = 0 }
> Maybe.map incrementSeconds time2
> Just (Time { hours = Hours 0, minutes = Minute 0, seconds = Second 0, milliseconds = Millisecond 0 }, True) : Maybe (Time, Bool)

-}
incrementSeconds : Time -> ( Time, Bool )
incrementSeconds (Time time) =
    let
        newSeconds =
            secondsToInt time.seconds + 1
    in
    if newSeconds >= 60 then
        incrementMinutes (Time { time | seconds = Second 0 })

    else
        ( Time { time | seconds = Second newSeconds }
        , False
        )


{-| Increments a 'Millisecond' inside a 'Time'.

> time = fromRawParts { hours = 12, minutes = 15, seconds = 0, milliseconds = 0 }
> Maybe.map incrementMilliseconds time
> Just (Time { hours = Hour 12, minutes = Minute 15, seconds = Second 0, milliseconds = Millisecond 1 }, False) : Maybe (Time, Bool)
>
> time2 = fromRawParts { hours = 23, minutes = 59, seconds = 59, milliseconds = 999 }
> Maybe.map incrementMilliseconds time
> Just (Time { hours = Hours 0, minutes = Minute 0, seconds = Second 0, milliseconds = Millisecond 0 }, True) : Maybe (Time, Bool)

-}
incrementMilliseconds : Time -> ( Time, Bool )
incrementMilliseconds (Time time) =
    let
        newMillis =
            millisecondsToInt time.milliseconds + 1
    in
    if newMillis >= 1000 then
        incrementSeconds (Time { time | milliseconds = Millisecond 0 })

    else
        ( Time { time | milliseconds = Millisecond newMillis }
        , False
        )


{-| Decrements an 'Hour' inside a 'Time'.

> time = fromRawParts { hours = 12, minutes = 15, seconds = 0, milliseconds = 0 }
> Maybe.map decrementHours time
> Just (Time { hours = Hour 11, minutes = Minute 15, seconds = Second 0, milliseconds = Millisecond 0 }, False) : Maybe (Time, Bool)

> time2 = fromRawParts { hours 0, minutes = 0, seconds = 0, milliseconds = 0 }
> Maybe.map decrementHours time2
> Just (Time { hours = Hour 23, minutes = Minute 0, seconds = Second 0, milliseconds = Millisecond 0}, True) : Maybe (Time, Bool)

--- The Time will keep on cycling around from 00:00 to 23:00 because it has
--- no knowledge of the 'Calendar' concept. It will also be returning a Bool
--- which is used in order to indicate if there has been a full cycle on the day.
--- The DateTime component will be accountable for changes in the calendar
--- when that is necessary.

-}
decrementHours : Time -> ( Time, Bool )
decrementHours (Time time) =
    let
        newHours =
            hoursToInt time.hours - 1
    in
    if newHours < 0 then
        ( Time { time | hours = Hour 23 }
        , True
        )

    else
        ( Time { time | hours = Hour newHours }
        , False
        )


{-| Decrements a 'Minute' inside a 'Time'.

> time = fromRawParts { hours = 12, minutes = 15, seconds = 0, milliseconds = 0 }
> Maybe.map decrementMinutes time
> Just (Time { hours = Hours 12, minutes = Minute 14, seconds = Second 0, milliseconds = Millisecond 0 }, False) : Maybe (Time, Bool)
>
> time2 = fromRawParts { hours = 0, minutes = 0, seconds = 0, milliseconds = 0 }
> Maybe.map decrementMinutes time2
> Just (Time { hours = Hours 23, minutes = Minute 59, seconds = Second 0, milliseconds = Millisecond 0 }, True) : Maybe (Time, Bool)

-}
decrementMinutes : Time -> ( Time, Bool )
decrementMinutes (Time time) =
    let
        newMinutes =
            minutesToInt time.minutes - 1
    in
    if newMinutes < 0 then
        decrementHours (Time { time | minutes = Minute 59 })

    else
        ( Time { time | minutes = Minute newMinutes }
        , False
        )


{-| Decrements a 'Second' inside a 'Time'.

> time = fromRawParts { hours = 12, minutes = 15, seconds = 30, milliseconds = 0 }
> Maybe.map decrementSeconds time
> Just (Time { hours = Hour 12, minutes = Minute 15, seconds = Second 29, milliseconds = Millisecond 0 }, False) : Maybe (Time, Bool)
>
> time2 = fromRawParts { hours = 0, minutes = 0, seconds = 0, milliseconds = 0 }
> Maybe.map decrementSeconds time2
> Just (Time { hours = Hours 23, minutes = Minute 59, seconds = Second 59, milliseconds = Millisecond 0 }, True) : Maybe (Time, Bool)

-}
decrementSeconds : Time -> ( Time, Bool )
decrementSeconds (Time time) =
    let
        newSeconds =
            secondsToInt time.seconds - 1
    in
    if newSeconds < 0 then
        decrementMinutes (Time { time | seconds = Second 59 })

    else
        ( Time { time | seconds = Second newSeconds }
        , False
        )


{-| Decrements a 'Millisecond' inside a 'Time'.

> time = fromRawParts { hours = 12, minutes = 15, seconds = 0, milliseconds = 500 }
> Maybe.map decrementMilliseconds time
> Just (Time { hours = Hour 12, minutes = Minute 15, seconds = Second 0, milliseconds = Millisecond 499 }, False) : Maybe (Time, Bool)
>
> time2 = fromRawParts { hours = 0, minutes = 0, seconds = 0, milliseconds = 0 }
> Maybe.map decrementMilliseconds time
> Just (Time { hours = Hours 23, minutes = Minute 59, seconds = Second 59, milliseconds = Millisecond 999 }, True) : Maybe (Time, Bool)

-}
decrementMilliseconds : Time -> ( Time, Bool )
decrementMilliseconds (Time time) =
    let
        newMillis =
            millisecondsToInt time.milliseconds - 1
    in
    if newMillis < 0 then
        decrementSeconds (Time { time | milliseconds = Millisecond 999 })

    else
        ( Time { time | milliseconds = Millisecond newMillis }
        , False
        )


{-| Compare two `Time` values.

> time = fromRawParts { hours = 12, minutes = 15, seconds = 0, milliseconds = 0 }
> time2 = fromRawParts { hours = 12, minutes = 20, seconds = 0, milliseconds = 0 }
> Maybe.map2 compareHours time time2
> LT : Order

-}
compareTime : Time -> Time -> Order
compareTime lhs rhs =
    let
        ( hoursComparison, minutesComparison, secondsComparison ) =
            ( compareHours (getHours lhs) (getHours rhs)
            , compareMinutes (getMinutes lhs) (getMinutes rhs)
            , compareSeconds (getSeconds lhs) (getSeconds rhs)
            )
    in
    case hoursComparison of
        EQ ->
            case minutesComparison of
                EQ ->
                    case secondsComparison of
                        EQ ->
                            compareMilliseconds (getMilliseconds lhs) (getMilliseconds rhs)

                        _ ->
                            secondsComparison

                _ ->
                    minutesComparison

        _ ->
            hoursComparison


{-| Compare two `Hour` values.

> Maybe.map2 compareHours (hoursFromInt 10) (hoursFromInt 6)
> LT : Order

-- I think it could be internal use only because we don't want the consumer to
-- have any notion of 'Hour'.

-- Internal use only

-}
compareHours : Hour -> Hour -> Order
compareHours (Hour lhs) (Hour rhs) =
    compare lhs rhs


{-| Compare two `Minute` values.

> Maybe.map2 compareMilliseconds (minutesFromInt 15) (minutesFromInt 15)
> EQ : Order

-- I think it could be internal use only because we don't want the consumer to
-- have any notion of 'Hour'.

-- Internal use only

-}
compareMinutes : Minute -> Minute -> Order
compareMinutes (Minute lhs) (Minute rhs) =
    compare lhs rhs


{-| Compare two `Second` values.

> Maybe.map2 compareSeconds (secondsFromInt 30) (secondsFromInt 45)
> LT : Order

-- I think it could be internal use only because we don't want the consumer to
-- have any notion of 'Hour'.

-- Internal use only

-}
compareSeconds : Second -> Second -> Order
compareSeconds (Second lhs) (Second rhs) =
    compare lhs rhs


{-| Compare two `Millisecond` values.

> Maybe.map2 compareMilliseconds (millisecondsFromInt 200) (millisecondsFromInt 200)
> EQ : Order

-- I think it could be internal use only because we don't want the consumer to
-- have any notion of 'Hour'.

-- Internal use only

-}
compareMilliseconds : Millisecond -> Millisecond -> Order
compareMilliseconds (Millisecond lhs) (Millisecond rhs) =
    compare lhs rhs


{-| Returns a zero time. To be used with caution.
-}
zero : Time
zero =
    Time { hours = Hour 0, minutes = Minute 0, seconds = Second 0, milliseconds = Millisecond 0 }
