module DateTime.Calendar.Internal exposing
    ( Date(..)
    , Day(..)
    , InternalDate
    , Month
    , RawDate
    , Year(..)
    , compare
    , compareDays
    , compareMonths
    , compareYears
    , dayFromInt
    , dayToInt
    , decrementDay
    , decrementMonth
    , decrementMonth_
    , decrementYear
    , fromPosix
    , fromRawDay
    , fromRawParts
    , fromYearMonthDay
    , getDateRange
    , getDateRange_
    , getDatesInMonth
    , getDay
    , getDayDiff
    , getFollowingMonths
    , getMonth
    , getPrecedingMonths
    , getWeekday
    , getYear
    , incrementDay
    , incrementMonth
    , incrementMonth_
    , incrementYear
    , isLeapYear
    , lastDayOf
    , millisInADay
    , millisInYear
    , millisSinceEpoch
    , millisSinceStartOfTheMonth
    , millisSinceStartOfTheYear
    , monthToInt
    , months
    , setDay
    , setMonth
    , setYear
    , toMillis
    , toPosix
    , yearFromInt
    , yearToInt
    )

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
    { year : Int
    , month : Time.Month
    , day : Int
    }



-- Constructors


{-| Get a UTC `Date` from a time zone and posix time.

> fromPosix (Time.millisToPosix 0)
> Date { day = Day 1, month = Jan, year = Year 1970 } : Date

-}
fromPosix : Time.Posix -> Date
fromPosix posix =
    Date
        { year = Year (Time.toYear Time.utc posix)
        , month = Time.toMonth Time.utc posix
        , day = Day (Time.toDay Time.utc posix)
        }


{-| Construct a `Date` from its (raw) constituent parts.
Returns `Nothing` if any parts or their combination would form an invalid date.

> fromRawParts { day = 11, month = Dec, year = 2018 }
> Just (Date { day = Day 11, month = Dec, year = Year 2018 }) : Maybe Date
>
> fromRawParts { day = 29, month = Feb, year = 2019 }
> Nothing : Maybe Date
>
> fromRawParts { day = 29, month = Feb, year = 2020 }
> Just (Date { day = Day 29, month = Feb, year = Year 2020 }) : Maybe Date

-}
fromRawParts : RawDate -> Maybe Date
fromRawParts { year, month, day } =
    yearFromInt year
        |> Maybe.andThen
            (\y ->
                fromRawDay y month day
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

-}
fromRawDay : Year -> Month -> Int -> Maybe Date
fromRawDay year month day =
    dayFromInt year month day
        |> Maybe.andThen (fromYearMonthDay year month)


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


{-| Attempt to construct a 'Year' from an Int value.
--- Currently the validity of the year is based on
--- the integer being greater than zero. ( year > 0 )

> yearFromInt 1970
> Just (Year 1970) : Maybe Year
>
> yearFromInt -1
> Nothing : Maybe Year

-}
yearFromInt : Int -> Maybe Year
yearFromInt year =
    if year > 0 then
        Just (Year year)

    else
        Nothing


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



-- Converters


