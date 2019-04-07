module Calendar.Internal exposing
    ( Date(..), RawDate
    , fromPosix, fromRawParts, fromRawDay, fromYearMonthDay, yearFromInt, dayFromInt
    , toPosix, toMillis, yearToInt, monthToInt, dayToInt
    , getYear, getMonth, getDay
    , setYear, setMonth, setDay
    , incrementYear, incrementMonth, incrementDay
    , decrementYear, decrementMonth, decrementDay
    , compare, compareYears, compareMonths, compareDays
    , getDateRange, getDatesInMonth, getDayDiff, getFollowingMonths, getPrecedingMonths, getWeekday, isLeapYear, lastDayOf, millisInYear, sort
    , months, millisInADay
    , Year(..), Month, Day(..)
    , millisSinceEpoch, millisSinceStartOfTheYear, millisSinceStartOfTheMonth
    , fromZonedPosix
    )

{-| The [Calendar](Calendar#) module was introduced in order to keep track of the `Calendar Date` concept.
It has no knowledge of `Time` therefore it can only represent a [Date](Calendar#Date)
which consists of a `Day`, a `Month` and a `Year`. You can construct a `Calendar Date` either
from a [Posix](https://package.elm-lang.org/packages/elm/time/latest/Time#Posix) time or by
using its [Raw constituent parts](Calendar#RawDate). You can use a `Date` and the
Calendar's utilities as a standalone or you can combine a [Date](Calendar#Date) and a
[Time](Clock#Time) in order to get a [DateTime](DateTime#DateTime) which can then be converted into
a [Posix](https://package.elm-lang.org/packages/elm/time/latest/Time#Posix).


# Type definition

@docs Date, RawDate


# Creating values

@docs fromPosix, fromRawParts, fromRawDay, fromYearMonthDay, yearFromInt, dayFromInt


# Conversions

@docs toPosix, toMillis, yearToInt, monthToInt, dayToInt


# Accessors

@docs getYear, getMonth, getDay


# Setters

@docs setYear, setMonth, setDay


# Increment value

@docs incrementYear, incrementMonth, incrementDay


# Decrement values

@docs decrementYear, decrementMonth, decrementDay


# Compare values

@docs compare, compareYears, compareMonths, compareDays


# Utilities

@docs getDateRange, getDatesInMonth, getDayDiff, getFollowingMonths, getPrecedingMonths, getWeekday, isLeapYear, lastDayOf, millisInYear, sort


# Constants

@docs months, millisInADay


# Exposed for Testing Purposes

@docs Year, Month, Day
@docs millisSinceEpoch, millisSinceStartOfTheYear, millisSinceStartOfTheMonth
@docs fromZonedPosix

-}

import Array exposing (Array)
import Time


{-| A full ([Gregorian](https://en.wikipedia.org/wiki/Gregorian_calendar)) calendar date.
-}
type Date
    = Date InternalDate


{-| The internal representation of Date and its constituent parts.
-}
type alias InternalDate =
    { year : Year
    , month : Month
    , day : Day
    }


{-| A calendar year.
-}
type Year
    = Year Int


{-| A calendar month.
-}
type alias Month =
    Time.Month


{-| A calendar day.
-}
type Day
    = Day Int


{-| The raw representation of a date.
-}
type alias RawDate =
    { year : Int
    , month : Time.Month
    , day : Int
    }



-- Creating a `Date`


{-| Construct a [Date](Calendar#Date) from a [Posix](https://package.elm-lang.org/packages/elm/time/latest/Time#Posix) time.
You can construct a `Posix` time from milliseconds using the [millisToPosix](https://package.elm-lang.org/packages/elm/time/latest/Time#millisToPosix)
function located in the [elm/time](https://package.elm-lang.org/packages/elm/time/latest/) package.

    fromPosix (Time.millisToPosix 0)
    -- Date { day = Day 1, month = Jan, year = Year 1970 } : Date

    fromPosix (Time.millisToPosix 1566795954000)
    -- Date { day = Day 26, month = Aug, year = Year 2019 } : Date

    fromPosix (Time.millisToPosix 1566777600000)
    -- Date { day = Day 26, month = Aug, year = Year 2019 } : Date

Notice that in the second and third examples the timestamps that are used are different but the resulting [Dates](Calendar#Date) are identical.
This is because the [Calendar](Calendar#) module doesn't have any knowledge of `Time` which means that if we attempt to convert both of these dates back [toMillis](Calendar#toMillis)
they will result in the same milliseconds. It is recommended using the [fromPosix](DateTime#fromPosix) function provided in the [DateTime](DateTime#)
module if you need to preserve both `Date` and `Time`.

-}
fromPosix : Time.Posix -> Date
fromPosix posix =
    Date
        { year = Year (Time.toYear Time.utc posix)
        , month = Time.toMonth Time.utc posix
        , day = Day (Time.toDay Time.utc posix)
        }


{-| Constructs a [Date](Calendar#Date) from a [Posix](https://package.elm-lang.org/packages/elm/time/latest/Time#Posix) time and
a [timezone](https://package.elm-lang.org/packages/elm/time/latest/Time#Zone). This function shouldn't be exposed to the consumer because
of the reasons outlined on this [issue](https://github.com/PanagiotisGeorgiadis/Elm-DateTime/issues/2).
-}
fromZonedPosix : Time.Zone -> Time.Posix -> Date
fromZonedPosix zone posix =
    Date
        { year = Year (Time.toYear zone posix)
        , month = Time.toMonth zone posix
        , day = Day (Time.toDay zone posix)
        }


{-| Attempt to construct a [Date](Calendar#Date) from its (raw) constituent parts.
Returns `Nothing` if any parts or their combination would form an invalid date.

    fromRawParts { day = 25, month = Dec, year = 2019 }
    -- Just (Date { day = Day 25, month = Dec, year = Year 2019 }) : Maybe Date

    fromRawParts { day = 29, month = Feb, year = 2019 }
    -- Nothing : Maybe Date

-}
fromRawParts : RawDate -> Maybe Date
fromRawParts { year, month, day } =
    Maybe.andThen (\y -> fromRawDay y month day) (yearFromInt year)


{-| Attempt to create a `Date` from its constituent Year and Month by using its raw day.
Returns `Nothing` if any parts or their combination would form an invalid date.

    fromRawDay (Year 2018) Dec 25 -- Just (Date { day = Day 25, month = Dec, year = Year 2018 }) : Maybe Date

    fromRawDay (Year 2020) Feb 29 -- Just (Date { day = Day 11, month = Feb, year = Year 2020 }) : Maybe Date

    fromRawDay (Year 2019) Feb 29 -- Nothing : Maybe Date

-}
fromRawDay : Year -> Month -> Int -> Maybe Date
fromRawDay year month day =
    dayFromInt year month day
        |> Maybe.andThen (fromYearMonthDay year month)


{-| Attempt to create a `Date` from its constituent parts.
Returns `Nothing` if the combination would form an invalid date.

    fromYearMonthDay (Year 2018) Dec (Day 25) -- Just (Date { year = (Year 2018), month = Dec, day = (Day 25)}) : Maybe Date

    fromYearMonthDay (Year 2020) Feb (Day 29) -- Just (Date { day = Day 29, month = Feb, year = Year 2020 }) : Maybe Date

    fromYearMonthDay (Year 2019) Feb (Day 29) -- Nothing : Maybe Date

-}
fromYearMonthDay : Year -> Month -> Day -> Maybe Date
fromYearMonthDay y m d =
    let
        maxDay =
            lastDayOf y m
    in
    case compareDays d maxDay of
        GT ->
            Nothing

        _ ->
            Just (Date { year = y, month = m, day = d })


{-| Attempt to construct a 'Year' from an Int value. Currently the validity
of the year is based on the integer being greater than zero. ( year > 0 )

    yearFromInt 1970 -- Just (Year 1970) : Maybe Year

    yearFromInt -1 -- Nothing : Maybe Year

-}
yearFromInt : Int -> Maybe Year
yearFromInt year =
    if year > 0 then
        Just (Year year)

    else
        Nothing


{-| Attempt to construct a 'Day' from an Int value. Currently the validity
of the day is based on the validity of the 'Date' object being created.
This means that given a valid year & month we check for the 'Date' max valid day.
Then the given Int needs to be greater than 0 and less than the max valid day
for the given year && month combination.
( 1 >= day >= maxValidDay )

    dayFromInt (Year 2018) Dec 25 -- Just (Day 25) : Maybe Day

    dayFromInt (Year 2020) Feb 29 -- Just (Day 29) : Maybe Day

    dayFromInt (Year 2019) Feb 29 -- Nothing : Maybe Day

-}
dayFromInt : Year -> Month -> Int -> Maybe Day
dayFromInt year month day =
    let
        maxValidDay =
            dayToInt (lastDayOf year month)
    in
    if day > 0 && Basics.compare day maxValidDay /= GT then
        Just (Day day)

    else
        Nothing



-- Conversions


{-| Transforms a 'Date' to a Posix time.
-}
toPosix : Date -> Time.Posix
toPosix =
    Time.millisToPosix << toMillis


{-| Transforms a [Date](Calendar#Date) into milliseconds.

    date = fromRawParts { day = 25, month = Dec, year = 2019 }
    Maybe.map toMillis date -- Just 1577232000000 == 25 Dec 2019 00:00:00.000

    want = 1566795954000 -- 26 Aug 2019 05:05:54.000
    got = toMillis (fromPosix (Time.millisToPosix want)) -- 1566777600000 == 26 Aug 2019 00:00:00.000

    want == got -- False

Notice that transforming a **date** to milliseconds will always get you midnight hours.
The first example above will return a timestamp that equals to **Wed 25th of December 2019 00:00:00.000**
and the second example will return a timestamp that equals to **26th of August 2019 00:00:00.000** even though
the timestamp we provided in the [fromPosix](Calendar#fromPosix) was equal to **26th of August 2019 05:05:54.000**

-}
toMillis : Date -> Int
toMillis (Date { year, month, day }) =
    millisSinceEpoch year
        + millisSinceStartOfTheYear year month
        + millisSinceStartOfTheMonth day


{-| Extract the Int value of a 'Year'.

    -- date == 26 Aug 1992
    yearToInt (getYear date) -- 1992 : Int

-}
yearToInt : Year -> Int
yearToInt (Year year) =
    year


{-| Convert a given [Month](https://package.elm-lang.org/packages/elm/time/latest/Time#Month) to an integer starting from 1.

    monthToInt Jan -- 1 : Int

    monthToInt Aug -- 8 : Int

Note: Obviously this function can be implemented in a dozen different approaches but decided to keep it simple.

-}
monthToInt : Month -> Int
monthToInt month =
    case month of
        Time.Jan ->
            1

        Time.Feb ->
            2

        Time.Mar ->
            3

        Time.Apr ->
            4

        Time.May ->
            5

        Time.Jun ->
            6

        Time.Jul ->
            7

        Time.Aug ->
            8

        Time.Sep ->
            9

        Time.Oct ->
            10

        Time.Nov ->
            11

        Time.Dec ->
            12


{-| Extract the Int part of a 'Day'.

    -- date == 26 Aug 1992
    dayToInt (getDay date) -- 26 : Int

-}
dayToInt : Day -> Int
dayToInt (Day day) =
    day



-- Accessors


{-| Extract the `Year` part of a [Date](Calendar#Date).

    -- date == 25 Dec 2019
    getYear date -- Year 2019 : Year

    yearToInt (getYear date) -- 2019 : Int

-}
getYear : Date -> Year
getYear (Date { year }) =
    year


{-| Extract the `Month` part of a [Date](Calendar#Date).

    -- date == 25 Dec 2019
    getMonth date -- Dec : Month

-}
getMonth : Date -> Month
getMonth (Date { month }) =
    month


{-| Extract the `Day` part of a [Date](Calendar#Date).

    -- date == 25 Dec 2019
    getDay date -- Day 25 : Day

    dayToInt (getDay date) -- 25 : Int

-}
getDay : Date -> Day
getDay (Date date) =
    date.day



-- Setters


{-| Attempts to set the `Year` part of a [Date](Calendar#Date).

    -- date == 29 Feb 2020
    setYear 2024 date -- Just (29 Feb 2024) : Maybe Date

    setYear 2019 date -- Nothing : Maybe Date

-}
setYear : Int -> Date -> Maybe Date
setYear year date =
    fromRawParts
        { year = year
        , month = getMonth date
        , day = dayToInt (getDay date)
        }


{-| Attempts to set the `Month` part of a [Date](Calendar#Date).

    -- date == 31 Jan 2019
    setMonth Aug date -- Just (31 Aug 2019) : Maybe Date

    setMonth Apr date -- Nothing : Maybe Date

-}
setMonth : Month -> Date -> Maybe Date
setMonth month date =
    fromRawParts
        { year = yearToInt (getYear date)
        , month = month
        , day = dayToInt (getDay date)
        }


{-| Attempts to set the `Day` part of a [Date](Calendar#Date).

    -- date == 31 Jan 2019
    setDay 25 date -- Just (25 Jan 2019) : Maybe Date

    setDay 32 date -- Nothing : Maybe Date

-}
setDay : Int -> Date -> Maybe Date
setDay day date =
    fromRawParts
        { year = yearToInt (getYear date)
        , month = getMonth date
        , day = day
        }



-- Increment values


{-| Increments the `Year` in a given [Date](Calendar#Date) while preserving the `Month` and `Day` parts.

    -- date  == 31 Jan 2019
    incrementYear date -- 31 Jan 2020 : Date

    -- date2 == 29 Feb 2020
    incrementYear date2 -- 28 Feb 2021 : Date

**Note:** In the first example, incrementing the `Year` causes no changes in the `Month` and `Day` parts.
On the second example we see that the `Day` part is different than the input. This is because the resulting date
would be an invalid date ( _**29th of February 2021**_ ). As a result of this scenario we fall back to the last valid day
of the given `Month` and `Year` combination.

---

**Note 2:** Here we cannot rely on transforming the date to millis and adding a year because
of the edge case restrictions such as current year might be a leap year and the given date may
contain the 29th of February but on the next year, February would only have 28 days.

-}
incrementYear : Date -> Date
incrementYear (Date date) =
    let
        updatedYear =
            Year (yearToInt date.year + 1)

        lastDayOfUpdatedMonth =
            lastDayOf updatedYear date.month

        updatedDay =
            case compareDays date.day lastDayOfUpdatedMonth of
                GT ->
                    lastDayOfUpdatedMonth

                _ ->
                    date.day
    in
    Date
        { year = updatedYear
        , month = date.month
        , day = updatedDay
        }


{-| Increments the `Month` in a given [Date](Calendar#Date). It will also roll over to the next year where applicable.

    -- date  == 15 Sep 2019
    incrementMonth date -- 15 Oct 2019 : Date

    -- date2 == 15 Dec 2019
    incrementMonth date2 -- 15 Jan 2020 : Date

    -- date3 == 31 Jan 2019
    incrementMonth date3 -- 28 Feb 2019 : Date

**Note:** In the first example, incrementing the `Month` causes no changes in the `Year` and `Day` parts while on the second
example it rolls forward the 'Year'. On the last example we see that the `Day` part is different than the input. This is because
the resulting date would be an invalid one ( _**31st of February 2019**_ ). As a result of this scenario we fall back to the last
valid day of the given `Month` and `Year` combination.

-}
incrementMonth : Date -> Date
incrementMonth (Date date) =
    let
        updatedMonth =
            rollMonthForward date.month

        updatedYear =
            case updatedMonth of
                Time.Jan ->
                    Year (yearToInt date.year + 1)

                _ ->
                    date.year

        lastDayOfUpdatedMonth =
            lastDayOf updatedYear updatedMonth

        updatedDay =
            case compareDays date.day lastDayOfUpdatedMonth of
                GT ->
                    lastDayOfUpdatedMonth

                _ ->
                    date.day
    in
    Date
        { year = updatedYear
        , month = updatedMonth
        , day = updatedDay
        }


{-| Gets next month from the given month.

    rollMonthForward Dec -- Jan : Month

    rollMonthForward Nov -- Dec : Month

-}
rollMonthForward : Month -> Month
rollMonthForward month =
    case month of
        Time.Jan ->
            Time.Feb

        Time.Feb ->
            Time.Mar

        Time.Mar ->
            Time.Apr

        Time.Apr ->
            Time.May

        Time.May ->
            Time.Jun

        Time.Jun ->
            Time.Jul

        Time.Jul ->
            Time.Aug

        Time.Aug ->
            Time.Sep

        Time.Sep ->
            Time.Oct

        Time.Oct ->
            Time.Nov

        Time.Nov ->
            Time.Dec

        Time.Dec ->
            Time.Jan


{-| Increments the `Day` in a given [Date](Calendar#Date). Will also increment `Month` and `Year` where applicable.

    -- date  == 25 Aug 2019
    incrementDay date -- 26 Aug 2019 : Date

    -- date2 == 31 Dec 2019
    incrementDay date2 -- 1 Jan 2020 : Date

**Note:** Its safe to get the next day by using milliseconds here because we are responsible
for transforming the given date to millis and parsing it from millis. The incrementYear + incrementMonth
are totally different cases and they both have respectively different edge cases and implementations.

-}
incrementDay : Date -> Date
incrementDay date =
    let
        millis =
            Time.posixToMillis (toPosix date) + millisInADay

        newDate =
            fromPosix (Time.millisToPosix millis)
    in
    newDate



-- Decrement values


{-| Decrements the `Year` in a given [Date](Calendar#Date) while preserving the `Month` and `Day` parts.

    -- date  == 31 Jan 2019
    decrementYear date -- 31 Jan 2018 : Date

    -- date2 == 29 Feb 2020
    decrementYear date2 -- 28 Feb 2019 : Date

**Note:** In the first example, decrementing the `Year` causes no changes in the `Month` and `Day` parts.
On the second example we see that the `Day` part is different than the input. This is because the resulting date
would be an invalid date ( _**29th of February 2019**_ ). As a result of this scenario we fall back to the last
valid day of the given `Month` and `Year` combination.

**Note 2:** Here we cannot rely on transforming the date to millis and removing a year because of the
edge case restrictions such as current year might be a leap year and the given date may contain the
29th of February but on the previous year, February would only have 28 days.

-}
decrementYear : Date -> Date
decrementYear (Date date) =
    let
        updatedYear =
            Year (yearToInt date.year - 1)

        lastDayOfUpdatedMonth =
            lastDayOf updatedYear date.month

        updatedDay =
            case compareDays date.day lastDayOfUpdatedMonth of
                GT ->
                    lastDayOfUpdatedMonth

                _ ->
                    date.day
    in
    Date
        { year = updatedYear
        , month = date.month
        , day = updatedDay
        }


{-| Decrements the `Month` in a given [Date](Calendar#Date). It will also roll backwards to the previous year where applicable.

    -- date  == 15 Sep 2019
    decrementMonth date -- 15 Aug 2019 : Date

    -- date2 == 15 Jan 2020
    decrementMonth date2 -- 15 Dec 2019 : Date

    -- date3 == 31 Dec 2019
    decrementMonth date3 -- 30 Nov 2019 : Date

**Note:** In the first example, decrementing the `Month` causes no changes in the `Year` and `Day` parts while
on the second example it rolls backwards the `Year`. On the last example we see that the `Day` part is different
than the input. This is because the resulting date would be an invalid one ( _**31st of November 2019**_ ). As a result
of this scenario we fall back to the last valid day of the given `Month` and `Year` combination.

-}
decrementMonth : Date -> Date
decrementMonth (Date date) =
    let
        updatedMonth =
            rollMonthBackwards date.month

        updatedYear =
            case updatedMonth of
                Time.Dec ->
                    Year (yearToInt date.year - 1)

                _ ->
                    date.year

        lastDayOfUpdatedMonth =
            lastDayOf updatedYear updatedMonth

        updatedDay =
            case compareDays date.day lastDayOfUpdatedMonth of
                GT ->
                    lastDayOfUpdatedMonth

                _ ->
                    date.day
    in
    Date
        { year = updatedYear
        , month = updatedMonth
        , day = updatedDay
        }


{-| Gets next month from the given month.

    rollMonthBackwards Jan -- Dec : Month

    rollMonthBackwards Dec -- Nov : Month

-}
rollMonthBackwards : Month -> Month
rollMonthBackwards month =
    case month of
        Time.Jan ->
            Time.Dec

        Time.Feb ->
            Time.Jan

        Time.Mar ->
            Time.Feb

        Time.Apr ->
            Time.Mar

        Time.May ->
            Time.Apr

        Time.Jun ->
            Time.May

        Time.Jul ->
            Time.Jun

        Time.Aug ->
            Time.Jul

        Time.Sep ->
            Time.Aug

        Time.Oct ->
            Time.Sep

        Time.Nov ->
            Time.Oct

        Time.Dec ->
            Time.Nov


{-| Decrements the `Day` in a given [Date](Calendar#Date). Will also decrement `Month` and `Year` where applicable.

    -- date  == 27 Aug 2019
    decrementDay date -- 26 Aug 2019 : Date

    -- date2 == 1 Jan 2020
    decrementDay date2 -- 31 Dec 2019 : Date

**Note:** Its safe to get the previous day by using milliseconds here because we are responsible
for transforming the given date to millis and parsing it from millis. The decrementYear + decrementMonth
are totally different cases and they both have respectively different edge cases and implementations.

-}
decrementDay : Date -> Date
decrementDay date =
    let
        millis =
            Time.posixToMillis (toPosix date) - millisInADay

        newDate =
            fromPosix (Time.millisToPosix millis)
    in
    newDate



-- Compare values


{-| Compares the two given [Dates](Calendar#Date) and returns an [Order](https://package.elm-lang.org/packages/elm/core/latest/Basics#Order).

    -- past   == 25 Aug 2019
    -- future == 26 Aug 2019
    compare past past -- EQ : Order

    compare past future -- LT : Order

    compare future past -- GT : Order

-}
compare : Date -> Date -> Order
compare lhs rhs =
    let
        ( yearsComparison, monthsComparison, daysComparison ) =
            ( compareYears (getYear lhs) (getYear rhs)
            , compareMonths (getMonth lhs) (getMonth rhs)
            , compareDays (getDay lhs) (getDay rhs)
            )
    in
    case yearsComparison of
        EQ ->
            case monthsComparison of
                EQ ->
                    daysComparison

                _ ->
                    monthsComparison

        _ ->
            yearsComparison


{-| Compares two given `Years` and returns an Order.

    compareYears (Year 2016) (Year 2017) -- LT : Order

    compareYears (Year 2017) (Year 2016) -- GT : Order

    compareYears (Year 2015) (Year 2015) -- EQ : Order

-}
compareYears : Year -> Year -> Order
compareYears lhs rhs =
    Basics.compare (yearToInt lhs) (yearToInt rhs)


{-| Compares two given `Months` and returns an Order.

    compareMonths Jan Feb -- LT : Order

    compareMonths Dec Feb -- GT : Order

    compareMonths Aug Aug --EQ : Order

-}
compareMonths : Month -> Month -> Order
compareMonths lhs rhs =
    Basics.compare (monthToInt lhs) (monthToInt rhs)


{-| Compares two given `Days` and returns an Order.

    compareDays (Day 28) (Day 29) -- LT : Order

    compareDays (Day 28) (Day 15) -- GT : Order

    compareDays (Day 15) (Day 15) -- EQ : Order

-}
compareDays : Day -> Day -> Order
compareDays lhs rhs =
    Basics.compare (dayToInt lhs) (dayToInt rhs)



-- Utilities


{-| Returns an incrementally sorted [Date](Calendar#Date) list based on the **start** and **end** date parameters.
_**The resulting list will include both start and end dates**_.

    -- start == 26 Feb 2020
    -- end   == 1 Mar 2020

    getDateRange start end
    -- [ 26 Feb 2020, 27 Feb 2020, 28 Feb 2020, 29 Feb 2020, 1  Mar 2020 ] : List Date

    getDateRange end start
    -- [ 26 Feb 2020, 27 Feb 2020, 28 Feb 2020, 29 Feb 2020, 1  Mar 2020 ] : List Date

-}
getDateRange : Date -> Date -> List Date
getDateRange startDate endDate =
    let
        ( startPosix, endPosix ) =
            ( toPosix startDate
            , toPosix endDate
            )

        posixDiff =
            Time.posixToMillis endPosix - Time.posixToMillis startPosix

        daysDiff =
            posixDiff // 1000 // 60 // 60 // 24
    in
    if daysDiff > 0 then
        getDateRange_ daysDiff startDate []

    else
        getDateRange_ (abs daysDiff) endDate []


{-| Internal helper function for getDateRange.
-}
getDateRange_ : Int -> Date -> List Date -> List Date
getDateRange_ daysCount prevDate res =
    let
        updatedRes =
            res ++ [ prevDate ]
    in
    if daysCount > 0 then
        let
            ( updatedDaysCount, updatedPrevDate ) =
                ( daysCount - 1
                , incrementDay prevDate
                )
        in
        getDateRange_ updatedDaysCount updatedPrevDate updatedRes

    else
        updatedRes


{-| Returns a list of [Dates](Calendar#Date) for the given `Year` and `Month` combination.

    -- date == 26 Aug 2019

    getDatesInMonth date
    -- [ 1 Aug 2019, 2 Aug 2019, 3 Aug 2019, ..., 29 Aug 2019, 30 Aug 2019, 31 Aug 2019 ] : List Date

-}
getDatesInMonth : Date -> List Date
getDatesInMonth (Date { year, month }) =
    let
        lastDayOfTheMonth =
            dayToInt (lastDayOf year month)
    in
    List.map
        (\day ->
            Date
                { year = year
                , month = month
                , day = Day day
                }
        )
        (List.range 1 lastDayOfTheMonth)


{-| Returns the difference in days between two [Dates](Calendar#Date). We can have a negative difference of days as can be seen in the examples below.

    -- past   == 24 Aug 2019
    -- future == 26 Aug 2019
    getDayDiff past future -- 2  : Int

    getDayDiff future past -- -2 : Int

-}
getDayDiff : Date -> Date -> Int
getDayDiff startDate endDate =
    let
        ( startPosix, endPosix ) =
            ( toPosix startDate
            , toPosix endDate
            )

        posixDiff =
            Time.posixToMillis endPosix - Time.posixToMillis startPosix
    in
    posixDiff // millisInADay


{-| Returns a list with all the following months in a Calendar Year based on the `Month` argument provided.
The resulting list **will not include** the given `Month`.

    getFollowingMonths Aug -- [ Sep, Oct, Nov, Dec ] : List Month

    getFollowingMonths Dec -- [] : List Month

-}
getFollowingMonths : Month -> List Month
getFollowingMonths month =
    Array.toList <|
        Array.slice (monthToInt month) 12 months


{-| Returns a list with all the preceding months in a Calendar Year based on the `Month` argument provided.
The resulting list **will not include** the given `Month`.

    getPrecedingMonths May -- [ Jan, Feb, Mar, Apr ] : List Month

    getPrecedingMonths Jan -- [] : List Month

-}
getPrecedingMonths : Month -> List Month
getPrecedingMonths month =
    Array.toList <|
        Array.slice 0 (monthToInt month - 1) months


{-| Returns the weekday of a specific [Date](Calendar#Date).

    -- date == 26 Aug 2019
    getWeekday date -- Mon : Weekday

-}
getWeekday : Date -> Time.Weekday
getWeekday date =
    Time.toWeekday Time.utc (toPosix date)


{-| Checks if the `Year` part of the given [Date](Calendar#Date) is a leap year.

    -- date  == 25 Dec 2019
    isLeapYear (getYear date) -- False

    -- date2 == 25 Dec 2020
    isLeapYear (getYear date2) -- True

-}
isLeapYear : Year -> Bool
isLeapYear (Year int) =
    (modBy 4 int == 0) && ((modBy 400 int == 0) || not (modBy 100 int == 0))


{-| Get the last day of the given `Year` and `Month`.

    lastDayOf (Year 2018) Dec -- 31 : Int

    lastDayOf (Year 2019) Feb -- 28 : Int

    lastDayOf (Year 2020) Feb -- 29 : Int

-}
lastDayOf : Year -> Month -> Day
lastDayOf year month =
    case month of
        Time.Jan ->
            Day 31

        Time.Feb ->
            if isLeapYear year then
                Day 29

            else
                Day 28

        Time.Mar ->
            Day 31

        Time.Apr ->
            Day 30

        Time.May ->
            Day 31

        Time.Jun ->
            Day 30

        Time.Jul ->
            Day 31

        Time.Aug ->
            Day 31

        Time.Sep ->
            Day 30

        Time.Oct ->
            Day 31

        Time.Nov ->
            Day 30

        Time.Dec ->
            Day 31


{-| Returns the year milliseconds since Epoch. This basically
means that it will return the milliseconds that have elapsed from
the 1st Jan 1970 00:00:00.000 till the 1st Jan of the given `Year`.

**Note:** This function is intended to be used along with
millisSinceStartOfTheYear and millisSinceStartOfTheMonth in order
to get the total milliseconds elapsed since Epoch (1 Jan 1970 00:00:00.000).

    millisSinceEpoch (Year 1970) -- 0 : Int

    millisSinceEpoch (Year 1971) -- 31536000000 : Int

    millisSinceEpoch (Year 2019) -- 1546300800000 : Int

-}
millisSinceEpoch : Year -> Int
millisSinceEpoch (Year year) =
    let
        epochYear =
            1970

        getTotalMillis =
            List.sum << List.map millisInYear << List.filterMap yearFromInt
    in
    if year >= 1970 then
        -- We chose (year - 1) here because we want the milliseconds
        -- in the start of the target year in order to add
        -- the months + days + hours + minutes + secs + millis if we want to.
        getTotalMillis (List.range epochYear (year - 1))

    else
        -- We chose (epochYear - 1) here because we want to
        -- get the total milliseconds of all the previous years,
        -- including the target year which we'll then add
        -- the months + days + hours + minutes + secs + millis in millis
        -- in order to get the desired outcome.
        -- Example: Target date = 26 Aug 1950.
        -- totalMillis from 1/1/1950 - 1/1/1969 = -631152000000
        -- 26 Aug date millis = 20476800000
        -- Resulting millis will be = -631152000000 + 20476800000 == -610675200000 == 26 Aug 1950
        Basics.negate <| getTotalMillis (List.range year (epochYear - 1))


{-| Returns the month milliseconds since the start of a given year. This basically
means that it will return the milliseconds that have elapsed since the start of the
given year till the 1st of the given month.

**Note:** This function is intended to be used along with millisSinceEpoch and
millisSinceStartOfTheMonth.

    millisSinceStartOfTheYear (Year 2018) Time.Jan -- 0 : Int

    millisSinceStartOfTheYear (Year 2018) Time.Dec -- 28857600000 : Int

-}
millisSinceStartOfTheYear : Year -> Month -> Int
millisSinceStartOfTheYear year month =
    List.foldl
        (\m res ->
            res + (millisInADay * dayToInt (lastDayOf year m))
        )
        0
        (getPrecedingMonths month)


{-| Returns the `Day` milliseconds since the start of a given month. This basically
means that it will return the milliseconds that have elapsed since the 1st day of
the given month till the given `Day` at midnight hours.

**Note:** This function is intended to be used along with millisSinceEpoch and
millisSinceStartOfTheYear.

    millisSinceStartOfTheMonth (Day 1) -- 0 : Int

    millisSinceStartOfTheMonth (Day 15) -- 1209600000 : Int

-}
millisSinceStartOfTheMonth : Day -> Int
millisSinceStartOfTheMonth day =
    -- -1 on the day because we are currently on that day and it hasn't passed yet.
    -- We also need time in order to construct the full posix.
    millisInADay * (dayToInt day - 1)


{-| Returns the milliseconds in a year.
-}
millisInYear : Year -> Int
millisInYear year =
    if isLeapYear year then
        millisInADay * 366

    else
        millisInADay * 365


{-| Sorts incrementally a list of [Dates](Calendar#Date).

    -- past   == 26 Aug 1920
    -- epoch  == 1 Jan 1970
    -- future == 25 Dec 2020

    sort [ future, past, epoch ]
    -- [ 26 Aug 1920, 1 Jan 1970, 25 Dec 2020 ] : List Date

-}
sort : List Date -> List Date
sort =
    List.sortBy toMillis



-- Constants


{-| Returns a list of all the `Months` in Calendar order.
-}
months : Array Month
months =
    Array.fromList
        [ Time.Jan
        , Time.Feb
        , Time.Mar
        , Time.Apr
        , Time.May
        , Time.Jun
        , Time.Jul
        , Time.Aug
        , Time.Sep
        , Time.Oct
        , Time.Nov
        , Time.Dec
        ]


{-| Returns the milliseconds in a day.
-}
millisInADay : Int
millisInADay =
    1000 * 60 * 60 * 24
