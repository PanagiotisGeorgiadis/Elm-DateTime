module DateTime.Clock exposing
    ( Time, RawTime
    , fromRawParts
    , toMillis
    , getHours, getMinutes, getSeconds, getMilliseconds
    , setHours, setMinutes, setSeconds, setMilliseconds
    , incrementHours, incrementMinutes, incrementSeconds, incrementMilliseconds
    , decrementHours, decrementMinutes, decrementSeconds, decrementMilliseconds
    , compare
    , sort
    , midnight
    )

{-| A clock time.


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
    Internal.RawTime



-- Constructors


{-| Construct a clock `Time` from raw hour, minute, second, millisecond integers.

> fromRawParts { hours = 12, minutes = 30, seconds = 0, milliseconds = 0 }
> Just (Time { hours = Hours 12, minutes = Minutes 30, seconds = Second 0, milliseconds = Millisecond 0 }) : Maybe Time
>
> fromRawParts { hours = 12, minutes = 60, seconds = 0, milliseconds = 0 }
> Nothing : Maybe Time

-}
fromRawParts : RawTime -> Maybe Time
fromRawParts =
    Internal.fromRawParts



-- Converters


{-| Convert a `Time` to milliseconds.

> Maybe.map toMillis (fromRawParts { hours = 12, minutes = 30, seconds = 0, milliseconds = 0 })
> Just 45000000 : Maybe Int

-}
toMillis : Time -> Int
toMillis =
    Internal.toMillis



-- Accessors


{-| Returns the `Hour` portion of a 'Time' as an `Int`.

> Maybe.map getHours (fromRawParts { hours = 12, minutes = 15, seconds = 0, milliseconds = 0 })
> Just 12 : Maybe Int

-}
getHours : Time -> Int
getHours =
    Internal.hoursToInt << Internal.getHours


{-| Returns the `Minute` portion of a 'Time' as an `Int`.

> Maybe.map getMinutes (fromRawParts { hours = 12, minutes = 15, seconds = 0, milliseconds = 0 })
> Just 15 : Maybe Int

-}
getMinutes : Time -> Int
getMinutes =
    Internal.minutesToInt << Internal.getMinutes


{-| Returns the `Second` portion of a 'Time' as an `Int`.

> Maybe.map getSeconds (fromRawParts { hours = 12, minutes = 15, seconds = 0, milliseconds = 0 })
> Just 0 : Maybe Int

-}
getSeconds : Time -> Int
getSeconds =
    Internal.secondsToInt << Internal.getSeconds


{-| Returns the `Millisecond` portion of a 'Time' as an `Int`.

> Maybe.map getMilliseconds (fromRawParts { hours = 12, minutes = 15, seconds = 0, milliseconds = 0 })
> Just 0 : Maybe Int

-}
getMilliseconds : Time -> Int
getMilliseconds =
    Internal.millisecondsToInt << Internal.getMilliseconds



-- Setters


{-| Attempts to set the 'Hour' on an existing time.
-}
setHours : Time -> Int -> Maybe Time
setHours =
    Internal.setHours


{-| Attempts to set the 'Minute' on an existing time.
-}
setMinutes : Time -> Int -> Maybe Time
setMinutes =
    Internal.setHours


{-| Attempts to set the 'Second' on an existing time.
-}
setSeconds : Time -> Int -> Maybe Time
setSeconds =
    Internal.setSeconds


{-| Attempts to set the 'Millisecond' on an existing time.
-}
setMilliseconds : Time -> Int -> Maybe Time
setMilliseconds =
    Internal.setMilliseconds



-- Incrementers


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
incrementHours =
    Internal.incrementHours


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
incrementMinutes =
    Internal.incrementMinutes


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
incrementSeconds =
    Internal.incrementSeconds


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
incrementMilliseconds =
    Internal.incrementMilliseconds



-- Decrementers


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
decrementHours =
    Internal.decrementHours


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
decrementMinutes =
    Internal.decrementMinutes


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
decrementSeconds =
    Internal.decrementSeconds


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
decrementMilliseconds =
    Internal.decrementMilliseconds



-- Comparers


{-| Compare two `Time` values.

> time = fromRawParts { hours = 12, minutes = 15, seconds = 0, milliseconds = 0 }
> time2 = fromRawParts { hours = 12, minutes = 20, seconds = 0, milliseconds = 0 }
> Maybe.map2 compareHours time time2
> LT : Order

-}
compare : Time -> Time -> Order
compare =
    Internal.compare



-- Utilities


sort : List Time -> List Time
sort =
    Internal.sort



-- Constants


{-| Returns midnight time. To be used with caution.
-}
midnight : Time
midnight =
    Internal.midnight
