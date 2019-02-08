module Tests.DateTime exposing (suite)

import DateTime.Calendar.Internal as Calendar
import DateTime.Clock.Internal as Clock
import DateTime.DateTime.Internal as DateTime
import Expect exposing (Expectation)
import Test exposing (Test, describe, test)
import Time exposing (Month(..), Weekday(..))


testDateMillis : Int
testDateMillis =
    1543276800000


millisInAnHour : Int
millisInAnHour =
    1000 * 60 * 60


millisInAMinute : Int
millisInAMinute =
    1000 * 60


millisInASecond : Int
millisInASecond =
    1000


midnightRawParts : Clock.RawTime
midnightRawParts =
    { hours = 0, minutes = 0, seconds = 0, milliseconds = 0 }


suite : Test
suite =
    describe "DateTime Test Suite"
        [ fromPosixTests
        , fromRawPartsTests

        -- , fromDateAndTimeTests -- There is nothing to test here.
        , toPosixTests

        -- , toMillisTests -- Its already tested within the toPosixTests.
        --
        -- , getDateTests -- There is nothing to test here.
        -- , getTimeTests -- There is nothing to test here.
        -- , getDayTests -- There is nothing to test here.
        -- , getMonthTests -- There is nothing to test here.
        -- , getYearTests -- There is nothing to test here.
        -- , getHoursTests -- There is nothing to test here.
        -- , getMinutesTests -- There is nothing to test here.
        -- , getSecondsTests -- There is nothing to test here.
        -- , getMillisecondsTests -- There is nothing to test here.
        --
        , setYearTests
        , setMonthTests
        , setDayTests
        , setHoursTests
        , setMinutesTests
        , setSecondsTests
        , setMillisecondsTests

        --
        -- , incrementYearTests -- TODO
        -- , incrementMonthTests -- TODO
        -- , incrementDayTests -- TODO
        -- , incrementHoursTests -- TODO
        -- , incrementMinutesTests -- TODO
        -- , incrementSecondsTests -- TODO
        -- , incrementMillisecondsTests -- TODO
        --
        -- , decrementYearTests -- TODO
        -- , decrementMonthTests -- TODO
        -- , decrementDayTests -- TODO
        -- , decrementHoursTests -- TODO
        -- , decrementMinutesTests -- TODO
        -- , decrementSecondsTests -- TODO
        -- , decrementMillisecondsTests -- TODO
        --
        -- , compareTests -- TODO
        -- , compareDatesTests -- TODO
        -- , compareTimeTests -- TODO
        -- , getWeekdayTests -- TODO
        -- , getDatesInMonthTests -- TODO
        -- , getDateRangeTests -- TODO
        --
        , sortTests
        ]