{-| Transforms a 'Date' to a Posix time.
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


{-| Extract the Int value of a 'Year'.

> date = fromPosix (Time.millisToPosix 0)
> yearToInt (getYear date)
> 1970 : Int

-}
yearToInt : Year -> Int
yearToInt (Year year) =
    year


{-| Convert a given month to an integer starting from 1.

> monthToInt Jan
> 1 : Int
>
> monthToInt Aug
> 8 : Int

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

> date = fromPosix (Time.millisToPosix 0)
> dayToInt (getDay date)
> 1 : Int

-}
dayToInt : Day -> Int
dayToInt (Day day) =
    day



-- Accessors


{-| Extract the `Year` part of a `Date`.

> getYear (fromPosix (Time.millisToPosix 0))
> Year 1970 : Year

-}
getYear : Date -> Year
getYear (Date { year }) =
    year


{-| Extract the `Month` part of a `Date`.

> getMonth (fromPosix (Time.millisToPosix 0))
> Jan : Month

-}
getMonth : Date -> Month
getMonth (Date { month }) =
    month


{-| Extract the `Day` part of a `Date`.

> getDay (fromPosix (Time.millisToPosix 0))
> Day 1 : Day

-}
getDay : Date -> Day
getDay (Date date) =
    date.day



-- Setters


{-| Attempts to set the 'Year' on an existing date
-}
setYear : Date -> Int -> Maybe Date
setYear date year =
    fromRawParts
        { year = year
        , month = getMonth date
        , day = dayToInt (getDay date)
        }


{-| Attempts to set the 'Month' on an existing date
-}
setMonth : Date -> Month -> Maybe Date
setMonth date month =
    fromRawParts
        { year = yearToInt (getYear date)
        , month = month
        , day = dayToInt (getDay date)
        }


{-| Attempts to set the 'Day' on an existing date
-}
setDay : Date -> Int -> Maybe Date
setDay date day =
    fromRawParts
        { year = yearToInt (getYear date)
        , month = getMonth date
        , day = day
        }



-- Incrementers


{-| Increments the 'Year' in a given 'Date' while preserving the month and
--- day where applicable.

> date = fromRawParts { day = 31, month = Jan, year = 2019 }
> incrementYear date
> Date { day = Day 31, month = Jan, year = Year 2020 }
>
> date2 = fromRawParts { day = 29, month = Feb, year 2020 }
> incrementYear date2
> Date { day = Day 28, month = Feb, year = Year 2021 }
>
> date3 = fromRawParts { day = 28, month = Feb, year 2019 }
> incrementYear date3
> Date { day = Day 28, month = Feb, year = Year 2020 }

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


{-| Gets next month from the given date. It preserves the day and year as is (where applicable).
--- If the day of the given date is out of bounds for the next month
--- then we return the maxDay for that month.

> date = fromRawParts { day = 31, month = Dec, year = 2018 }
>
> incrementMonth date
> Date { day = Day 31, month = Jan, year = 2019 } : Date
>
> incrementMonth (incrementMonth date)
> Date { day = Day 28, month = Feb, year = 2019 } : Date

-}
incrementMonth : Date -> Date
incrementMonth (Date date) =
    let
        updatedMonth =
            incrementMonth_ date.month

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

> incrementMonth\_ Dec
> Jan : Month
>
> incrementMonth\_ Nov
> Dec : Month

-}
incrementMonth_ : Month -> Month
incrementMonth_ month =
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


{-| Increments the 'Day' in a given 'Date'. Will also increment 'Month' && 'Year'
--- if applicable.

> date = fromRawParts { day = 31, month = Dec, year = 2018 }
> incrementDay date
> Date { day = Day 1, month = Jan, year = Year 2019 }
>
> date2 = fromRawParts { day = 29, month = Feb, year 2020 }
> incrementDay date2
> Date { day = Day 1, month = Mar, year = Year 2020 }
>
> date3 = fromRawParts { day = 24, month = Dec, year 2018 }
> incrementDay date3
> Date { day = Day 25, month = Dec, year = Year 2018 }

--------------------- Note ---------------------
--- Its safe to get the next day by using milliseconds
--- here because we are responsible for transforming the
--- given date to millis and parsing it from millis.
--- The incrementYear + incrementMonth are totally different
--- and they both have respectively different edge cases
--- and implementations.

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



-- Decrementers


{-| Decrements the 'Year' in a given 'Date' while preserving the month and
--- day where applicable.

> date = fromRawParts { day = 31, month = Jan, year = 2019 }
> decrementYear date
> Date { day = Day 31, month = Jan, year = Year 2018 }
>
> date2 = fromRawParts { day = 29, month = Feb, year 2020 }
> decrementYear date2
> Date { day = Day 28, month = Feb, year = Year 2019 }
>
> date3 = fromRawParts { day = 28, month = Feb, year 2019 }
> decrementYear date3
> Date { day = Day 28, month = Feb, year = Year 2018 }

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


{-| Gets previous month from the given date. It preserves the day and year as is (where applicable).
--- If the day of the given date is out of bounds for the previous month then
--- we return the maxDay for that month.

> date = fromRawParts { day = 31, month = Jan, year = 2019 }
>
> decrementMonth date
> Date { day = Day 31, month = Dec, year = 2018 } : Date
>
> decrementMonth (decrementMonth date)
> Date { day = Day 30, month = Nov, year = 2018 } : Date

-}
decrementMonth : Date -> Date
decrementMonth (Date date) =
    let
        updatedMonth =
            decrementMonth_ date.month

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

> decrementMonth\_ Jan
> Dec : Month
>
> decrementMonth\_ Dec
> Nov : Month

-}
decrementMonth_ : Month -> Month
decrementMonth_ month =
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


{-| Decrements the 'Day' in a given 'Date'. Will also decrement 'Month' && 'Year'
--- if applicable.

> date = fromRawParts { day = 1, month = Jan, year = 2019 }
> decrementDay date
> Date { day = Day 31, month = Dec, year = Year 2018 }
>
> date2 = fromRawParts { day = 1, month = Mar, year 2020 }
> decrementDay date2
> Date { day = Day 29, month = Feb, year = Year 2020 }
>
> date3 = fromRawParts { day = 26, month = Dec, year 2018 }
> decrementDay date3
> Date { day = Day 25, month = Dec, year = Year 2018 }

--------------------- Note ---------------------
--- Its safe to get the previous day by using milliseconds
--- here because we are responsible for transforming the
--- given date to millis and parsing it from millis.
--- The decrementYear + decrementMonth are totally different
--- and they both have respectively different edge cases
--- and implementations.

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



-- Comparers


{-| Comparison on a Date level.
--- Compares two given dates and gives an Order

> date = (fromPosix (Time.millisToPosix 0)) -- 1 Jan 1970
> laterDate = (fromPosix (Time.millisToPosix 10000000000)) -- 26 Apr 1970

> compare date laterDate
> LT : Order
>
> compare laterDate date
> GT : Order
>
> compare laterDate date
> EQ : Order

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

-}
compareYears : Year -> Year -> Order
compareYears lhs rhs =
    Basics.compare (yearToInt lhs) (yearToInt rhs)


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

-}
compareMonths : Month -> Month -> Order
compareMonths lhs rhs =
    Basics.compare (monthToInt lhs) (monthToInt rhs)


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

-}
compareDays : Day -> Day -> Order
compareDays lhs rhs =
    Basics.compare (dayToInt lhs) (dayToInt rhs)



-- Utilities


{-| Returns a List of dates based on the start and end 'Dates' given as parameters.
--- The resulting list includes both the start and end 'Dates'.
--- In the case of startDate > endDate the resulting list would still be
--- a valid sorted date range list.

> startDate = fromRawParts { day = 25, month = Feb, year = 2020 }
> endDate = fromRawParts { day = 1, month = Mar, year = 2020 }
> getDateRange startDate endDate
> [ Date { day = Day 25, month = Feb, year = Year 2020 }
> , Date { day = Day 26, month = Feb, year = Year 2020 }
> , Date { day = Day 27, month = Feb, year = Year 2020 }
> , Date { day = Day 28, month = Feb, year = Year 2020 }
> , Date { day = Day 29, month = Feb, year = Year 2020 }
> , Date { day = Day 1, month = Mar, year = Year 2020 }
> ]
>
> startDate2 = fromRawParts { day = 25, month = Feb, year = 2019 }
> endDate2 = fromRawParts { day = 1, month = Mar, year = 2019 }
> getDateRange startDate2 endDate2
> [ Date { day = Day 25, month = Feb, year = Year 2019 }
> , Date { day = Day 26, month = Feb, year = Year 2019 }
> , Date { day = Day 27, month = Feb, year = Year 2019 }
> , Date { day = Day 28, month = Feb, year = Year 2019 }
> , Date { day = Day 1, month = Mar, year = Year 2019 }
> ]

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


{-| Returns the number of days between two 'Dates'.
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


{-| Gets the list of the following months from the given month.
--- It doesn't include the given month in the resulting list.

> getFollowingMonths Aug
> [ Sep, Oct, Nov, Dec ]
>
> getFollowingMonths Dec
> []

-}
getFollowingMonths : Month -> List Month
getFollowingMonths month =
    Array.toList <|
        Array.slice (monthToInt month) 12 months


{-| Gets the list of the preceding months from the given month.
--- It doesn't include the given month in the resulting list.

> getPrecedingMonths Aug
> [ Jan, Feb, Mar, Apr, May, Jun, Jul ]
>
> getPrecedingMonths Jan
> []

-}
getPrecedingMonths : Month -> List Month
getPrecedingMonths month =
    Array.toList <|
        Array.slice 0 (monthToInt month - 1) months


{-| Returns the weekday of a specific 'Date'

> date = fromRawParts { day = 29, month = Feb, year = 2020 }
> getWeekday date
> Sat : Time.Weekday
>
> date2 = fromRawParts { day = 25, month = Nov, year = 2018 }
> getWeekday date2
> Tue : Time.Weekday

-}
getWeekday : Date -> Time.Weekday
getWeekday date =
    Time.toWeekday Time.utc (toPosix date)


{-| Checks if the given year is a leap year.

> isLeapYear 2019
> False
>
> isLeapYear 2020
> True

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


{-| Returns the year milliseconds since epoch.
--- This function is intended to be used along with millisSinceStartOfTheYear
--- and millisSinceStartOfTheMonth.

> millisSinceEpoch (Year 1970)
> 0
>
> millisSinceEpoch (Year 1971)
> 31536000000

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



-- Constants


{-| Returns a list of all the Months in Calendar order.
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
