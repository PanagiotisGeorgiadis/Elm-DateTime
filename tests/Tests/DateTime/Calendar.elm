module Tests.DateTime.Calendar exposing
    ( Date(..), RawDate, Day(..), Year(..)
    , fromPosix, fromRawYearMonthDay
    , getDay, getMonth, getYear
    , toMillis, toPosix, dayToInt, monthToInt, yearToInt
    , getNextDay, getNextMonth, incrementYear
    , getPreviousDay, getPreviousMonth, decrementYear
    , compareDates, isLeapYear, weekdayFromDate, getDatesInMonth, getDateRange, months, lastDayOf
    , millisInADay
    , InternalDate, Month, compareDays, compareMonths, compareYears, dayFromInt, fromRawDay, fromYearMonthDay, getDateRange_, getFollowingMonths, getNextMonth_, getPrecedingMonths, getPreviousMonth_, millisInYear, millisSinceEpoch, millisSinceStartOfTheMonth, millisSinceStartOfTheYear, monthFromInt, yearFromInt
    )

{-| A calendar date.


# Type definition

@docs Date, RawDate, Day, Year


# Creating values

@docs fromPosix, fromRawYearMonthDay


# Accessors

@docs getDay, getMonth, getYear


# Converters

@docs toMillis, toPosix, dayToInt, monthToInt, yearToInt


# Incrementers

@docs getNextDay, getNextMonth, incrementYear


# Decrementers

@docs getPreviousDay, getPreviousMonth, decrementYear


# Utilities

@docs compareDates, isLeapYear, weekdayFromDate, getDatesInMonth, getDateRange, months, lastDayOf


# Constants

@docs millisInADay

-}

import Array exposing (Array)
import Time


{-| A full (Gregorian) calendar date.
-}
type Date
    = Date InternalDate


type alias InternalDate =
    { year : Year
    , month : Month
    , day : Day
    }


type Year
    = Year Int


type alias Month =
    Time.Month


type Day
    = Day Int


type alias RawDate =
    { rawYear : Int
    , rawMonth : Int
    , rawDay : Int
    }


{-| Extract the `Year` part of a `Date`.

> getYear (fromPosix (Time.millisToPosix 0))
> Year 1970 : Year

-- Can be exposed

-}
getYear : Date -> Year
getYear (Date { year }) =
    year


{-| Extract the Int value of a 'Year'.

> date = fromPosix (Time.millisToPosix 0)
> yearToInt (getYear date)
> 1970 : Int

-- Can be exposed

-}
yearToInt : Year -> Int
yearToInt (Year year) =
    year


{-| Attempt to construct a 'Year' from an Int value.
--- Currently the validity of the year is based on
--- the integer being greater than zero. ( year > 0 )

> yearFromInt 1970
> Just (Year 1970) : Maybe Year
>
> yearFromInt -1
> Nothing : Maybe Year

-- Internal use only

-}
yearFromInt : Int -> Maybe Year
yearFromInt year =
    if year > 0 then
        Just (Year year)

    else
        Nothing


{-| Extract the `Month` part of a `Date`.

> getMonth (fromPosix (Time.millisToPosix 0))
> Jan : Month

-- Can be exposed

-}
getMonth : Date -> Month
getMonth (Date { month }) =
    month


