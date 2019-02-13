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

{-| A [24-hour clock time](https://en.wikipedia.org/wiki/24-hour_clock).


# Type definition

@docs Time, RawTime


# Creating values

@docs fromPosix, fromRawParts


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



-- Constructors


{-| Construct a [Time](DateTime-Clock#Time) from a [Posix](https://package.elm-lang.org/packages/elm/time/latest/Time#Posix) time.
You can construct a `Posix` time from milliseconds using the [millisToPosix](https://package.elm-lang.org/packages/elm/time/latest/Time#millisToPosix)
function located in the [elm/time](https://package.elm-lang.org/packages/elm/time/latest/) package.

    fromPosix (Time.millisToPosix 0)
    -- Time { hours = Hour 0, minutes = Minute 0, seconds = Second 0, milliseconds = Millisecond 0 }

    fromPosix (Time.millisToPosix 1566795954000)
    -- Time { hours = Hour 5, minutes = Minute 5, seconds = Second 54, milliseconds = Millisecond 0 }

    fromPosix (Time.millisToPosix 1566777600000)
    -- Time { hours = Hour 0, minutes = Minute 0, seconds = Second 0, milliseconds = Millisecond 0 }

Notice that in the first and third examples the timestamps that are used are different but the result [Times](DateTime-Clock#Time) are identical.
This is because the [Clock](DateTime-Clock) module only extracts the `Hours`, `Minutes`, `Seconds` and `Milliseconds` from the given
[Posix](https://package.elm-lang.org/packages/elm/time/latest/Time#Posix) time given. This means that if we attempt to convert both of these `Times`
back [toMillis](DateTime-Clock#toMillis) they will result in the same milliseconds. It is recommended using the [fromPosix](DateTime-DateTime#fromPosix)
function provided in the [DateTime](DateTime-DateTime) module if you need to preserve both `Date` and `Time`.

-}
fromPosix : Time_.Posix -> Time
fromPosix =
    Internal.fromPosix


{-| Construct a clock `Time` from raw hour, minute, second, millisecond integers.

    time = { hours = 23, minutes = 15, seconds = 45, milliseconds = 999 }
    fromRawParts time -- Just (Time { hours = Hour 23, minutes = Minute 15, seconds = Second 45, milliseconds = Millisecond 999 })

    time2 = { hours = 24, minutes = 15, seconds = 45, milliseconds = 999 }
    fromRawParts time -- Nothing

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



-- Converters


{-| Convert a `Time` to milliseconds.

    time = fromRawParts { hours = 12, minutes = 30, seconds = 0, milliseconds = 0 }
    Maybe.map toMillis time -- Just 45000000

    toMillis <| fromPosix (Time.millisToPosix 1566777600000) -- 0

-}
toMillis : Time -> Int
toMillis =
    Internal.toMillis



-- Accessors


{-| Extract the `Hours` part of a [Time](DateTime-Clock#Time).

    time = fromRawParts { hours = 12, minutes = 15, seconds = 45, milliseconds = 500 }
    Maybe.map getHours time -- Just 12

-}
getHours : Time -> Int
getHours =
    Internal.hoursToInt << Internal.getHours


{-| Extract the `Minutes` part of a [Time](DateTime-Clock#Time).

    time = fromRawParts { hours = 12, minutes = 15, seconds = 45, milliseconds = 500 }
    Maybe.map getMinutes time -- Just 15

-}
getMinutes : Time -> Int
getMinutes =
    Internal.minutesToInt << Internal.getMinutes


{-| Extract the `Seconds` part of a [Time](DateTime-Clock#Time).

    time = fromRawParts { hours = 12, minutes = 15, seconds = 45, milliseconds = 500 }
    Maybe.map getSeconds time -- Just 45

-}
getSeconds : Time -> Int
getSeconds =
    Internal.secondsToInt << Internal.getSeconds


{-| Extract the `Millisecond` part of a [Time](DateTime-Clock#Time).

    time = fromRawParts { hours = 12, minutes = 15, seconds = 45, milliseconds = 500 }
    Maybe.map getMilliseconds time -- Just 500

-}
getMilliseconds : Time -> Int
getMilliseconds =
    Internal.millisecondsToInt << Internal.getMilliseconds



-- Setters


{-| Attempts to set the `Hour` on an existing time.

    time = fromRawParts { hours = 15, minutes = 45, seconds = 54, milliseconds = 250 }

    Maybe.andThen (setHours 23) time -- Just (Time { hours = Hour 23, minutes = Minute 45, seconds = Second 54, milliseconds = Millisecond 250 })
    Maybe.andThen (setHours 24) time -- Nothing

-}
setHours : Int -> Time -> Maybe Time
setHours =
    Internal.setHours


{-| Attempts to set the `Minute` on an existing time.

    time = fromRawParts { hours = 15, minutes = 45, seconds = 54, milliseconds = 250 }

    Maybe.andThen (setMinutes 36) time -- Just (Time { hours = Hour 15, minutes = Minute 36, seconds = Second 54, milliseconds = Millisecond 250 })
    Maybe.andThen (setMinutes 60) time -- Nothing

-}
setMinutes : Int -> Time -> Maybe Time
setMinutes =
    Internal.setMinutes


{-| Attempts to set the `Second` on an existing time.

    time = fromRawParts { hours = 15, minutes = 45, seconds = 54, milliseconds = 250 }

    Maybe.andThen (setSeconds 20) time -- Just (Time { hours = Hour 15, minutes = Minute 45, seconds = Second 20, milliseconds = Millisecond 250 })
    Maybe.andThen (setSeconds 60) time -- Nothing

-}
setSeconds : Int -> Time -> Maybe Time
setSeconds =
    Internal.setSeconds


{-| Attempts to set the `Millisecond` on an existing time.

    time = fromRawParts { hours = 15, minutes = 45, seconds = 54, milliseconds = 250 }

    Maybe.andThen (setMilliseconds 589) time -- Just (Time { hours = Hour 15, minutes = Minute 45, seconds = Second 54, milliseconds = Millisecond 589 })
    Maybe.andThen (setMilliseconds 1000) time -- Nothing

-}
setMilliseconds : Int -> Time -> Maybe Time
setMilliseconds =
    Internal.setMilliseconds



-- Incrementers


{-| Increments an `Hour` inside a [Time](DateTime-Clock#Time). The [Time](DateTime-Clock#Time) will keep on cycling forward with a
maximum time of _23:59:59.999_. It also returns a `Bool` flag which indicates if the new `Time` has passed through the midnight hour ( 00:00:00.000 ).
This flag can be used in order to notify that a `Day` has passed but it is advised to use the [DateTime](DateTime-DateTime) module for these kind
of operations since it provides all the available helpers and takes care of any [Calendar](DateTime-Calendar) changes.

    time = fromRawParts { hours = 12, minutes = 15, seconds = 45, milliseconds = 750 }
    Maybe.map incrementHours time -- Just (Time { hours = Hour 13, minutes = Minute 15, seconds = Second 45, milliseconds = Millisecond 750 }, False)

    time2 = fromRawParts { hours = 23, minutes = 0, seconds = 0, milliseconds = 0 }
    Maybe.map incrementHours time2 -- Just (Time { hours = Hour 0, minutes = Minute 0, seconds = Second 0, milliseconds = Millisecond 0 }, True)

-}
incrementHours : Time -> ( Time, Bool )
incrementHours =
    Internal.incrementHours


{-| Increments a `Minute` inside a [Time](DateTime-Clock#Time). The [Time](DateTime-Clock#Time) will keep on cycling around
as mentioned in the [incrementHours](DateTime-Clock#incrementHours) description.

    time = fromRawParts { hours = 12, minutes = 59, seconds = 45, milliseconds = 750 }
    Maybe.map incrementMinutes time -- Just (Time { hours = Hour 13, minutes = Minute 0, seconds = Second 45, milliseconds = Millisecond 750 }, False)

    time2 = fromRawParts { hours = 23, minutes = 59, seconds = 45, milliseconds = 750 }
    Maybe.map incrementMinutes time2 -- Just (Time { hours = Hour 0, minutes = Minute 0, seconds = Second 45, milliseconds = Millisecond 750}, True)

-}
incrementMinutes : Time -> ( Time, Bool )
incrementMinutes =
    Internal.incrementMinutes


{-| Increments a `Second` inside a [Time](DateTime-Clock#Time). The [Time](DateTime-Clock#Time) will keep on cycling around
as mentioned in the [incrementHours](DateTime-Clock#incrementHours) description.

    time = fromRawParts { hours = 12, minutes = 59, seconds = 59, milliseconds = 750 }
    Maybe.map incrementSeconds time -- Just (Time { hours = Hour 13, minutes = Minute 0, seconds = Second 0, milliseconds = Millisecond 750 }, False)

    time2 = fromRawParts { hours = 23, minutes = 59, seconds = 59, milliseconds = 750 }
    Maybe.map incrementSeconds time2 -- Just (Time { hours = Hour 0, minutes = Minute 0, seconds = Second 0, milliseconds = Millisecond 750}, True)

-}
incrementSeconds : Time -> ( Time, Bool )
incrementSeconds =
    Internal.incrementSeconds


{-| Increments a `Millisecond` inside a [Time](DateTime-Clock#Time). The [Time](DateTime-Clock#Time) will keep on cycling around
as mentioned in the [incrementHours](DateTime-Clock#incrementHours) description.

    time = fromRawParts { hours = 12, minutes = 59, seconds = 59, milliseconds = 999 }
    Maybe.map incrementMilliseconds time -- Just (Time { hours = Hour 13, minutes = Minute 0, seconds = Second 0, milliseconds = Millisecond 0 }, False)

    time2 = fromRawParts { hours = 23, minutes = 59, seconds = 59, milliseconds = 999 }
    Maybe.map incrementMilliseconds time2 -- Just (Time { hours = Hour 0, minutes = Minute 0, seconds = Second 0, milliseconds = Millisecond 0}, True)

-}
incrementMilliseconds : Time -> ( Time, Bool )
incrementMilliseconds =
    Internal.incrementMilliseconds



-- Decrementers


{-| Decrements an `Hour` inside a [Time](DateTime-Clock#Time). The [Time](DateTime-Clock#Time) will keep on cycling backwards with a
minimum time of _00:00:00.000_. It also returns a `Bool` flag which indicates if the new `Time` has passed through the midnight hour ( 00:00:00.000 ).
This flag can be used in order to notify that a `Day` has passed but it is advised to use the [DateTime](DateTime-DateTime) module for these kind
of operations since it provides all the available helpers and takes care of any [Calendar](DateTime-Calendar) changes.

    time = fromRawParts { hours = 13, minutes = 15, seconds = 45, milliseconds = 750 }
    Maybe.map decrementHours time -- Just (Time { hours = Hour 12, minutes = Minute 15, seconds = Second 45, milliseconds = Millisecond 750 }, False)

    time2 = fromRawParts { hours = 0, minutes = 59, seconds = 59, milliseconds = 999 }
    Maybe.map decrementHours time2 -- Just (Time { hours = Hour 23, minutes = Minute 59, seconds = Second 59, milliseconds = Millisecond 999 }, True)

-}
decrementHours : Time -> ( Time, Bool )
decrementHours =
    Internal.decrementHours


{-| Decrements a `Minute` inside a [Time](DateTime-Clock#Time). The [Time](DateTime-Clock#Time) will keep on cycling backwards
as mentioned in the [incrementHours](DateTime-Clock#decrementHours) description.

    time = fromRawParts { hours = 12, minutes = 15, seconds = 0, milliseconds = 0 }
    Maybe.map decrementMinutes time -- Just (Time { hours = Hour 12, minutes = Minute 14, seconds = Second 0, milliseconds = Millisecond 0 }, False)

    time2 = fromRawParts { hours = 0, minutes = 0, seconds = 0, milliseconds = 0 }
    Maybe.map decrementMinutes time2 -- Just (Time { hours = Hour 23, minutes = Minute 59, seconds = Second 0, milliseconds = Millisecond 0 }, True)

-}
decrementMinutes : Time -> ( Time, Bool )
decrementMinutes =
    Internal.decrementMinutes


{-| Decrements a `Second` inside a [Time](DateTime-Clock#Time). The [Time](DateTime-Clock#Time) will keep on cycling backwards
as mentioned in the [incrementHours](DateTime-Clock#decrementHours) description.

    time = fromRawParts { hours = 12, minutes = 15, seconds = 0, milliseconds = 0 }
    Maybe.map decrementSeconds time -- Just (Time { hours = Hour 12, minutes = Minute 14, seconds = Second 59, milliseconds = Millisecond 0 }, False)

    time2 = fromRawParts { hours = 0, minutes = 0, seconds = 0, milliseconds = 0 }
    Maybe.map decrementSeconds time2 -- Just (Time { hours = Hour 23, minutes = Minute 59, seconds = Second 59, milliseconds = Millisecond 0 }, True)

-}
decrementSeconds : Time -> ( Time, Bool )
decrementSeconds =
    Internal.decrementSeconds


{-| Decrements a `Millisecond` inside a [Time](DateTime-Clock#Time). The [Time](DateTime-Clock#Time) will keep on cycling backwards
as mentioned in the [incrementHours](DateTime-Clock#decrementHours) description.

    time = fromRawParts { hours = 12, minutes = 15, seconds = 0, milliseconds = 0 }
    Maybe.map decrementMilliseconds time -- Just (Time { hours = Hour 12, minutes = Minute 14, seconds = Second 59, milliseconds = Millisecond 999 }, False)

    time2 = fromRawParts { hours = 0, minutes = 0, seconds = 0, milliseconds = 0 }
    Maybe.map decrementMilliseconds time2 -- Just (Time { hours = Hour 23, minutes = Minute 59, seconds = Second 59, milliseconds = Millisecond 999 }, True)

-}
decrementMilliseconds : Time -> ( Time, Bool )
decrementMilliseconds =
    Internal.decrementMilliseconds



-- Comparers


{-| Compare two `Time` values.

    past = fromRawParts { hours = 15, minutes = 45, seconds = 24, milliseconds = 780 }
    future = fromRawParts { hours = 15, minutes = 45, seconds = 24, milliseconds = 800 }

    Maybe.map2 compare past past -- Just EQ
    Maybe.map2 compare past future -- Just LT
    Maybe.map2 compare future past -- Just GT

-}
compare : Time -> Time -> Order
compare =
    Internal.compare



-- Utilities


{-| Sorts a List of 'Time' based on their representation in milliseconds.

    midnight = fromRawParts { hours = 0, minutes = 0, seconds = 0, milliseconds = 0 }
    dawn = fromRawParts { hours = 6, minutes = 0, seconds = 0, milliseconds = 0 }
    noon = fromRawParts { hours = 12, minutes = 0, seconds = 0, milliseconds = 0 }
    dusk = fromRawParts { hours = 18, minutes = 0, seconds = 0, milliseconds = 0 }

    sort (List.filterMap identity [ noon, dawn, dusk, midnight ])
    -- [ Time { hours = Hour 0, minutes = Minute 0, seconds = Second 0, milliseconds = Millisecond 0 }
    -- , Time { hours = Hour 6, minutes = Minute 0, seconds = Second 0, milliseconds = Millisecond 0 }
    -- , Time { hours = Hour 12, minutes = Minute 0, seconds = Second 0, milliseconds = Millisecond 0 }
    -- , Time { hours = Hour 18, minutes = Minute 0, seconds = Second 0, milliseconds = Millisecond 0 }
    -- ]

-}
sort : List Time -> List Time
sort =
    Internal.sort



-- Constants


{-| Returns midnight time.
-}
midnight : Time
midnight =
    Internal.midnight