fromPosixTests : Test
fromPosixTests =
    let
        date =
            -- This timestamp is equivalent to Fri Dec 21 2018 15:45:30.000 GMT+0000
            DateTime.fromPosix (Time.millisToPosix 1545407130000)

        negativeDate =
            -- This timestamp is equivalent to Sat Aug 26 1950 00:00:00.000 GMT+0000
            DateTime.fromPosix (Time.millisToPosix -610675200000)
    in
    describe "DateTime.fromPosix Test Suite"
        [ test "Year validation"
            (\_ ->
                Expect.equal 2018 (DateTime.getYear date)
            )
        , test "Month validation"
            (\_ ->
                Expect.equal Dec (DateTime.getMonth date)
            )
        , test "Day validation"
            (\_ ->
                Expect.equal 21 (DateTime.getDay date)
            )
        , test "Weekday validation"
            (\_ ->
                Expect.equal Fri (DateTime.getWeekday date)
            )
        , test "Hours validation"
            (\_ ->
                Expect.equal 15 (DateTime.getHours date)
            )
        , test "Minutes validation"
            (\_ ->
                Expect.equal 45 (DateTime.getMinutes date)
            )
        , test "Seconds validation"
            (\_ ->
                Expect.equal 30 (DateTime.getSeconds date)
            )
        , test "Milliseconds validation"
            (\_ ->
                Expect.equal 0 (DateTime.getMilliseconds date)
            )
        , test "Milliseconds second validation"
            (\_ ->
                let
                    date_ =
                        DateTime.fromPosix (Time.millisToPosix (1545407130000 + 500))
                in
                Expect.equal 500 (DateTime.getMilliseconds date_)
            )
        , test "Negative timestamp Year validation"
            (\_ ->
                Expect.equal 1950 (DateTime.getYear negativeDate)
            )
        , test "Negative timestamp Month validation"
            (\_ ->
                Expect.equal Aug (DateTime.getMonth negativeDate)
            )
        , test "Negative timestamp Day validation"
            (\_ ->
                Expect.equal 26 (DateTime.getDay negativeDate)
            )
        , test "Negative timestamp Weekday validation"
            (\_ ->
                Expect.equal Sat (DateTime.getWeekday negativeDate)
            )
        , test "Negative timestamp Hours validation"
            (\_ ->
                Expect.equal 0 (DateTime.getHours negativeDate)
            )
        , test "Negative timestamp Minutes validation"
            (\_ ->
                Expect.equal 0 (DateTime.getMinutes negativeDate)
            )
        , test "Negative timestamp Seconds validation"
            (\_ ->
                Expect.equal 0 (DateTime.getSeconds negativeDate)
            )
        , test "Negative timestamp Milliseconds validation"
            (\_ ->
                Expect.equal 0 (DateTime.getMilliseconds negativeDate)
            )
        ]


fromRawPartsTests : Test
fromRawPartsTests =
    let
        date =
            -- This timestamp is equivalent to Sat Aug 26 2019 00:00:00.000 GMT+0000
            DateTime.fromPosix (Time.millisToPosix 1566777600000)
    in
    describe "DateTime.fromRawParts Test Suite"
        [ test "Valid DateTime construction from raw parts"
            (\_ ->
                Expect.equal (Just date) <|
                    DateTime.fromRawParts { year = 2019, month = Aug, day = 26 } midnightRawParts
            )
        , test "Invalid DateTime construction from invalid Year passed in raw parts"
            (\_ ->
                Expect.equal Nothing <|
                    DateTime.fromRawParts { year = 0, month = Nov, day = 27 } midnightRawParts
            )
        , test "Invalid DateTime construction from invalid Day passed in raw parts"
            (\_ ->
                Expect.equal Nothing <|
                    DateTime.fromRawParts { year = 2019, month = Nov, day = 31 } midnightRawParts
            )
        , test "Invalid DateTime construction from invalid Hours passed in raw parts"
            (\_ ->
                Expect.equal Nothing <|
                    DateTime.fromRawParts { year = 2019, month = Dec, day = 25 } { hours = 24, minutes = 0, seconds = 0, milliseconds = 0 }
            )
        , test "Invalid DateTime construction from invalid Minutes passed in raw parts"
            (\_ ->
                Expect.equal Nothing <|
                    DateTime.fromRawParts { year = 2019, month = Dec, day = 25 } { hours = 0, minutes = 60, seconds = 0, milliseconds = 0 }
            )
        , test "Invalid DateTime construction from invalid Seconds passed in raw parts"
            (\_ ->
                Expect.equal Nothing <|
                    DateTime.fromRawParts { year = 2019, month = Dec, day = 25 } { hours = 0, minutes = 0, seconds = 60, milliseconds = 0 }
            )
        , test "Invalid DateTime construction from invalid Milliseconds passed in raw parts"
            (\_ ->
                Expect.equal Nothing <|
                    DateTime.fromRawParts { year = 2019, month = Dec, day = 25 } { hours = 0, minutes = 0, seconds = 0, milliseconds = 1000 }
            )
        , test "Valid 29th of February date construction from raw components"
            (\_ ->
                Expect.notEqual Nothing <|
                    DateTime.fromRawParts { year = 2020, month = Feb, day = 29 } midnightRawParts
            )
        , test "Invalid 29th of February date construction from raw components"
            (\_ ->
                Expect.equal Nothing <|
                    DateTime.fromRawParts { year = 2019, month = Feb, day = 29 } midnightRawParts
            )
        ]


