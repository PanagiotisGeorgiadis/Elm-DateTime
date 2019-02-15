module DateTime.Clock exposing
    ( Time, RawTime
    , fromPosix, fromRawParts
    , toMillis
    , getHours, getMinutes, getSeconds, getMilliseconds
    , setHours, setMinutes, setSeconds, setMilliseconds
    , incrementHours, incrementMinutes, incrementSeconds, incrementMilliseconds
    , decrementHours, decrementMinutes, decrementSeconds, decrementMilliseconds
    , compare
    , sort
    , midnight
    )

{-| The `Clock` module was introduced in order to keep track of the `Time` concept.
It has no notion of a `Date` or any of its parts and it represents `Time` as a [24-hour clock](https://en.wikipedia.org/wiki/24-hour_clock)
which consists of `Hours`, `Minutes`, `Seconds` and `Milliseconds`. You can construct a `Time`
either by providing a [Posix](https://package.elm-lang.org/packages/elm/time/latest/Time#Posix) time
or by using its [Raw constituent parts](DateTime-Clock#RawTime). You can use a `Time` and
the Clock's utilities as a standalone or you can combine a [Time](DateTime-Clock#Time) and a [Date](DateTime-Calendar#Date)
in order to get a [DateTime](DateTime-DateTime#DateTime) which can then be converted into a [Posix](https://package.elm-lang.org/packages/elm/time/latest/Time#Posix).


# Type definition

@docs Time, RawTime


# Creating a `Time`

@docs fromPosix, fromRawParts


# Conversions

@docs toMillis


# Accessors

@docs getHours, getMinutes, getSeconds, getMilliseconds


# Setters

@docs setHours, setMinutes, setSeconds, setMilliseconds


# Increment values

@docs incrementHours, incrementMinutes, incrementSeconds, incrementMilliseconds


# Decrement values

@docs decrementHours, decrementMinutes, decrementSeconds, decrementMilliseconds


# Compare values

@docs compare


# Utilities

@docs sort


# Constants

@docs midnight

-}

import DateTime.Clock.Internal as Internal exposing (Hour, Millisecond, Minute, Second)
import Time as Time_


{-| A clock time.
-}
type alias Time =
    Internal.Time


{-| An 'abstract' representation of Time and its constituent parts based on Integers.
-}
type alias RawTime =
    { hours : Int
    , minutes : Int
    , seconds : Int
    , milliseconds : Int
    }



-- Creating a `Time`


{-| Construct a [Time](DateTime-Clock#Time) from a [Posix](https://package.elm-lang.org/packages/elm/time/latest/Time#Posix) time.
You can construct a `Posix` time from milliseconds using the [millisToPosix](https://package.elm-lang.org/packages/elm/time/latest/Time#millisToPosix)
function located in the [elm/time](https://package.elm-lang.org/packages/elm/time/latest/) package.

    fromPosix (Time.millisToPosix 0)
    -- Time { hours = Hour 0, minutes = Minute 0, seconds = Second 0, milliseconds = Millisecond 0 } : Time

    fromPosix (Time.millisToPosix 1566795954000)
    -- Time { hours = Hour 5, minutes = Minute 5, seconds = Second 54, milliseconds = Millisecond 0 } : Time

    fromPosix (Time.millisToPosix 1566777600000)
    -- Time { hours = Hour 0, minutes = Minute 0, seconds = Second 0, milliseconds = Millisecond 0 } : Time

Notice that in the first and third examples the timestamps that are used are different but the result [Times](DateTime-Clock#Time) are identical.
This is because the [Clock](DateTime-Clock) module only extracts the `Hours`, `Minutes`, `Seconds` and `Milliseconds` from the given
[Posix](https://package.elm-lang.org/packages/elm/time/latest/Time#Posix) time given. This means that if we attempt to convert both of these `Times`
back [toMillis](DateTime-Clock#toMillis) they will result in the same milliseconds. It is recommended using the [fromPosix](DateTime-DateTime#fromPosix)
function provided in the [DateTime](DateTime-DateTime) module if you need to preserve both `Date` and `Time`.

-}
fromPosix : Time_.Posix -> Time
fromPosix =
    Internal.fromPosix


{-| Construct a clock [Time](DateTime-Clock#Time) from raw `Hour`, `Minute`, `Second`, `Millisecond` integers.

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
fromRawParts =
    Internal.fromRawParts



-- Conversions


{-| Convert a [Time](DateTime-Clock#Time) to milliseconds since midnight.

    time = fromRawParts { hours = 12, minutes = 30, seconds = 0, milliseconds = 0 }
    Maybe.map toMillis time -- Just 45000000 : Maybe Int

    want = 1566777600000 -- 26 Aug 2019 00:00:00.000
    got = toMillis (fromPosix (Time.millisToPosix want)) -- 0 : Int

    want == got -- False

-}
toMillis : Time -> Int
toMillis =
    Internal.toMillis



-- Accessors


{-| Extract the `Hours` part of a [Time](DateTime-Clock#Time).

    -- time == 12:15:45.500
    getHours time -- 12 : Int

-}
getHours : Time -> Int
getHours =
    Internal.hoursToInt << Internal.getHours


{-| Extract the `Minutes` part of a [Time](DateTime-Clock#Time).

    -- time == 12:15:45.500
    getMinutes time -- 15 : Int

-}
getMinutes : Time -> Int
getMinutes =
    Internal.minutesToInt << Internal.getMinutes


{-| Extract the `Seconds` part of a [Time](DateTime-Clock#Time).

    -- time == 12:15:45.500
    getSeconds time -- 45 : Int

-}
getSeconds : Time -> Int
getSeconds =
    Internal.secondsToInt << Internal.getSeconds


{-| Extract the `Millisecond` part of a [Time](DateTime-Clock#Time).

    -- time == 12:15:45.500
    getMilliseconds time -- 500 : Int

-}
getMilliseconds : Time -> Int
getMilliseconds =
    Internal.millisecondsToInt << Internal.getMilliseconds



-- Setters


{-| Attempts to set the `Hour` on an existing time.

    -- time == 15:45:54.250
    setHours 23 time -- Just (23:45:54.250) : Maybe Time

    setHours 24 time -- Nothing : Maybe Time

-}
setHours : Int -> Time -> Maybe Time
setHours =
    Internal.setHours


{-| Attempts to set the `Minute` on an existing time.

    -- time == 15:45:54.250
    setMinutes 36 time -- Just (15:36:54.250) : Maybe Time

    setMinutes 60 time -- Nothing : Maybe Time

-}
setMinutes : Int -> Time -> Maybe Time
setMinutes =
    Internal.setMinutes


{-| Attempts to set the `Second` on an existing time.

    -- time == 15:45:54.250
    setSeconds 20 time -- Just (15:45:20.250) : Maybe Time

    setSeconds 60 time -- Nothing : Maybe Time

-}
setSeconds : Int -> Time -> Maybe Time
setSeconds =
    Internal.setSeconds


{-| Attempts to set the `Millisecond` on an existing time.

    -- time == 15:45:54.250
    setMilliseconds 589 time -- Just (15:45:54.589) : Maybe Time

    setMilliseconds 1000 time -- Nothing : Maybe Time

-}
setMilliseconds : Int -> Time -> Maybe Time
setMilliseconds =
    Internal.setMilliseconds



-- Increment values


{-| Increments an `Hour` inside a [Time](DateTime-Clock#Time). The [Time](DateTime-Clock#Time) will keep on cycling forward with a
maximum time of _23:59:59.999_. It also returns a `Bool` flag which indicates if the new `Time` has passed through the midnight hour ( 00:00:00.000 ).
This flag can be used in order to notify that a `Day` has passed but it is advised to use the [DateTime](DateTime-DateTime) module for these kind
of operations since it provides all the available helpers and takes care of any [Calendar](DateTime-Calendar) changes.

    -- time == 12:15:45.750
    incrementHours time -- (13:15:45.750, False) : (Time, Bool)

    -- time2 == 23:00:00.000
    incrementHours time2 -- (00:00:00.000, True) : (Time, Bool)

-}
incrementHours : Time -> ( Time, Bool )
incrementHours =
    Internal.incrementHours


{-| Increments a `Minute` inside a [Time](DateTime-Clock#Time). The [Time](DateTime-Clock#Time) will keep on cycling around
as mentioned in the [incrementHours](DateTime-Clock#incrementHours) description.

    -- time  == 12:59:45.750
    incrementMinutes time -- (13:00:45.750, False) : (Time, Bool)

    -- time2 == 23:59:45.750
    incrementMinutes time2 -- (00:00:45.750, True) : (Time, Bool)

-}
incrementMinutes : Time -> ( Time, Bool )
incrementMinutes =
    Internal.incrementMinutes


{-| Increments a `Second` inside a [Time](DateTime-Clock#Time). The [Time](DateTime-Clock#Time) will keep on cycling around
as mentioned in the [incrementHours](DateTime-Clock#incrementHours) description.

    -- time  == 12:59:59.750
    incrementSeconds time -- (13:00:00.750, False) : (Time, Bool)

    -- time2 == 23:59:59.750
    incrementSeconds time2 -- (00:00:00.750, True) : (Time, Bool)

-}
incrementSeconds : Time -> ( Time, Bool )
incrementSeconds =
    Internal.incrementSeconds


{-| Increments a `Millisecond` inside a [Time](DateTime-Clock#Time). The [Time](DateTime-Clock#Time) will keep on cycling around
as mentioned in the [incrementHours](DateTime-Clock#incrementHours) description.

    -- time  == 12:59:59.999
    incrementMilliseconds time -- (13:00:00.000, False) : (Time, Bool)

    -- time2 == 23:59:59.999
    incrementMilliseconds time2 -- (00:00:00.000, True) : (Time, Bool)

-}
incrementMilliseconds : Time -> ( Time, Bool )
incrementMilliseconds =
    Internal.incrementMilliseconds



-- Decrement values


{-| Decrements an `Hour` inside a [Time](DateTime-Clock#Time). The [Time](DateTime-Clock#Time) will keep on cycling backwards with a
minimum time of _00:00:00.000_. It also returns a `Bool` flag which indicates if the new `Time` has passed through the midnight hour ( 00:00:00.000 ).
This flag can be used in order to notify that a `Day` has passed but it is advised to use the [DateTime](DateTime-DateTime) module for these kind
of operations since it provides all the available helpers and takes care of any [Calendar](DateTime-Calendar) changes.

    -- time  == 13:15:45.750
    decrementHours time -- (12:15:45.750, False) : (Time, Bool)

    -- time2 == 00:59:59.999
    decrementHours time2 -- (23:59:59.999, True) : (Time, Bool)

-}
decrementHours : Time -> ( Time, Bool )
decrementHours =
    Internal.decrementHours


{-| Decrements a `Minute` inside a [Time](DateTime-Clock#Time). The [Time](DateTime-Clock#Time) will keep on cycling backwards
as mentioned in the [decrementHours](DateTime-Clock#decrementHours) description.

    -- time  == 12:15:00.000
    decrementMinutes time -- (12:14:00.000, False) : (Time, Bool)

    -- time2 == 00:00:00.000
    decrementMinutes time2 -- (23:59:00.000, True) : (Time, Bool)

-}
decrementMinutes : Time -> ( Time, Bool )
decrementMinutes =
    Internal.decrementMinutes


{-| Decrements a `Second` inside a [Time](DateTime-Clock#Time). The [Time](DateTime-Clock#Time) will keep on cycling backwards
as mentioned in the [decrementHours](DateTime-Clock#decrementHours) description.

    -- time  == 12:15:00.000
    decrementSeconds time -- (12:14:59.000, False) : (Time, Bool)

    -- time2 == 00:00:00.000
    decrementSeconds time2 -- (23:59:59.000, True) : (Time, Bool)

-}
decrementSeconds : Time -> ( Time, Bool )
decrementSeconds =
    Internal.decrementSeconds


{-| Decrements a `Millisecond` inside a [Time](DateTime-Clock#Time). The [Time](DateTime-Clock#Time) will keep on cycling backwards
as mentioned in the [decrementHours](DateTime-Clock#decrementHours) description.

    -- time  == 12:15:00.000
    decrementMilliseconds time -- (12:14:59.999, False) : (Time, Bool)

    -- time2 == 00:00:00.000
    decrementMilliseconds time2 -- (23:59:59.999, True) : (Time, Bool)

-}
decrementMilliseconds : Time -> ( Time, Bool )
decrementMilliseconds =
    Internal.decrementMilliseconds



-- Compare values


{-| Compare two `Time` values.

    -- past   == 15:45:24.780
    -- future == 15:45:24.800
    compare past past -- EQ : Order

    compare past future -- LT : Order

    compare future past -- GT : Order

-}
compare : Time -> Time -> Order
compare =
    Internal.compare



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
    Internal.sort



-- Constants


{-| Returns midnight time.

    midnight == 00:00:00.000

-}
midnight : Time
midnight =
    Internal.midnight
