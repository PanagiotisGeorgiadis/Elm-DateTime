module Clock.Internal exposing
    ( Time(..), RawTime
    , fromRawParts
    , toMillis
    , getHours, getMinutes, getSeconds, getMilliseconds
    , setHours, setMinutes, setSeconds, setMilliseconds
    , incrementHours, incrementMinutes, incrementSeconds, incrementMilliseconds
    , decrementHours, decrementMinutes, decrementSeconds, decrementMilliseconds
    , compare
    , sort
    , midnight
    , Hour(..), Minute(..), Second(..), Millisecond(..)
    , fromPosix
    , hoursFromInt, minutesFromInt, secondsFromInt, millisecondsFromInt
    , hoursToInt, minutesToInt, secondsToInt, millisecondsToInt
    , compareHours, compareMinutes, compareSeconds, compareMilliseconds
    , fromZonedPosix
    )

{-| The [Clock](Clock#) module was introduced in order to keep track of the `Time` concept.
It has no notion of a `Date` or any of its parts and it represents `Time` as a [24-hour clock](https://en.wikipedia.org/wiki/24-hour_clock)
which consists of `Hours`, `Minutes`, `Seconds` and `Milliseconds`. You can construct a `Time`
either by providing a [Posix](https://package.elm-lang.org/packages/elm/time/latest/Time#Posix) time
or by using its [Raw constituent parts](Clock#RawTime). You can use a `Time` and
the Clock's utilities as a standalone or you can combine a [Time](Clock#Time) and a [Date](Calendar#Date)
in order to get a [DateTime](DateTime#DateTime) which can then be converted into a [Posix](https://package.elm-lang.org/packages/elm/time/latest/Time#Posix).


# Type definition

@docs Time, RawTime


# Creating values

@docs fromRawParts


# Conversions

@docs toMillis


# Accessors

@docs getHours, getMinutes, getSeconds, getMilliseconds


# Setters

@docs setHours, setMinutes, setSeconds, setMilliseconds


# Incrementers

@docs incrementHours, incrementMinutes, incrementSeconds, incrementMilliseconds


# Decrementers

@docs decrementHours, decrementMinutes, decrementSeconds, decrementMilliseconds


# Comparers

@docs compare


# Utilities

@docs sort


# Constants

@docs midnight


# Exposed for Testing Purposes

@docs Hour, Minute, Second, Millisecond
@docs fromPosix
@docs hoursFromInt, minutesFromInt, secondsFromInt, millisecondsFromInt
@docs hoursToInt, minutesToInt, secondsToInt, millisecondsToInt
@docs compareHours, compareMinutes, compareSeconds, compareMilliseconds
@docs fromZonedPosix

-}

import Time as Time_


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


{-| A clock hour
-}
type Hour
    = Hour Int


{-| A clock minute
-}
type Minute
    = Minute Int


{-| A clock second
-}
type Second
    = Second Int


{-| A clock millisecond
-}
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



-- Creating a `Time`


{-| Construct a [Time](Clock#Time) from a [Posix](https://package.elm-lang.org/packages/elm/time/latest/Time#Posix) time.
You can construct a `Posix` time from milliseconds using the [millisToPosix](https://package.elm-lang.org/packages/elm/time/latest/Time#millisToPosix)
function located in the [elm/time](https://package.elm-lang.org/packages/elm/time/latest/) package.

    fromPosix (Time.millisToPosix 0)
    -- Time { hours = Hour 0, minutes = Minute 0, seconds = Second 0, milliseconds = Millisecond 0 } : Time

    fromPosix (Time.millisToPosix 1566795954000)
    -- Time { hours = Hour 5, minutes = Minute 5, seconds = Second 54, milliseconds = Millisecond 0 } : Time

    fromPosix (Time.millisToPosix 1566777600000)
    -- Time { hours = Hour 0, minutes = Minute 0, seconds = Second 0, milliseconds = Millisecond 0 } : Time

Notice that in the first and third examples the timestamps that are used are different but the result [Times](Clock#Time) are identical.
This is because the [Clock](Clock#) module only extracts the `Hours`, `Minutes`, `Seconds` and `Milliseconds` from the given
[Posix](https://package.elm-lang.org/packages/elm/time/latest/Time#Posix) time given. This means that if we attempt to convert both of these `Times`
back [toMillis](Clock#toMillis) they will result in the same milliseconds. It is recommended using the [fromPosix](DateTime#fromPosix)
function provided in the [DateTime](DateTime#) module if you need to preserve both `Date` and `Time`.

-}
fromPosix : Time_.Posix -> Time
fromPosix posix =
    Time
        { hours = Hour (Time_.toHour Time_.utc posix)
        , minutes = Minute (Time_.toMinute Time_.utc posix)
        , seconds = Second (Time_.toSecond Time_.utc posix)
        , milliseconds = Millisecond (Time_.toMillis Time_.utc posix)
        }


{-| Constructs a [Time](Clock#Time) from a [Posix](https://package.elm-lang.org/packages/elm/time/latest/Time#Posix) time and
a [timezone](https://package.elm-lang.org/packages/elm/time/latest/Time#Zone). This function shouldn't be exposed to the consumer because
of the reasons outlined on this [issue](https://github.com/PanagiotisGeorgiadis/Elm-DateTime/issues/2).
-}
fromZonedPosix : Time_.Zone -> Time_.Posix -> Time
fromZonedPosix zone posix =
    Time
        { hours = Hour (Time_.toHour zone posix)
        , minutes = Minute (Time_.toMinute zone posix)
        , seconds = Second (Time_.toSecond zone posix)
        , milliseconds = Millisecond (Time_.toMillis zone posix)
        }


{-| Construct a clock [Time](Clock#Time) from raw `Hour`, `Minute`, `Second`, `Millisecond` integers.

    fromRawParts { hours = 23, minutes = 15, seconds = 45, milliseconds = 999 }
    -- Just (Time { hours = Hour 23, minutes = Minute 15, seconds = Second 45, milliseconds = Millisecond 999 }) : Maybe Time

    fromRawParts { hours = 24, minutes = 15, seconds = 45, milliseconds = 999 }
    -- Nothing : Maybe Time

Notice that the second attempt to construct a time resulted in `Nothing`. This is because the upper limit for an `Hour` is 23.

The limits are as follows:

  - 0 &le; Hours &lt; 24
  - 0 &le; Minutes &lt; 60
  - 0 &le; Seconds &lt; 60
  - 0 &le; Milliseconds &lt; 1000

-}
fromRawParts : RawTime -> Maybe Time
fromRawParts { hours, minutes, seconds, milliseconds } =
    Maybe.map4
        (\h m s mm ->
            Time (InternalTime h m s mm)
        )
        (hoursFromInt hours)
        (minutesFromInt minutes)
        (secondsFromInt seconds)
        (millisecondsFromInt milliseconds)


{-| Attempt to construct a `Hour` from an `Int`.

    hoursFromInt 3 -- Just (Hour 3) : Maybe Hour

    hoursFromInt 45 -- Just (Hour 45) : Maybe Hour

    hoursFromInt 75 -- Nothing : Maybe Hour

-}
hoursFromInt : Int -> Maybe Hour
hoursFromInt hours =
    if hours >= 0 && hours < 24 then
        Just (Hour hours)

    else
        Nothing


{-| Attempt to construct a `Minute` from an `Int`.

    minutesFromInt 3 -- Just (Minute 3) : Maybe Minute

    minutesFromInt 45 -- Just (Minute 45) : Maybe Minute

    minutesFromInt 75 -- Nothing : Maybe Minute

-}
minutesFromInt : Int -> Maybe Minute
minutesFromInt minutes =
    if minutes >= 0 && minutes < 60 then
        Just (Minute minutes)

    else
        Nothing


{-| Attempt to construct a `Second` from an `Int`.

    secondsFromInt 3 -- Just (Second 3) : Maybe Second

    secondsFromInt 45 -- Just (Second 45) : Maybe Second

    secondsFromInt 75 -- Nothing : Maybe Second

-}
secondsFromInt : Int -> Maybe Second
secondsFromInt seconds =
    if seconds >= 0 && seconds < 60 then
        Just (Second seconds)

    else
        Nothing


{-| Attempt to construct a `Millisecond` from an `Int`.

    millisecondsFromInt 300 -- Just (Millisecond 300) : Maybe Millisecond

    millisecondsFromInt 450 -- Just (Millisecond 450) : Maybe Millisecond

    millisecondsFromInt 1500 -- Nothing : Maybe Millisecond

-}
millisecondsFromInt : Int -> Maybe Millisecond
millisecondsFromInt millis =
    if millis >= 0 && millis < 1000 then
        Just (Millisecond millis)

    else
        Nothing



-- Conversions


{-| Convert a [Time](Clock#Time) to milliseconds since midnight.

    time = fromRawParts { hours = 12, minutes = 30, seconds = 0, milliseconds = 0 }
    Maybe.map toMillis time -- Just 45000000 : Maybe Int

    want = 1566777600000 -- 26 Aug 2019 00:00:00.000
    got = toMillis (fromPosix (Time.millisToPosix want)) -- 0 : Int

    want == got -- False

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

    Maybe.map hoursToInt (hoursFromInt 12) -- Just 12 : Maybe Int

-}
hoursToInt : Hour -> Int
hoursToInt (Hour hours) =
    hours


{-| Convert a `Minute` to an `Int`.

    Maybe.map minutesToInt (minutesFromInt 30) -- Just 30 : Maybe Int

-}
minutesToInt : Minute -> Int
minutesToInt (Minute minutes) =
    minutes


{-| Convert a `Second` to an `Int`.

    Maybe.map secondsToInt (secondsFromInt 30) -- Just 30 : Maybe Int

-}
secondsToInt : Second -> Int
secondsToInt (Second seconds) =
    seconds


{-| Convert a `Millisecond` to an `Int`.

    Maybe.map millisecondsToInt (millisecondsFromInt 500) -- Just 500 : Maybe Int

-}
millisecondsToInt : Millisecond -> Int
millisecondsToInt (Millisecond milliseconds) =
    milliseconds



-- Accessors


{-| Extract the `Hours` part of a [Time](Clock#Time).

    -- time == 12:15:45.500
    getHours time -- Hour 12 : Hour

-}
getHours : Time -> Hour
getHours (Time { hours }) =
    hours


{-| Extract the `Minutes` part of a [Time](Clock#Time).

    -- time == 12:15:45.500
    getMinutes time -- Minute 15 : Minute

-}
getMinutes : Time -> Minute
getMinutes (Time { minutes }) =
    minutes


{-| Extract the `Seconds` part of a [Time](Clock#Time).

    -- time == 12:15:45.500
    getSeconds time -- Second 45 : Second

-}
getSeconds : Time -> Second
getSeconds (Time { seconds }) =
    seconds


{-| Extract the `Millisecond` part of a [Time](Clock#Time).

    -- time == 12:15:45.500
    getMilliseconds time -- Millisecond 500 : Millisecond

-}
getMilliseconds : Time -> Millisecond
getMilliseconds (Time { milliseconds }) =
    milliseconds



-- Setters


{-| Attempts to set the `Hour` on an existing time.

    -- time == 15:45:54.250
    setHours 23 time -- Just (23:45:54.250) : Maybe Time

    setHours 24 time -- Nothing : Maybe Time

-}
setHours : Int -> Time -> Maybe Time
setHours hours time =
    fromRawParts
        { hours = hours
        , minutes = minutesToInt (getMinutes time)
        , seconds = secondsToInt (getSeconds time)
        , milliseconds = millisecondsToInt (getMilliseconds time)
        }


{-| Attempts to set the `Minute` on an existing time.

    -- time == 15:45:54.250
    setMinutes 36 time -- Just (15:36:54.250) : Maybe Time

    setMinutes 60 time -- Nothing : Maybe Time

-}
setMinutes : Int -> Time -> Maybe Time
setMinutes minutes time =
    fromRawParts
        { hours = hoursToInt (getHours time)
        , minutes = minutes
        , seconds = secondsToInt (getSeconds time)
        , milliseconds = millisecondsToInt (getMilliseconds time)
        }


{-| Attempts to set the `Second` on an existing time.

    -- time == 15:45:54.250
    setSeconds 20 time -- Just (15:45:20.250) : Maybe Time

    setSeconds 60 time -- Nothing : Maybe Time

-}
setSeconds : Int -> Time -> Maybe Time
setSeconds seconds time =
    fromRawParts
        { hours = hoursToInt (getHours time)
        , minutes = minutesToInt (getMinutes time)
        , seconds = seconds
        , milliseconds = millisecondsToInt (getMilliseconds time)
        }


{-| Attempts to set the `Millisecond` on an existing time.

    -- time == 15:45:54.250
    setMilliseconds 589 time -- Just (15:45:54.589) : Maybe Time

    setMilliseconds 1000 time -- Nothing : Maybe Time

-}
setMilliseconds : Int -> Time -> Maybe Time
setMilliseconds milliseconds time =
    fromRawParts
        { hours = hoursToInt (getHours time)
        , minutes = minutesToInt (getMinutes time)
        , seconds = secondsToInt (getSeconds time)
        , milliseconds = milliseconds
        }



-- Increment values


{-| Increments an `Hour` inside a [Time](Clock#Time). The [Time](Clock#Time) will keep on cycling forward with a
maximum time of _23:59:59.999_. It also returns a `Bool` flag which indicates if the new `Time` has passed through the midnight hour ( 00:00:00.000 ).
This flag can be used in order to notify that a `Day` has passed but it is advised to use the [DateTime](DateTime#) module for these kind
of operations since it provides all the available helpers and takes care of any [Calendar](Calendar#) changes.

-- time == 12:15:45.750
incrementHours time -- (13:15:45.750, False) : (Time, Bool)

-- time2 == 23:00:00.000
incrementHours time2 -- (00:00:00.000, True) : (Time, Bool)

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


{-| Increments a `Minute` inside a [Time](Clock#Time). The [Time](Clock#Time) will keep on cycling around
as mentioned in the [incrementHours](Clock#incrementHours) description.

-- time == 12:59:45.750
incrementMinutes time -- (13:00:45.750, False) : (Time, Bool)

-- time2 == 23:59:45.750
incrementMinutes time2 -- (00:00:45.750, True) : (Time, Bool)

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


{-| Increments a `Second` inside a [Time](Clock#Time). The [Time](Clock#Time) will keep on cycling around
as mentioned in the [incrementHours](Clock#incrementHours) description.

-- time == 12:59:59.750
incrementSeconds time -- (13:00:00.750, False) : (Time, Bool)

-- time2 == 23:59:59.750
incrementSeconds time2 -- (00:00:00.750, True) : (Time, Bool)

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


{-| Increments a `Millisecond` inside a [Time](Clock#Time). The [Time](Clock#Time) will keep on cycling around
as mentioned in the [incrementHours](Clock#incrementHours) description.

-- time == 12:59:59.999
incrementMilliseconds time -- (13:00:00.000, False) : (Time, Bool)

-- time2 == 23:59:59.999
incrementMilliseconds time2 -- (00:00:00.000, True) : (Time, Bool)

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



-- Decrement values


{-| Decrements an `Hour` inside a [Time](Clock#Time). The [Time](Clock#Time) will keep on cycling backwards with a
minimum time of _00:00:00.000_. It also returns a `Bool` flag which indicates if the new `Time` has passed through the midnight hour ( 00:00:00.000 ).
This flag can be used in order to notify that a `Day` has passed but it is advised to use the [DateTime](DateTime#) module for these kind
of operations since it provides all the available helpers and takes care of any [Calendar](Calendar#) changes.

    -- time  == 13:15:45.750
    decrementHours time -- (12:15:45.750, False) : (Time, Bool)

    -- time2 == 00:59:59.999
    decrementHours time2 -- (23:59:59.999, True) : (Time, Bool)

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


{-| Decrements a `Minute` inside a [Time](Clock#Time). The [Time](Clock#Time) will keep on cycling backwards
as mentioned in the [decrementHours](Clock#decrementHours) description.

    -- time  == 12:15:00.000
    decrementMinutes time -- (12:14:00.000, False) : (Time, Bool)

    -- time2 == 00:00:00.000
    decrementMinutes time2 -- (23:59:00.000, True) : (Time, Bool)

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


{-| Decrements a `Second` inside a [Time](Clock#Time). The [Time](Clock#Time) will keep on cycling backwards
as mentioned in the [decrementHours](Clock#decrementHours) description.

    -- time  == 12:15:00.000
    decrementSeconds time -- (12:14:59.000, False) : (Time, Bool)

    -- time2 == 00:00:00.000
    decrementSeconds time2 -- (23:59:59.000, True) : (Time, Bool)

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


{-| Decrements a `Millisecond` inside a [Time](Clock#Time). The [Time](Clock#Time) will keep on cycling backwards
as mentioned in the [decrementHours](Clock#decrementHours) description.

    -- time  == 12:15:00.000
    decrementMilliseconds time -- (12:14:59.999, False) : (Time, Bool)

    -- time2 == 00:00:00.000
    decrementMilliseconds time2 -- (23:59:59.999, True) : (Time, Bool)

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



-- Compare values


{-| Compare two `Time` values.

    -- past   == 15:45:24.780
    -- future == 15:45:24.800
    compare past past -- EQ : Order

    compare past future -- LT : Order

    compare future past -- GT : Order

-}
compare : Time -> Time -> Order
compare lhs rhs =
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

    -- time  == 12:15:30.500
    -- time2 == 12:30:45.250
    -- time3 == 15:15:30.250
    compareHours (getHours time) (getHours time3) -- LT : Order

    compareHours (getHours time) (getHours time2) -- EQ : Order

    compareHours (getHours time3) (getHours time2) -- GT : Order

-}
compareHours : Hour -> Hour -> Order
compareHours (Hour lhs) (Hour rhs) =
    Basics.compare lhs rhs


{-| Compare two `Minute` values.

    -- time  == 12:15:30.500
    -- time2 == 12:30:45.250
    -- time3 == 15:15:30.250
    compareMinutes (getMinutes time) (getMinutes time2) -- LT : Order

    compareMinutes (getMinutes time) (getMinutes time3) -- EQ : Order

    compareMinutes (getMinutes time2) (getMinutes time3) -- GT : Order

-}
compareMinutes : Minute -> Minute -> Order
compareMinutes (Minute lhs) (Minute rhs) =
    Basics.compare lhs rhs


{-| Compare two `Second` values.

    -- time  == 12:15:30.500
    -- time2 == 12:30:45.250
    -- time3 == 15:15:30.250
    compareSeconds (getSeconds time) (getSeconds time2) -- LT : Order

    compareSeconds (getSeconds time) (getSeconds time3) -- EQ : Order

    compareSeconds (getSeconds time2) (getSeconds time3) -- GT : Order

-}
compareSeconds : Second -> Second -> Order
compareSeconds (Second lhs) (Second rhs) =
    Basics.compare lhs rhs


{-| Compare two `Millisecond` values.

    -- time  == 12:15:30.500
    -- time2 == 12:30:45.250
    -- time3 == 15:15:30.250
    compareMilliseconds (getMilliseconds time3) (getMilliseconds time) -- LT : Order

    compareMilliseconds (getMilliseconds time2) (getMilliseconds time3) -- EQ : Order

    compareMilliseconds (getMilliseconds time) (getMilliseconds time2) -- GT : Order

-}
compareMilliseconds : Millisecond -> Millisecond -> Order
compareMilliseconds (Millisecond lhs) (Millisecond rhs) =
    Basics.compare lhs rhs



-- Utilities


{-| Sorts a List of 'Time' based on their representation in milliseconds.

    -- dawn     == 06:00:00.000
    -- noon     == 12:00:00.000
    -- dusk     == 18:00:00.000
    -- midnight == 00:00:00.000

    sort [ noon, dawn, dusk, midnight ]
    -- [ 00:00:00.000, 06:00:00.000, 12:00:00.000, 18:00:00.000 ] : List Time

-}
sort : List Time -> List Time
sort =
    List.sortBy toMillis



-- Constants


{-| Returns midnight time.

    midnight == 00:00:00.000

-}
midnight : Time
midnight =
    Time { hours = Hour 0, minutes = Minute 0, seconds = Second 0, milliseconds = Millisecond 0 }