{-| Convert a given month to an integer starting from 1.

> monthToInt Jan
> 1 : Int
>
> monthToInt Aug
> 8 : Int

-- Can be exposed

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


{-| Attempt to construct a 'Month' from an Int value.
--- Currently the validity of the month is based on
--- the integer having a value between one and twelve. ( 1 ≥ month ≥ 12 )

> monthFromInt 1
> Just Jan : Maybe Month
>
> monthFromInt 12
> Just Dec : Maybe Month
>
> monthFromInt -1
> Nothing : Maybe Month

-- Internal, not to be exposed

-}
monthFromInt : Int -> Maybe Month
monthFromInt int =
    Array.get (int - 1) months


{-| Extract the `Day` part of a `Date`.

> getDay (fromPosix (Time.millisToPosix 0))
> Day 1 : Day

-- Can be exposed

-}
getDay : Date -> Day
getDay (Date date) =
    date.day


{-| Extract the Int part of a 'Day'.

> date = fromPosix (Time.millisToPosix 0)
> dayToInt (getDay date)
> 1 : Int

-- Can be exposed

-}
dayToInt : Day -> Int
dayToInt (Day day) =
    day


{-| Attempt to construct a 'Day' from an Int value.
--- Currently the validity of the day is based on
--- the validity of the 'Date' object being created.
--- This means that given a valid year & month we check
--- for the 'Date' max day. Then the given Int needs to be
--- greater than 0 and less than the max day for the given year && month.
--- ( 1 ≥ day ≥ maxValidDay )

> dayFromInt (Year 2018) Dec 25
> Just (Day 25) : Maybe Day
>
> dayFromInt (Year 2019) Feb 29
> Nothing : Maybe Day
>
> dayFromInt (Year 2020) Feb 29
> Just (Day 29) : Maybe Day

-- Internal, not to be exposed

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


{-| Construct a `Date` from its constituent parts.
--- Returns `Nothing` if the combination would form an invalid date.

> fromYearMonthDay (Year 2018) Dec (Day 25)
> Just (Date { year = (Year 2018), month = Dec, day = (Day 25)})
>
> fromYearMonthDay (Year 2019) Feb (Day 29)
> Nothing
>
> fromYearMonthDay (Year 2020) Feb (Day 29)
> Just (Date { day = Day 29, month = Feb, year = Year 2020 }) : Maybe Date

-- Internal, not to be exposed

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


{-| Comparison on a Date level.
--- Compares two given dates and gives an Order

> date = (fromPosix (Time.millisToPosix 0)) -- 1 Jan 1970
> laterDate = (fromPosix (Time.millisToPosix 10000000000)) -- 26 Apr 1970

> compareDates date laterDate
> LT : Order
>
> compareDates laterDate date
> GT : Order
>
> compareDates laterDate date
> EQ : Order

-- Can be exposed

-}
compareDates : Date -> Date -> Order
compareDates lhs rhs =
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


{-| Comparison on a Day level.
--- Compares two given days and gives an Order

> compareDays (Day 28) (Day 29)
> LT : Order
>
> compareDays (Day 28) (Day 15)
> GT : Order
>
> compareDays (Day 15) (Day 15)
> EQ : Order

-- Internal, not to be exposed

-}
compareDays : Day -> Day -> Order
compareDays lhs rhs =
    Basics.compare (dayToInt lhs) (dayToInt rhs)


{-| Comparison on a Month level.
--- Compares two given months and gives an Order

> compareMonths Jan Feb
> LT : Order
>
> compareMonths Dec Feb
> GT : Order
>
> compareMonths Aug Aug
> EQ : Order

-- Internal, not to be exposed

-}
compareMonths : Month -> Month -> Order
compareMonths lhs rhs =
    Basics.compare (monthToInt lhs) (monthToInt rhs)


{-| Comparison on a Year level.
--- Compares two given years and gives an Order

> compareYears 2016 2017
> LT : Order
>
> compareYears 2017 2016
> GT : Order
>
> compareYears 2015 2015
> EQ : Order

-- Internal, not to be exposed

-}
compareYears : Year -> Year -> Order
compareYears lhs rhs =
    Basics.compare (yearToInt lhs) (yearToInt rhs)


{-| Construct a `Date` from its (raw) constituent parts.
Returns `Nothing` if any parts or their combination would form an invalid date.

> fromRawYearMonthDay { rawDay = 11, rawMonth = 12, rawYear = 2018 }
> Just (Date { day = Day 11, month = Dec, year = Year 2018 }) : Maybe Date
>
> fromRawYearMonthDay { rawDay = 29, rawMonth = 2, rawYear = 2019 }
> Nothing : Maybe Date
>
> fromRawYearMonthDay { rawDay = 29, rawMonth = 2, rawYear = 2020 }
> Just (Date { day = Day 11, month = Feb, year = Year 2020 }) : Maybe Date

-- Can be exposed.

-}
fromRawYearMonthDay : RawDate -> Maybe Date
fromRawYearMonthDay { rawYear, rawMonth, rawDay } =
    yearFromInt rawYear
        |> Maybe.andThen
            (\y ->
                monthFromInt rawMonth
                    |> Maybe.andThen
                        (\m ->
                            fromRawDay y m rawDay
                        )
            )


{-| Construct a `Date` from its constituent Year and Month by using its raw day.
Returns `Nothing` if any parts or their combination would form an invalid date.

> fromRawDay (Year 2018) Dec 25
> Just (Date { day = Day 25, month = Dec, year = Year 2018 }) : Maybe Date
>
> fromRawDay (Year 2019) Feb 29
> Nothing : Maybe Date
>
> fromRawDay (Year 2020) Feb 29
> Just (Date { day = Day 11, month = Feb, year = Year 2020 }) : Maybe Date

-- Internal, not to be exposed

-}
fromRawDay : Year -> Month -> Int -> Maybe Date
fromRawDay year month rawDay =
    dayFromInt year month rawDay
        |> Maybe.andThen (fromYearMonthDay year month)


{-| Construct a `Date` from its constituent Year and Month by using its raw day.
Returns `Nothing` if any parts or their combination would form an invalid date.

> fromRawDay (Year 2018) Dec 25
> Just (Date { day = Day 25, month = Dec, year = Year 2018 }) : Maybe Date
>
> fromRawDay (Year 2019) Feb 29
> Nothing : Maybe Date
>
> fromRawDay (Year 2020) Feb 29
> Just (Date { day = Day 11, month = Feb, year = Year 2020 }) : Maybe Date

-- Internal, not to be exposed

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


{-| Gets next month from the given date. It preserves the day and year as is (where applicable).
--- If the day of the given date is out of bounds for the next month
--- then we return the maxDay for that month.

> date = fromRawYearMonthDay { rawDay = 31, rawMonth = 12 rawYear = 2018 }
>
> getNextMonth date
> Date { day = Day 31, rawMonth = 1, rawYear = 2019 } : Date
>
> getNextMonth (getNextMonth date)
> Date { day = Day 28, rawMonth = 28, rawYear = 2019 } : Date

-- Can Be Exposed

-}
getNextMonth : Date -> Date
getNextMonth (Date date) =
    let
        updatedMonth =
            getNextMonth_ date.month

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

> getNextMonth\_ Dec
> Jan : Month
>
> getNextMonth\_ Nov
> Dec : Month

-- Internal, not to be exposed

-}
getNextMonth_ : Month -> Month
getNextMonth_ month =
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


{-| Gets previous month from the given date. It preserves the day and year as is (where applicable).
--- If the day of the given date is out of bounds for the previous month then
--- we return the maxDay for that month.

> date = fromRawYearMonthDay { rawDay = 31, rawMonth = 1 rawYear = 2019 }
>
> getPreviousMonth date
> Date { day = Day 31, rawMonth = 12, rawYear = 2018 } : Date
>
> getNextMonth (getNextMonth date)
> Date { day = Day 30, rawMonth = 11, rawYear = 2018 } : Date

-- Can Be Exposed

-}
getPreviousMonth : Date -> Date
getPreviousMonth (Date date) =
    let
        updatedMonth =
            getPreviousMonth_ date.month

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

> getNextMonth\_ Jan
> Dec : Month
>
> getNextMonth\_ Dec
> Nov : Month

-- Internal, not to be exposed

-}
getPreviousMonth_ : Month -> Month
getPreviousMonth_ month =
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


{-| Gets the list of the preceding months from the given month.
--- It doesn't include the given month in the resulting list.

> getPrecedingMonths Aug
> [ Jan, Feb, Mar, Apr, May, Jun, Jul ]
>
> getPrecedingMonths Jan
> []

-- Internal, not to be exposed

-}
getPrecedingMonths : Month -> List Month
getPrecedingMonths month =
    Array.toList <|
        Array.slice 0 (monthToInt month - 1) months


{-| Gets the list of the following months from the given month.
--- It doesn't include the given month in the resulting list.

> getFollowingMonths Aug
> [ Sep, Oct, Nov, Dec ]
>
> getFollowingMonths Dec
> []

-- Internal, not to be exposed

-}
getFollowingMonths : Month -> List Month
getFollowingMonths month =
    Array.toList <|
        Array.slice (monthToInt month) 12 months


{-| Get a UTC `Date` from a time zone and posix time.

> fromPosix (Time.millisToPosix 0)
> Date { day = Day 1, month = Jan, year = Year 1970 } : Date

-- Can Be Exposed

-}
fromPosix : Time.Posix -> Date
fromPosix posix =
    Date
        { year = Year (Time.toYear Time.utc posix)
        , month = Time.toMonth Time.utc posix
        , day = Day (Time.toDay Time.utc posix)
        }


{-| Checks if the given year is a leap year.

> isLeapYear 2019
> False
>
> isLeapYear 2020
> True

-- Can Be Exposed

-}
isLeapYear : Year -> Bool
isLeapYear (Year int) =
    (modBy 4 int == 0) && ((modBy 400 int == 0) || not (modBy 100 int == 0))


{-| Get the last day of the given `Year` and `Month`.

> lastDayOf (Year 2018) Dec
> 31
>
> lastDayOf (Year 2019) Feb
> 28
>
> lastDayOf (Year 2020) Feb
> 29

-- Can be exposed

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


{-| Increments the 'Year' in a given 'Date' while preserving the month and
--- day where applicable.

> date = fromRawYearMonthDay { rawDay = 31, rawMonth = 1 rawYear = 2019 }
> incrementYear date
> Date { day = Day 31, month = Jan, year = Year 2020 }
>
> date2 = fromRawYearMonthDay { rawDay = 29, rawMonth = 2, rawYear 2020 }
> incrementYear date2
> Date { day = Day 28, month = Feb, year = Year 2021 }
>
> date3 = fromRawYearMonthDay { rawDay = 28, rawMonth = 2, rawYear 2019 }
> incrementYear date3
> Date { day = Day 28, month = Feb, year = Year 2020 }

-- Can be exposed

--------------------- Note ---------------------
--- Here we cannot rely on transforming the date
--- to millis and adding a year because of the
--- edge case restrictions such as current year
--- might be a leap year and the given date may
--- contain the 29th of February but on the next
--- year, February would only have 28 days.

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


{-| Decrements the 'Year' in a given 'Date' while preserving the month and
--- day where applicable.

> date = fromRawYearMonthDay { rawDay = 31, rawMonth = 1 rawYear = 2019 }
> decrementYear date
> Date { day = Day 31, month = Jan, year = Year 2018 }
>
> date2 = fromRawYearMonthDay { rawDay = 29, rawMonth = 2, rawYear 2020 }
> decrementYear date2
> Date { day = Day 28, month = Feb, year = Year 2019 }
>
> date3 = fromRawYearMonthDay { rawDay = 28, rawMonth = 2, rawYear 2019 }
> decrementYear date3
> Date { day = Day 28, month = Feb, year = Year 2018 }

-- Can be exposed

--------------------- Note ---------------------
--- Here we cannot rely on transforming the date
--- to millis and removing a year because of the
--- edge case restrictions such as current year
--- might be a leap year and the given date may
--- contain the 29th of February but on the previous
--- year, February would only have 28 days.

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


{-| Transforms a 'Date' to a Posix time.

-- Can be exposed

-}
toPosix : Date -> Time.Posix
toPosix =
    Time.millisToPosix << toMillis


{-| Transforms a 'Date' into milliseconds
-}
toMillis : Date -> Int
toMillis (Date { year, month, day }) =
    millisSinceEpoch year
        + millisSinceStartOfTheYear year month
        + millisSinceStartOfTheMonth day


{-| Returns the milliseconds in a day.
-}
millisInADay : Int
millisInADay =
    1000 * 60 * 60 * 24


{-| Returns the milliseconds in a year.

-- Internal, not to be exposed

-}
millisInYear : Year -> Int
millisInYear year =
    if isLeapYear year then
        1000 * 60 * 60 * 24 * 366

    else
        1000 * 60 * 60 * 24 * 365


{-| Returns the year milliseconds since epoch.
--- This function is intended to be used along with millisSinceStartOfTheYear
--- and millisSinceStartOfTheMonth.

> millisSinceEpoch (Year 1970)
> 0
>
> millisSinceEpoch (Year 1971)
> 31536000000

-- Internal, not to be exposed

-}
millisSinceEpoch : Year -> Int
millisSinceEpoch (Year year) =
    let
        -- year - 1 because we want the milliseconds
        -- in the start of the target year in order to add
        -- the months + days + hours + minues + secs if we want to.
        years_ =
            List.range 1970 (year - 1)
    in
    List.foldl
        (\y result ->
            let
                yearMillis =
                    Maybe.withDefault 0 <|
                        Maybe.map millisInYear (yearFromInt y)
            in
            result + yearMillis
        )
        0
        years_


{-| Returns the month milliseconds since the start of a given year.
--- This function is intended to be used along with millisSinceEpoch
--- and millisSinceStartOfTheMonth.

> millisSinceStartOfTheYear (Year 2018) Time.Jan
> 0 : Int
>
> millisSinceStartOfTheYear (Year 2018) Time.Dec
> 28857600000 : Int

-- Internal, not to be exposed

-}
millisSinceStartOfTheYear : Year -> Month -> Int
millisSinceStartOfTheYear year month =
    List.foldl
        (\m res ->
            res + (millisInADay * dayToInt (lastDayOf year m))
        )
        0
        (getPrecedingMonths month)


{-| Returns the day milliseconds since the start of a given month.
--- This function is intended to be used along with millisSinceEpoch
--- and millisSinceStartOfTheYear.

> millisSinceStartOfTheMonth (Day 1)
> 0 : Int
>
> millisSinceStartOfTheMonth (Day 15)
> 1209600000 : Int

-- Internal, not to be exposed

-}
millisSinceStartOfTheMonth : Day -> Int
millisSinceStartOfTheMonth day =
    -- -1 on the day because we are currently on that day and it hasn't passed yet.
    -- We also need time in order to construct the full posix.
    millisInADay * (dayToInt day - 1)


{-| Returns the weekday of a specific 'Date'

> date = fromRawYearMonthDay { rawDay = 29, rawMonth = 2, rawYear = 2020 }
> weekdayFromDate date
> Sat : Time.Weekday
>
> date2 = fromRawYearMonthDay { rawDay = 25, rawMonth = 11, rawYear = 2018 }
> weekdayFromDate date2
> Tue : Time.Weekday

-- Can be exposed

-}
weekdayFromDate : Date -> Time.Weekday
weekdayFromDate date =
    Time.toWeekday Time.utc (toPosix date)


{-| Returns a list of 'Dates' for the given 'Year' and 'Month' combination.

> getDatesInMonth (Year 2018) Dec
> [ Date { day = Day 1, month = Dec, year = Year 2018 }
> , Date { day = Day 2, month = Dec, year = Year 2018 }
> , Date { day = Day 3, month = Dec, year = Year 2018 }
> , Date { day = Day 4, month = Dec, year = Year 2018 }
> , Date { day = Day 5, month = Dec, year = Year 2018 }
> ...
> , Date { day = Day 29, month = Dec, year = Year 2018 }
> , Date { day = Day 30, month = Dec, year = Year 2018 }
> , Date { day = Day 31, month = Dec, year = Year 2018 }
> ]

-- Can be exposed

-}
getDatesInMonth : Year -> Month -> List Date
getDatesInMonth year month =
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


{-| Increments the 'Day' in a given 'Date'. Will also increment 'Month' && 'Year'
--- if applicable.

> date = fromRawYearMonthDay { rawDay = 31, rawMonth = 12, rawYear = 2018 }
> getNextDay date
> Date { day = Day 1, month = Jan, year = Year 2019 }
>
> date2 = fromRawYearMonthDay { rawDay = 29, rawMonth = 2, rawYear 2020 }
> getNextDay date2
> Date { day = Day 1, month = Mar, year = Year 2020 }
>
> date3 = fromRawYearMonthDay { rawDay = 24, rawMonth = 12, rawYear 2018 }
> getNextDay date3
> Date { day = Day 25, month = Dec, year = Year 2018 }

-- Can be exposed

--------------------- Note ---------------------
--- Its safe to get the next day by using milliseconds
--- here because we are responsible for transforming the
--- given date to millis and parsing it from millis.
--- The getNextYear + getNextMonth are totally different
--- and they both have respectively different edge cases
--- and implementations.

-}
getNextDay : Date -> Date
getNextDay date =
    let
        millis =
            Time.posixToMillis (toPosix date) + millisInADay

        newDate =
            fromPosix (Time.millisToPosix millis)
    in
    newDate


{-| Decrements the 'Day' in a given 'Date'. Will also decrement 'Month' && 'Year'
--- if applicable.

> date = fromRawYearMonthDay { rawDay = 1, rawMonth = 1, rawYear = 2019 }
> getPreviousDay date
> Date { day = Day 31, month = Dec, year = Year 2018 }
>
> date2 = fromRawYearMonthDay { rawDay = 1, rawMonth = 3, rawYear 2020 }
> getPreviousDay date2
> Date { day = Day 29, month = Feb, year = Year 2020 }
>
> date3 = fromRawYearMonthDay { rawDay = 26, rawMonth = 12, rawYear 2018 }
> getPreviousDay date3
> Date { day = Day 25, month = Dec, year = Year 2018 }

-- Can be exposed

--------------------- Note ---------------------
--- Its safe to get the previous day by using milliseconds
--- here because we are responsible for transforming the
--- given date to millis and parsing it from millis.
--- The getNextYear + getNextMonth are totally different
--- and they both have respectively different edge cases
--- and implementations.

-}
getPreviousDay : Date -> Date
getPreviousDay date =
    let
        millis =
            Time.posixToMillis (toPosix date) - millisInADay

        newDate =
            fromPosix (Time.millisToPosix millis)
    in
    newDate


{-| Returns a List of dates based on the start and end 'Dates' given as parameters.
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

-- Can be exposed

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

-- Internal, not to be exposed

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
                , getNextDay prevDate
                )
        in
        getDateRange_ updatedDaysCount updatedPrevDate updatedRes

    else
        updatedRes