toPosixTests : Test
toPosixTests =
    let
        posix =
            -- This timestamp is equivalent to Sat Aug 26 2019 00:00:00.000 GMT+0000
            Time.millisToPosix 1566777600000

        negativePosix =
            -- This timestamp is equivalent to Sun May 9 1920 00:00:00.000 GMT+0000
            Time.millisToPosix -1566777600000
    in
    describe "DateTime.toPosix Test Suite"
        [ test "Test from raw parts conversion"
            (\_ ->
                Expect.equal (Just posix) <|
                    Maybe.map DateTime.toPosix <|
                        DateTime.fromRawParts { year = 2019, month = Aug, day = 26 } midnightRawParts
            )
        , test "Testing from raw parts conversion using a negative resulting date"
            (\_ ->
                Expect.equal (Just negativePosix) <|
                    Maybe.map DateTime.toPosix <|
                        DateTime.fromRawParts { year = 1920, month = May, day = 9 } midnightRawParts
            )
        , test "Testing fromPosix -> toPosix conversion"
            (\_ ->
                Expect.equal posix <|
                    DateTime.toPosix (DateTime.fromPosix posix)
            )
        , test "Testing fromPosix -> toPosix conversion using a negative resulting date"
            (\_ ->
                Expect.equal negativePosix <|
                    DateTime.toPosix (DateTime.fromPosix negativePosix)
            )
        ]


setYearTests : Test
setYearTests =
    let
        initialDate =
            DateTime.fromRawParts { year = 2020, month = Feb, day = 29 } midnightRawParts
    in
    describe "DateTime.setYear Test Suite"
        [ test "Testing for a valid date."
            (\_ ->
                Expect.equal
                    (DateTime.fromRawParts { year = 2024, month = Feb, day = 29 } midnightRawParts)
                    (Maybe.andThen (DateTime.setYear 2024) initialDate)
            )
        , test "Testing for an invalid date."
            (\_ ->
                Expect.equal Nothing <|
                    Maybe.andThen (DateTime.setYear 2019) initialDate
            )
        , test "Testing for a valid date but an invalid year."
            (\_ ->
                Expect.equal Nothing <|
                    Maybe.andThen (DateTime.setYear 0) initialDate
            )
        ]


setMonthTests : Test
setMonthTests =
    let
        initialDate =
            DateTime.fromRawParts { year = 2020, month = Jan, day = 31 } midnightRawParts
    in
    describe "DateTime.setMonth Test Suite"
        [ test "Testing for a valid month."
            (\_ ->
                Expect.equal
                    (DateTime.fromRawParts { year = 2020, month = Aug, day = 31 } midnightRawParts)
                    (Maybe.andThen (DateTime.setMonth Aug) initialDate)
            )
        , test "Testing for an invalid month."
            (\_ ->
                Expect.equal Nothing <|
                    Maybe.andThen (DateTime.setMonth Feb) initialDate
            )
        ]


setDayTests : Test
setDayTests =
    let
        initialDate =
            DateTime.fromRawParts { year = 2020, month = Feb, day = 28 } midnightRawParts
    in
    describe "DateTime.setDay Test Suite"
        [ test "Testing for a valid day."
            (\_ ->
                Expect.equal
                    (DateTime.fromRawParts { year = 2020, month = Feb, day = 29 } midnightRawParts)
                    (Maybe.andThen (DateTime.setDay 29) initialDate)
            )
        , test "Testing for an invalid day."
            (\_ ->
                Expect.equal Nothing <|
                    Maybe.andThen (DateTime.setDay 30) initialDate
            )
        ]


setHoursTests : Test
setHoursTests =
    let
        initial =
            DateTime.fromRawParts { year = 2020, month = Jan, day = 31 } { hours = 15, minutes = 0, seconds = 0, milliseconds = 0 }
    in
    describe "DateTime.setHours Test Suite"
        [ test "Testing a valid updating of hours."
            (\_ ->
                Expect.equal
                    (DateTime.fromRawParts { year = 2020, month = Jan, day = 31 } { hours = 23, minutes = 0, seconds = 0, milliseconds = 0 })
                    (Maybe.andThen (DateTime.setHours 23) initial)
            )
        , test "Testing an invalid updating of hours."
            (\_ ->
                Expect.equal Nothing <|
                    Maybe.andThen (DateTime.setHours 24) initial
            )
        ]


setMinutesTests : Test
setMinutesTests =
    let
        initial =
            DateTime.fromRawParts { year = 2020, month = Jan, day = 31 } { hours = 15, minutes = 0, seconds = 0, milliseconds = 0 }
    in
    describe "DateTime.setMinutes Test Suite"
        [ test "Testing a valid updating of minutes."
            (\_ ->
                Expect.equal
                    (DateTime.fromRawParts { year = 2020, month = Jan, day = 31 } { hours = 15, minutes = 30, seconds = 0, milliseconds = 0 })
                    (Maybe.andThen (DateTime.setMinutes 30) initial)
            )
        , test "Testing an invalid updating of minutes."
            (\_ ->
                Expect.equal Nothing <|
                    Maybe.andThen (DateTime.setMinutes 60) initial
            )
        ]


setSecondsTests : Test
setSecondsTests =
    let
        initial =
            DateTime.fromRawParts { year = 2020, month = Jan, day = 31 } { hours = 15, minutes = 0, seconds = 0, milliseconds = 0 }
    in
    describe "DateTime.setSeconds Test Suite"
        [ test "Testing a valid updating of seconds."
            (\_ ->
                Expect.equal
                    (DateTime.fromRawParts { year = 2020, month = Jan, day = 31 } { hours = 15, minutes = 0, seconds = 30, milliseconds = 0 })
                    (Maybe.andThen (DateTime.setSeconds 30) initial)
            )
        , test "Testing an invalid updating of seconds."
            (\_ ->
                Expect.equal Nothing <|
                    Maybe.andThen (DateTime.setSeconds 60) initial
            )
        ]


setMillisecondsTests : Test
setMillisecondsTests =
    let
        initial =
            DateTime.fromRawParts { year = 2020, month = Jan, day = 31 } { hours = 15, minutes = 0, seconds = 0, milliseconds = 0 }
    in
    describe "DateTime.setMilliseconds Test Suite"
        [ test "Testing a valid updating of seconds."
            (\_ ->
                Expect.equal
                    (DateTime.fromRawParts { year = 2020, month = Jan, day = 31 } { hours = 15, minutes = 0, seconds = 0, milliseconds = 500 })
                    (Maybe.andThen (DateTime.setMilliseconds 500) initial)
            )
        , test "Testing an invalid updating of seconds."
            (\_ ->
                Expect.equal Nothing <|
                    Maybe.andThen (DateTime.setMilliseconds 1000) initial
            )
        ]


sortTests : Test
sortTests =
    let
        defaultDateTime =
            DateTime.fromPosix (Time.millisToPosix 0)

        rawDate =
            { year = 2019, month = Aug, day = 26 }
    in
    describe "DateTime.sort Test Suite"
        [ test "Testing date sorting"
            (\_ ->
                let
                    dateTimeList =
                        List.map (Maybe.withDefault defaultDateTime)
                            [ DateTime.fromRawParts { year = 2019, month = Feb, day = 5 } midnightRawParts
                            , DateTime.fromRawParts { year = 1995, month = Jan, day = 26 } midnightRawParts
                            , DateTime.fromRawParts { year = 2017, month = Mar, day = 17 } midnightRawParts
                            , DateTime.fromRawParts { year = 1895, month = Feb, day = 20 } midnightRawParts
                            , DateTime.fromRawParts { year = 2018, month = Aug, day = 15 } midnightRawParts
                            , DateTime.fromRawParts { year = 1650, month = Feb, day = 10 } midnightRawParts
                            ]

                    sortedList =
                        List.map (Maybe.withDefault defaultDateTime)
                            [ DateTime.fromRawParts { year = 1650, month = Feb, day = 10 } midnightRawParts
                            , DateTime.fromRawParts { year = 1895, month = Feb, day = 20 } midnightRawParts
                            , DateTime.fromRawParts { year = 1995, month = Jan, day = 26 } midnightRawParts
                            , DateTime.fromRawParts { year = 2017, month = Mar, day = 17 } midnightRawParts
                            , DateTime.fromRawParts { year = 2018, month = Aug, day = 15 } midnightRawParts
                            , DateTime.fromRawParts { year = 2019, month = Feb, day = 5 } midnightRawParts
                            ]
                in
                Expect.equalLists sortedList (DateTime.sort dateTimeList)
            )
        , test "Testing time sorting"
            (\_ ->
                let
                    dateTimeList =
                        List.map (Maybe.withDefault defaultDateTime)
                            [ DateTime.fromRawParts rawDate { hours = 16, minutes = 15, seconds = 0, milliseconds = 0 }
                            , DateTime.fromRawParts rawDate { hours = 4, minutes = 35, seconds = 45, milliseconds = 0 }
                            , DateTime.fromRawParts rawDate { hours = 16, minutes = 15, seconds = 10, milliseconds = 0 }
                            , DateTime.fromRawParts rawDate { hours = 21, minutes = 20, seconds = 15, milliseconds = 0 }
                            , DateTime.fromRawParts rawDate { hours = 12, minutes = 15, seconds = 10, milliseconds = 150 }
                            , DateTime.fromRawParts rawDate { hours = 23, minutes = 59, seconds = 59, milliseconds = 0 }
                            , DateTime.fromRawParts rawDate { hours = 8, minutes = 59, seconds = 59, milliseconds = 999 }
                            , DateTime.fromRawParts rawDate { hours = 23, minutes = 59, seconds = 59, milliseconds = 250 }
                            , DateTime.fromRawParts rawDate { hours = 22, minutes = 30, seconds = 40, milliseconds = 500 }
                            , DateTime.fromRawParts rawDate { hours = 16, minutes = 15, seconds = 10, milliseconds = 150 }
                            ]

                    sortedList =
                        List.map (Maybe.withDefault defaultDateTime)
                            [ DateTime.fromRawParts rawDate { hours = 4, minutes = 35, seconds = 45, milliseconds = 0 }
                            , DateTime.fromRawParts rawDate { hours = 8, minutes = 59, seconds = 59, milliseconds = 999 }
                            , DateTime.fromRawParts rawDate { hours = 12, minutes = 15, seconds = 10, milliseconds = 150 }
                            , DateTime.fromRawParts rawDate { hours = 16, minutes = 15, seconds = 0, milliseconds = 0 }
                            , DateTime.fromRawParts rawDate { hours = 16, minutes = 15, seconds = 10, milliseconds = 0 }
                            , DateTime.fromRawParts rawDate { hours = 16, minutes = 15, seconds = 10, milliseconds = 150 }
                            , DateTime.fromRawParts rawDate { hours = 21, minutes = 20, seconds = 15, milliseconds = 0 }
                            , DateTime.fromRawParts rawDate { hours = 22, minutes = 30, seconds = 40, milliseconds = 500 }
                            , DateTime.fromRawParts rawDate { hours = 23, minutes = 59, seconds = 59, milliseconds = 0 }
                            , DateTime.fromRawParts rawDate { hours = 23, minutes = 59, seconds = 59, milliseconds = 250 }
                            ]
                in
                Expect.equalLists sortedList (DateTime.sort dateTimeList)
            )
        , test "Testing dateTime sorting"
            (\_ ->
                let
                    dateTimeList =
                        List.map (Maybe.withDefault defaultDateTime)
                            [ DateTime.fromRawParts { year = 2018, month = Aug, day = 15 } { hours = 16, minutes = 15, seconds = 0, milliseconds = 0 }
                            , DateTime.fromRawParts { year = 1895, month = Feb, day = 20 } { hours = 4, minutes = 35, seconds = 45, milliseconds = 0 }
                            , DateTime.fromRawParts { year = 1995, month = Jan, day = 26 } { hours = 16, minutes = 15, seconds = 10, milliseconds = 0 }
                            , DateTime.fromRawParts { year = 2017, month = Mar, day = 17 } { hours = 21, minutes = 20, seconds = 15, milliseconds = 0 }
                            , DateTime.fromRawParts { year = 2019, month = Feb, day = 5 } { hours = 12, minutes = 15, seconds = 10, milliseconds = 150 }
                            , DateTime.fromRawParts { year = 2017, month = Mar, day = 17 } { hours = 23, minutes = 59, seconds = 59, milliseconds = 0 }
                            , DateTime.fromRawParts { year = 1895, month = Feb, day = 20 } { hours = 8, minutes = 59, seconds = 59, milliseconds = 999 }
                            , DateTime.fromRawParts { year = 1650, month = Feb, day = 10 } { hours = 23, minutes = 59, seconds = 59, milliseconds = 250 }
                            , DateTime.fromRawParts { year = 2013, month = Jun, day = 13 } { hours = 22, minutes = 30, seconds = 40, milliseconds = 500 }
                            , DateTime.fromRawParts { year = 1995, month = Jan, day = 26 } { hours = 16, minutes = 15, seconds = 10, milliseconds = 150 }
                            ]

                    sortedList =
                        List.map (Maybe.withDefault defaultDateTime)
                            [ DateTime.fromRawParts { year = 1650, month = Feb, day = 10 } { hours = 23, minutes = 59, seconds = 59, milliseconds = 250 }
                            , DateTime.fromRawParts { year = 1895, month = Feb, day = 20 } { hours = 4, minutes = 35, seconds = 45, milliseconds = 0 }
                            , DateTime.fromRawParts { year = 1895, month = Feb, day = 20 } { hours = 8, minutes = 59, seconds = 59, milliseconds = 999 }
                            , DateTime.fromRawParts { year = 1995, month = Jan, day = 26 } { hours = 16, minutes = 15, seconds = 10, milliseconds = 0 }
                            , DateTime.fromRawParts { year = 1995, month = Jan, day = 26 } { hours = 16, minutes = 15, seconds = 10, milliseconds = 150 }
                            , DateTime.fromRawParts { year = 2013, month = Jun, day = 13 } { hours = 22, minutes = 30, seconds = 40, milliseconds = 500 }
                            , DateTime.fromRawParts { year = 2017, month = Mar, day = 17 } { hours = 21, minutes = 20, seconds = 15, milliseconds = 0 }
                            , DateTime.fromRawParts { year = 2017, month = Mar, day = 17 } { hours = 23, minutes = 59, seconds = 59, milliseconds = 0 }
                            , DateTime.fromRawParts { year = 2018, month = Aug, day = 15 } { hours = 16, minutes = 15, seconds = 0, milliseconds = 0 }
                            , DateTime.fromRawParts { year = 2019, month = Feb, day = 5 } { hours = 12, minutes = 15, seconds = 10, milliseconds = 150 }
                            ]
                in
                Expect.equalLists sortedList (DateTime.sort dateTimeList)
            )
        ]
