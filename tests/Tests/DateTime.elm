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
        --
        , toPosixTests

        --
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
        , incrementYearTests
        , incrementMonthTests
        , incrementDayTests
        , incrementHoursTests
        , incrementMinutesTests
        , incrementSecondsTests
        , incrementMillisecondsTests
        , decrementYearTests
        , decrementMonthTests
        , decrementDayTests
        , decrementHoursTests
        , decrementMinutesTests
        , decrementSecondsTests
        , decrementMillisecondsTests
        , compareTests
        , compareDatesTests
        , compareTimeTests
        , getWeekdayTests
        , getDatesInMonthTests
        , getDateRangeTests
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


incrementYearTests : Test
incrementYearTests =
    let
        rawHours =
            { hours = 23, minutes = 15, seconds = 45, milliseconds = 250 }
    in
    describe "DateTime.incrementYear Test Suite"
        [ test "Incrementing the year with an initial DateTime of 11th of February 2019 23:15:45.250"
            (\_ ->
                let
                    dateTime =
                        DateTime.fromRawParts { year = 2019, month = Feb, day = 11 } rawHours
                in
                Expect.equal
                    (DateTime.fromRawParts { year = 2020, month = Feb, day = 11 } rawHours)
                    (Maybe.map DateTime.incrementYear dateTime)
            )
        , test "Incrementing the year with an initial DateTime of 29th of February 2020 23:15:45.250"
            (\_ ->
                let
                    dateTime =
                        DateTime.fromRawParts { year = 2020, month = Feb, day = 29 } rawHours
                in
                Expect.equal
                    (DateTime.fromRawParts { year = 2021, month = Feb, day = 28 } rawHours)
                    (Maybe.map DateTime.incrementYear dateTime)
            )
        , test "Incrementing the year with an initial DateTime of 28th of February 2019 23:15:45.250"
            (\_ ->
                let
                    dateTime =
                        DateTime.fromRawParts { year = 2019, month = Feb, day = 28 } rawHours
                in
                Expect.equal
                    (DateTime.fromRawParts { year = 2020, month = Feb, day = 28 } rawHours)
                    (Maybe.map DateTime.incrementYear dateTime)
            )
        ]


incrementMonthTests : Test
incrementMonthTests =
    let
        rawHours =
            { hours = 23, minutes = 15, seconds = 45, milliseconds = 250 }
    in
    describe "DateTime.incrementMonth Test Suite"
        [ test "Incrementing the month with an initial DateTime of 12th of December 2018 23:15:45.250 (Checking month and year increment)"
            (\_ ->
                let
                    dateTime =
                        DateTime.fromRawParts { year = 2018, month = Dec, day = 12 } rawHours
                in
                Expect.equal
                    (DateTime.fromRawParts { year = 2019, month = Jan, day = 12 } rawHours)
                    (Maybe.map DateTime.incrementMonth dateTime)
            )
        , test "Incrementing the month with an initial DateTime of 15th of June 2019 23:15:45.250"
            (\_ ->
                let
                    dateTime =
                        DateTime.fromRawParts { year = 2019, month = Jun, day = 15 } rawHours
                in
                Expect.equal
                    (DateTime.fromRawParts { year = 2019, month = Jul, day = 15 } rawHours)
                    (Maybe.map DateTime.incrementMonth dateTime)
            )
        , test "Incrementing the month with an initial DateTime of 31st of January 2019 23:15:45.250"
            (\_ ->
                let
                    dateTime =
                        DateTime.fromRawParts { year = 2019, month = Jan, day = 31 } rawHours
                in
                Expect.equal
                    (DateTime.fromRawParts { year = 2019, month = Feb, day = 28 } rawHours)
                    (Maybe.map DateTime.incrementMonth dateTime)
            )
        , test "Incrementing the month with an initial DateTime of 31st of January 2020 23:15:45.250"
            (\_ ->
                let
                    dateTime =
                        DateTime.fromRawParts { year = 2020, month = Jan, day = 31 } rawHours
                in
                Expect.equal
                    (DateTime.fromRawParts { year = 2020, month = Feb, day = 29 } rawHours)
                    (Maybe.map DateTime.incrementMonth dateTime)
            )
        ]


incrementDayTests : Test
incrementDayTests =
    let
        rawHours =
            { hours = 23, minutes = 15, seconds = 45, milliseconds = 250 }
    in
    describe "DateTime.incrementDay Test Suite"
        [ test "Incrementing the day with an initial DateTime of 31st of December 2018 23:15:45.250 (Checking day, month and year increment)"
            (\_ ->
                let
                    dateTime =
                        DateTime.fromRawParts { year = 2018, month = Dec, day = 31 } rawHours
                in
                Expect.equal
                    (DateTime.fromRawParts { year = 2019, month = Jan, day = 1 } rawHours)
                    (Maybe.map DateTime.incrementDay dateTime)
            )
        , test "Incrementing the day with an initial DateTime of 28th of February 2019 23:15:45.250"
            (\_ ->
                let
                    dateTime =
                        DateTime.fromRawParts { year = 2019, month = Feb, day = 28 } rawHours
                in
                Expect.equal
                    (DateTime.fromRawParts { year = 2019, month = Mar, day = 1 } rawHours)
                    (Maybe.map DateTime.incrementDay dateTime)
            )
        , test "Incrementing the day with an initial DateTime of 28th of February 2020 23:15:45.250"
            (\_ ->
                let
                    dateTime =
                        DateTime.fromRawParts { year = 2020, month = Feb, day = 28 } rawHours
                in
                Expect.equal
                    (DateTime.fromRawParts { year = 2020, month = Feb, day = 29 } rawHours)
                    (Maybe.map DateTime.incrementDay dateTime)
            )
        , test "Incrementing the day with an initial DateTime of 12th of September 2019 23:15:45.250"
            (\_ ->
                let
                    dateTime =
                        DateTime.fromRawParts { year = 2019, month = Sep, day = 12 } rawHours
                in
                Expect.equal
                    (DateTime.fromRawParts { year = 2019, month = Sep, day = 13 } rawHours)
                    (Maybe.map DateTime.incrementDay dateTime)
            )
        ]


incrementHoursTests : Test
incrementHoursTests =
    let
        ( rawHours, expectedRawHours ) =
            ( { hours = 23, minutes = 15, seconds = 45, milliseconds = 250 }
            , { hours = 0, minutes = 15, seconds = 45, milliseconds = 250 }
            )
    in
    describe "DateTime.incrementHours Test Suite"
        [ test "Incrementing the hours with an initial DateTime of 31st of December 2018 23:15:45.250 (Checking hours, day, month and year increment)"
            (\_ ->
                let
                    dateTime =
                        DateTime.fromRawParts { year = 2018, month = Dec, day = 31 } rawHours
                in
                Expect.equal
                    (DateTime.fromRawParts { year = 2019, month = Jan, day = 1 } expectedRawHours)
                    (Maybe.map DateTime.incrementHours dateTime)
            )
        , test "Incrementing the hours with an initial DateTime of 28th of February 2019 23:15:45.250"
            (\_ ->
                let
                    dateTime =
                        DateTime.fromRawParts { year = 2019, month = Feb, day = 28 } rawHours
                in
                Expect.equal
                    (DateTime.fromRawParts { year = 2019, month = Mar, day = 1 } expectedRawHours)
                    (Maybe.map DateTime.incrementHours dateTime)
            )
        , test "Incrementing the hours with an initial DateTime of 28th of February 2020 23:15:45.250"
            (\_ ->
                let
                    dateTime =
                        DateTime.fromRawParts { year = 2020, month = Feb, day = 28 } rawHours
                in
                Expect.equal
                    (DateTime.fromRawParts { year = 2020, month = Feb, day = 29 } expectedRawHours)
                    (Maybe.map DateTime.incrementHours dateTime)
            )
        , test "Incrementing the hours with an initial DateTime of 15th of January 2020 15:45:25.250"
            (\_ ->
                let
                    dateTime =
                        DateTime.fromRawParts { year = 2020, month = Jan, day = 15 } { hours = 15, minutes = 45, seconds = 25, milliseconds = 250 }
                in
                Expect.equal
                    (DateTime.fromRawParts { year = 2020, month = Jan, day = 15 } { hours = 16, minutes = 45, seconds = 25, milliseconds = 250 })
                    (Maybe.map DateTime.incrementHours dateTime)
            )
        ]


incrementMinutesTests : Test
incrementMinutesTests =
    let
        ( rawHours, expectedRawHours ) =
            ( { hours = 23, minutes = 59, seconds = 15, milliseconds = 250 }
            , { hours = 0, minutes = 0, seconds = 15, milliseconds = 250 }
            )
    in
    describe "DateTime.incrementMinutes Test Suite"
        [ test "Incrementing the minutes with an initial DateTime of 31st of December 2018 23:59:15.250 (Checking minutes, hours, day, month and year increment)"
            (\_ ->
                let
                    dateTime =
                        DateTime.fromRawParts { year = 2018, month = Dec, day = 31 } rawHours
                in
                Expect.equal
                    (DateTime.fromRawParts { year = 2019, month = Jan, day = 1 } expectedRawHours)
                    (Maybe.map DateTime.incrementMinutes dateTime)
            )
        , test "Incrementing the minutes with an initial DateTime of 28th of February 2019 23:59:15.250"
            (\_ ->
                let
                    dateTime =
                        DateTime.fromRawParts { year = 2019, month = Feb, day = 28 } rawHours
                in
                Expect.equal
                    (DateTime.fromRawParts { year = 2019, month = Mar, day = 1 } expectedRawHours)
                    (Maybe.map DateTime.incrementMinutes dateTime)
            )
        , test "Incrementing the minutes with an initial DateTime of 28th of February 2020 23:59:15.250"
            (\_ ->
                let
                    dateTime =
                        DateTime.fromRawParts { year = 2020, month = Feb, day = 28 } rawHours
                in
                Expect.equal
                    (DateTime.fromRawParts { year = 2020, month = Feb, day = 29 } expectedRawHours)
                    (Maybe.map DateTime.incrementMinutes dateTime)
            )
        , test "Incrementing the minutes with an initial DateTime of 15th of January 2020 15:45:25.250"
            (\_ ->
                let
                    dateTime =
                        DateTime.fromRawParts { year = 2020, month = Jan, day = 15 } { hours = 15, minutes = 45, seconds = 25, milliseconds = 250 }
                in
                Expect.equal
                    (DateTime.fromRawParts { year = 2020, month = Jan, day = 15 } { hours = 15, minutes = 46, seconds = 25, milliseconds = 250 })
                    (Maybe.map DateTime.incrementMinutes dateTime)
            )
        ]


incrementSecondsTests : Test
incrementSecondsTests =
    let
        ( rawHours, expectedRawHours ) =
            ( { hours = 23, minutes = 59, seconds = 59, milliseconds = 250 }
            , { hours = 0, minutes = 0, seconds = 0, milliseconds = 250 }
            )
    in
    describe "DateTime.incrementSeconds Test Suite"
        [ test "Incrementing the seconds with an initial DateTime of 31st of December 2018 23:59:59.250 (Checking seconds, minutes, hours, day, month and year increment)"
            (\_ ->
                let
                    dateTime =
                        DateTime.fromRawParts { year = 2018, month = Dec, day = 31 } rawHours
                in
                Expect.equal
                    (DateTime.fromRawParts { year = 2019, month = Jan, day = 1 } expectedRawHours)
                    (Maybe.map DateTime.incrementSeconds dateTime)
            )
        , test "Incrementing the seconds with an initial DateTime of 28th of February 2019 23:59:59.250"
            (\_ ->
                let
                    dateTime =
                        DateTime.fromRawParts { year = 2019, month = Feb, day = 28 } rawHours
                in
                Expect.equal
                    (DateTime.fromRawParts { year = 2019, month = Mar, day = 1 } expectedRawHours)
                    (Maybe.map DateTime.incrementSeconds dateTime)
            )
        , test "Incrementing the seconds with an initial DateTime of 28th of February 2020 23:59:59.250"
            (\_ ->
                let
                    dateTime =
                        DateTime.fromRawParts { year = 2020, month = Feb, day = 28 } rawHours
                in
                Expect.equal
                    (DateTime.fromRawParts { year = 2020, month = Feb, day = 29 } expectedRawHours)
                    (Maybe.map DateTime.incrementSeconds dateTime)
            )
        , test "Incrementing the seconds with an initial DateTime of 15th of January 2020 15:45:59.250"
            (\_ ->
                let
                    dateTime =
                        DateTime.fromRawParts { year = 2020, month = Jan, day = 15 } { hours = 15, minutes = 45, seconds = 59, milliseconds = 250 }
                in
                Expect.equal
                    (DateTime.fromRawParts { year = 2020, month = Jan, day = 15 } { hours = 15, minutes = 46, seconds = 0, milliseconds = 250 })
                    (Maybe.map DateTime.incrementSeconds dateTime)
            )
        ]


incrementMillisecondsTests : Test
incrementMillisecondsTests =
    let
        ( rawHours, expectedRawHours ) =
            ( { hours = 23, minutes = 59, seconds = 59, milliseconds = 999 }
            , { hours = 0, minutes = 0, seconds = 0, milliseconds = 0 }
            )
    in
    describe "DateTime.incrementMilliseconds Test Suite"
        [ test "Incrementing the milliseconds with an initial DateTime of 31st of December 2018 23:59:59.999 (Checking milliseconds, seconds, minutes, hours, day, month and year increment)"
            (\_ ->
                let
                    dateTime =
                        DateTime.fromRawParts { year = 2018, month = Dec, day = 31 } rawHours
                in
                Expect.equal
                    (DateTime.fromRawParts { year = 2019, month = Jan, day = 1 } expectedRawHours)
                    (Maybe.map DateTime.incrementMilliseconds dateTime)
            )
        , test "Incrementing the milliseconds with an initial DateTime of 28th of February 2019 23:59:59.999"
            (\_ ->
                let
                    dateTime =
                        DateTime.fromRawParts { year = 2019, month = Feb, day = 28 } rawHours
                in
                Expect.equal
                    (DateTime.fromRawParts { year = 2019, month = Mar, day = 1 } expectedRawHours)
                    (Maybe.map DateTime.incrementMilliseconds dateTime)
            )
        , test "Incrementing the milliseconds with an initial DateTime of 28th of February 2020 23:59:59.999"
            (\_ ->
                let
                    dateTime =
                        DateTime.fromRawParts { year = 2020, month = Feb, day = 28 } rawHours
                in
                Expect.equal
                    (DateTime.fromRawParts { year = 2020, month = Feb, day = 29 } expectedRawHours)
                    (Maybe.map DateTime.incrementMilliseconds dateTime)
            )
        , test "Incrementing the milliseconds with an initial DateTime of 15th of January 2020 15:45:59.999"
            (\_ ->
                let
                    dateTime =
                        DateTime.fromRawParts { year = 2020, month = Jan, day = 15 } { hours = 15, minutes = 45, seconds = 59, milliseconds = 999 }
                in
                Expect.equal
                    (DateTime.fromRawParts { year = 2020, month = Jan, day = 15 } { hours = 15, minutes = 46, seconds = 0, milliseconds = 0 })
                    (Maybe.map DateTime.incrementMilliseconds dateTime)
            )
        ]


decrementYearTests : Test
decrementYearTests =
    let
        rawHours =
            { hours = 23, minutes = 15, seconds = 45, milliseconds = 250 }
    in
    describe "DateTime.decrementYear Test Suite"
        [ test "Decrementing the year with an initial DateTime of 11th of February 2019 23:15:45.250"
            (\_ ->
                let
                    dateTime =
                        DateTime.fromRawParts { year = 2019, month = Feb, day = 11 } rawHours
                in
                Expect.equal
                    (DateTime.fromRawParts { year = 2018, month = Feb, day = 11 } rawHours)
                    (Maybe.map DateTime.decrementYear dateTime)
            )
        , test "Decrementing the year with an initial DateTime of 29th of February 2020 23:15:45.250"
            (\_ ->
                let
                    dateTime =
                        DateTime.fromRawParts { year = 2020, month = Feb, day = 29 } rawHours
                in
                Expect.equal
                    (DateTime.fromRawParts { year = 2019, month = Feb, day = 28 } rawHours)
                    (Maybe.map DateTime.decrementYear dateTime)
            )
        , test "Decrementing the year with an initial DateTime of 28th of February 2021 23:15:45.250"
            (\_ ->
                let
                    dateTime =
                        DateTime.fromRawParts { year = 2021, month = Feb, day = 28 } rawHours
                in
                Expect.equal
                    (DateTime.fromRawParts { year = 2020, month = Feb, day = 28 } rawHours)
                    (Maybe.map DateTime.decrementYear dateTime)
            )
        ]


decrementMonthTests : Test
decrementMonthTests =
    let
        rawHours =
            { hours = 23, minutes = 15, seconds = 45, milliseconds = 250 }
    in
    describe "DateTime.decrementMonth Test Suite"
        [ test "Decrementing the month with an initial DateTime as 12th of January 2018 23:15:45.250 (Checking month and year decrement)"
            (\_ ->
                let
                    dateTime =
                        DateTime.fromRawParts { year = 2018, month = Jan, day = 12 } rawHours
                in
                Expect.equal
                    (DateTime.fromRawParts { year = 2017, month = Dec, day = 12 } rawHours)
                    (Maybe.map DateTime.decrementMonth dateTime)
            )
        , test "Decrementing the month with an initial DateTime as 15th of June 2019 23:15:45.250"
            (\_ ->
                let
                    dateTime =
                        DateTime.fromRawParts { year = 2019, month = Jun, day = 15 } rawHours
                in
                Expect.equal
                    (DateTime.fromRawParts { year = 2019, month = May, day = 15 } rawHours)
                    (Maybe.map DateTime.decrementMonth dateTime)
            )
        , test "Decrementing the month with an initial DateTime as 31st of March 2019 23:15:45.250"
            (\_ ->
                let
                    dateTime =
                        DateTime.fromRawParts { year = 2019, month = Mar, day = 31 } rawHours
                in
                Expect.equal
                    (DateTime.fromRawParts { year = 2019, month = Feb, day = 28 } rawHours)
                    (Maybe.map DateTime.decrementMonth dateTime)
            )
        , test "Decrementing the month with an initial DateTime as 31st of March 2020 23:15:45.250"
            (\_ ->
                let
                    dateTime =
                        DateTime.fromRawParts { year = 2020, month = Mar, day = 31 } rawHours
                in
                Expect.equal
                    (DateTime.fromRawParts { year = 2020, month = Feb, day = 29 } rawHours)
                    (Maybe.map DateTime.decrementMonth dateTime)
            )
        ]


decrementDayTests : Test
decrementDayTests =
    let
        rawHours =
            { hours = 23, minutes = 15, seconds = 45, milliseconds = 250 }
    in
    describe "DateTime.decrementDay Test Suite"
        [ test "Decrementing the day with an initial DateTime of 1st of January 2019 23:15:45.250 (Checking day, month and year decrement)"
            (\_ ->
                let
                    dateTime =
                        DateTime.fromRawParts { year = 2019, month = Jan, day = 1 } rawHours
                in
                Expect.equal
                    (DateTime.fromRawParts { year = 2018, month = Dec, day = 31 } rawHours)
                    (Maybe.map DateTime.decrementDay dateTime)
            )
        , test "Decrementing the day with an initial DateTime of 1st of March 2019 23:15:45.250"
            (\_ ->
                let
                    dateTime =
                        DateTime.fromRawParts { year = 2019, month = Mar, day = 1 } rawHours
                in
                Expect.equal
                    (DateTime.fromRawParts { year = 2019, month = Feb, day = 28 } rawHours)
                    (Maybe.map DateTime.decrementDay dateTime)
            )
        , test "Decrementing the day with an initial DateTime of 1st of March 2020 23:15:45.250"
            (\_ ->
                let
                    dateTime =
                        DateTime.fromRawParts { year = 2020, month = Mar, day = 1 } rawHours
                in
                Expect.equal
                    (DateTime.fromRawParts { year = 2020, month = Feb, day = 29 } rawHours)
                    (Maybe.map DateTime.decrementDay dateTime)
            )
        , test "Decrementing the day with an initial DateTime of 12th of September 2019 23:15:45.250"
            (\_ ->
                let
                    dateTime =
                        DateTime.fromRawParts { year = 2019, month = Sep, day = 12 } rawHours
                in
                Expect.equal
                    (DateTime.fromRawParts { year = 2019, month = Sep, day = 11 } rawHours)
                    (Maybe.map DateTime.decrementDay dateTime)
            )
        ]


decrementHoursTests : Test
decrementHoursTests =
    let
        ( rawHours, expectedRawHours ) =
            ( { hours = 0, minutes = 15, seconds = 45, milliseconds = 250 }
            , { hours = 23, minutes = 15, seconds = 45, milliseconds = 250 }
            )
    in
    describe "DateTime.decrementHours Test Suite"
        [ test "Decrementing the hours with an initial DateTime as 1st of January 2019 00:15:45.250 (Checking hours, day, month and year decrement)"
            (\_ ->
                let
                    dateTime =
                        DateTime.fromRawParts { year = 2019, month = Jan, day = 1 } rawHours
                in
                Expect.equal
                    (DateTime.fromRawParts { year = 2018, month = Dec, day = 31 } expectedRawHours)
                    (Maybe.map DateTime.decrementHours dateTime)
            )
        , test "Decrementing the hours with an initial DateTime as 1st of March 2019 00:15:45.250"
            (\_ ->
                let
                    dateTime =
                        DateTime.fromRawParts { year = 2019, month = Mar, day = 1 } rawHours
                in
                Expect.equal
                    (DateTime.fromRawParts { year = 2019, month = Feb, day = 28 } expectedRawHours)
                    (Maybe.map DateTime.decrementHours dateTime)
            )
        , test "Decrementing the hours with an initial DateTime as 1st of March 2020 00:15:45.250"
            (\_ ->
                let
                    dateTime =
                        DateTime.fromRawParts { year = 2020, month = Mar, day = 1 } rawHours
                in
                Expect.equal
                    (DateTime.fromRawParts { year = 2020, month = Feb, day = 29 } expectedRawHours)
                    (Maybe.map DateTime.decrementHours dateTime)
            )
        , test "Decrementing the hours with an initial DateTime as 15th of January 2020 16:45:25.250"
            (\_ ->
                let
                    dateTime =
                        DateTime.fromRawParts { year = 2020, month = Jan, day = 15 } { hours = 16, minutes = 45, seconds = 25, milliseconds = 250 }
                in
                Expect.equal
                    (DateTime.fromRawParts { year = 2020, month = Jan, day = 15 } { hours = 15, minutes = 45, seconds = 25, milliseconds = 250 })
                    (Maybe.map DateTime.decrementHours dateTime)
            )
        ]


decrementMinutesTests : Test
decrementMinutesTests =
    let
        ( rawHours, expectedRawHours ) =
            ( { hours = 0, minutes = 0, seconds = 15, milliseconds = 250 }
            , { hours = 23, minutes = 59, seconds = 15, milliseconds = 250 }
            )
    in
    describe "DateTime.decrementMinutes Test Suite"
        [ test "Decrementing the minutes with an initial DateTime of 1st of January 2019 00:00:15.250 (Checking minutes, hours, day, month and year decrement)"
            (\_ ->
                let
                    dateTime =
                        DateTime.fromRawParts { year = 2019, month = Jan, day = 1 } rawHours
                in
                Expect.equal
                    (DateTime.fromRawParts { year = 2018, month = Dec, day = 31 } expectedRawHours)
                    (Maybe.map DateTime.decrementMinutes dateTime)
            )
        , test "Decrementing the minutes with an initial DateTime of 1st of March 2019 00:00:15.250"
            (\_ ->
                let
                    dateTime =
                        DateTime.fromRawParts { year = 2019, month = Mar, day = 1 } rawHours
                in
                Expect.equal
                    (DateTime.fromRawParts { year = 2019, month = Feb, day = 28 } expectedRawHours)
                    (Maybe.map DateTime.decrementMinutes dateTime)
            )
        , test "Decrementing the minutes with an initial DateTime of 1st of March 2020 00:00:15.250"
            (\_ ->
                let
                    dateTime =
                        DateTime.fromRawParts { year = 2020, month = Mar, day = 1 } rawHours
                in
                Expect.equal
                    (DateTime.fromRawParts { year = 2020, month = Feb, day = 29 } expectedRawHours)
                    (Maybe.map DateTime.decrementMinutes dateTime)
            )
        , test "Decrementing the minutes with an initial DateTime of 15th of January 2020 15:45:25.250"
            (\_ ->
                let
                    dateTime =
                        DateTime.fromRawParts { year = 2020, month = Jan, day = 15 } { hours = 15, minutes = 45, seconds = 25, milliseconds = 250 }
                in
                Expect.equal
                    (DateTime.fromRawParts { year = 2020, month = Jan, day = 15 } { hours = 15, minutes = 44, seconds = 25, milliseconds = 250 })
                    (Maybe.map DateTime.decrementMinutes dateTime)
            )
        ]


decrementSecondsTests : Test
decrementSecondsTests =
    let
        ( rawHours, expectedRawHours ) =
            ( { hours = 0, minutes = 0, seconds = 0, milliseconds = 250 }
            , { hours = 23, minutes = 59, seconds = 59, milliseconds = 250 }
            )
    in
    describe "DateTime.decrementSeconds Test Suite"
        [ test "Decrementing the seconds with an initial DateTime of 1st of January 2019 00:00:00.250 (Checking seconds, minutes, hours, day, month and year decrement)"
            (\_ ->
                let
                    dateTime =
                        DateTime.fromRawParts { year = 2019, month = Jan, day = 1 } rawHours
                in
                Expect.equal
                    (DateTime.fromRawParts { year = 2018, month = Dec, day = 31 } expectedRawHours)
                    (Maybe.map DateTime.decrementSeconds dateTime)
            )
        , test "Decrementing the seconds with an initial DateTime of 1st of March 2019 00:00:00.250"
            (\_ ->
                let
                    dateTime =
                        DateTime.fromRawParts { year = 2019, month = Mar, day = 1 } rawHours
                in
                Expect.equal
                    (DateTime.fromRawParts { year = 2019, month = Feb, day = 28 } expectedRawHours)
                    (Maybe.map DateTime.decrementSeconds dateTime)
            )
        , test "Decrementing the seconds with an initial DateTime of 1st of March 2020 00:00:00.250"
            (\_ ->
                let
                    dateTime =
                        DateTime.fromRawParts { year = 2020, month = Mar, day = 1 } rawHours
                in
                Expect.equal
                    (DateTime.fromRawParts { year = 2020, month = Feb, day = 29 } expectedRawHours)
                    (Maybe.map DateTime.decrementSeconds dateTime)
            )
        , test "Decrementing the seconds with an initial DateTime of 15th of January 2020 15:45:59.250"
            (\_ ->
                let
                    dateTime =
                        DateTime.fromRawParts { year = 2020, month = Jan, day = 15 } { hours = 15, minutes = 45, seconds = 59, milliseconds = 250 }
                in
                Expect.equal
                    (DateTime.fromRawParts { year = 2020, month = Jan, day = 15 } { hours = 15, minutes = 45, seconds = 58, milliseconds = 250 })
                    (Maybe.map DateTime.decrementSeconds dateTime)
            )
        ]


decrementMillisecondsTests : Test
decrementMillisecondsTests =
    let
        ( rawHours, expectedRawHours ) =
            ( { hours = 0, minutes = 0, seconds = 0, milliseconds = 0 }
            , { hours = 23, minutes = 59, seconds = 59, milliseconds = 999 }
            )
    in
    describe "DateTime.decrementMilliseconds Test Suite"
        [ test "Decrementing the milliseconds with an initial DateTime of 1st of January 2019 00:00:00.000 (Checking milliseconds, seconds, minutes, hours, day, month and year decrement)"
            (\_ ->
                let
                    dateTime =
                        DateTime.fromRawParts { year = 2019, month = Jan, day = 1 } rawHours
                in
                Expect.equal
                    (DateTime.fromRawParts { year = 2018, month = Dec, day = 31 } expectedRawHours)
                    (Maybe.map DateTime.decrementMilliseconds dateTime)
            )
        , test "Decrementing the milliseconds with an initial DateTime of 1st of March 2019 00:00:00.000"
            (\_ ->
                let
                    dateTime =
                        DateTime.fromRawParts { year = 2019, month = Mar, day = 1 } rawHours
                in
                Expect.equal
                    (DateTime.fromRawParts { year = 2019, month = Feb, day = 28 } expectedRawHours)
                    (Maybe.map DateTime.decrementMilliseconds dateTime)
            )
        , test "Decrementing the milliseconds with an initial DateTime of 1st of March 2020 00:00:00.000"
            (\_ ->
                let
                    dateTime =
                        DateTime.fromRawParts { year = 2020, month = Mar, day = 1 } rawHours
                in
                Expect.equal
                    (DateTime.fromRawParts { year = 2020, month = Feb, day = 29 } expectedRawHours)
                    (Maybe.map DateTime.decrementMilliseconds dateTime)
            )
        , test "Decrementing the milliseconds with an initial DateTime of 15th of January 2020 16:00:00.000"
            (\_ ->
                let
                    dateTime =
                        DateTime.fromRawParts { year = 2020, month = Jan, day = 15 } { hours = 16, minutes = 0, seconds = 0, milliseconds = 0 }
                in
                Expect.equal
                    (DateTime.fromRawParts { year = 2020, month = Jan, day = 15 } { hours = 15, minutes = 59, seconds = 59, milliseconds = 999 })
                    (Maybe.map DateTime.decrementMilliseconds dateTime)
            )
        ]


compareTests : Test
compareTests =
    describe "DateTime.compare Test Suite"
        [ test "Comparing 15th November 2018 21:00:00.000 with 24th October 2019 21:00:00.000"
            (\_ ->
                Expect.equal (Just LT) <|
                    Maybe.map2 DateTime.compare
                        (DateTime.fromRawParts { year = 2018, month = Nov, day = 15 } { hours = 21, minutes = 0, seconds = 0, milliseconds = 0 })
                        (DateTime.fromRawParts { year = 2019, month = Oct, day = 24 } { hours = 21, minutes = 0, seconds = 0, milliseconds = 0 })
            )
        , test "Comparing 24th October 2019 21:00:00.000 with 15th November 2018 21:00:00.000"
            (\_ ->
                Expect.equal (Just GT) <|
                    Maybe.map2 DateTime.compare
                        (DateTime.fromRawParts { year = 2019, month = Oct, day = 24 } { hours = 21, minutes = 0, seconds = 0, milliseconds = 0 })
                        (DateTime.fromRawParts { year = 2018, month = Nov, day = 15 } { hours = 21, minutes = 0, seconds = 0, milliseconds = 0 })
            )
        , test "Comparing two equal dates"
            (\_ ->
                Expect.equal (Just EQ) <|
                    Maybe.map2 DateTime.compare
                        (DateTime.fromRawParts { year = 2019, month = Oct, day = 24 } { hours = 21, minutes = 0, seconds = 0, milliseconds = 0 })
                        (DateTime.fromRawParts { year = 2019, month = Oct, day = 24 } { hours = 21, minutes = 0, seconds = 0, milliseconds = 0 })
            )
        , test "Comparing 24th of October 2019 21:00:00.000 with 24th of October 2019 22:00:00.000"
            (\_ ->
                Expect.equal (Just LT) <|
                    Maybe.map2 DateTime.compare
                        (DateTime.fromRawParts { year = 2019, month = Oct, day = 24 } { hours = 21, minutes = 0, seconds = 0, milliseconds = 0 })
                        (DateTime.fromRawParts { year = 2019, month = Oct, day = 24 } { hours = 22, minutes = 0, seconds = 0, milliseconds = 0 })
            )
        , test "Comparing 24th of October 2019 21:45:56.000 with 24th of October 2019 21:45:55.000"
            (\_ ->
                Expect.equal (Just GT) <|
                    Maybe.map2 DateTime.compare
                        (DateTime.fromRawParts { year = 2019, month = Oct, day = 24 } { hours = 21, minutes = 45, seconds = 56, milliseconds = 0 })
                        (DateTime.fromRawParts { year = 2019, month = Oct, day = 24 } { hours = 21, minutes = 45, seconds = 55, milliseconds = 0 })
            )
        , test "Comparing 24th of October 2019 21:45:56.000 with 25th of October 1870 21:45:55.000"
            (\_ ->
                Expect.equal (Just GT) <|
                    Maybe.map2 DateTime.compare
                        (DateTime.fromRawParts { year = 2019, month = Oct, day = 24 } { hours = 21, minutes = 45, seconds = 55, milliseconds = 0 })
                        (DateTime.fromRawParts { year = 1870, month = Oct, day = 25 } { hours = 21, minutes = 45, seconds = 56, milliseconds = 0 })
            )
        ]


compareDatesTests : Test
compareDatesTests =
    let
        ( lower, higher ) =
            ( DateTime.fromRawParts { year = 2019, month = Aug, day = 25 } { hours = 21, minutes = 0, seconds = 0, milliseconds = 0 }
            , DateTime.fromRawParts { year = 2019, month = Aug, day = 26 } { hours = 21, minutes = 0, seconds = 0, milliseconds = 0 }
            )
    in
    describe "DateTime.compareDates Test Suite"
        [ test "Comparing 25th of August 2019 21:00:00.000 with 26th of August 2019 21:00:00.000"
            (\_ ->
                Expect.equal (Just LT) <|
                    Maybe.map2 DateTime.compareDates lower higher
            )
        , test "Comparing 26th of August 2019 21:00:00.000 with 25th of August 2019 21:00:00.000"
            (\_ ->
                Expect.equal (Just GT) <|
                    Maybe.map2 DateTime.compareDates higher lower
            )
        , test "Comparing 26th of August 2019 21:00:00.000 with 26th of August 2019 21:00:00.000"
            (\_ ->
                Expect.equal (Just EQ) <|
                    Maybe.map2 DateTime.compareDates higher higher
            )
        , test "Comparing 26th of August 2019 21:00:00.000 with 26th of August 2019 21:45:30.000"
            (\_ ->
                Expect.equal (Just EQ) <|
                    Maybe.map2 DateTime.compareDates higher (DateTime.fromRawParts { year = 2019, month = Aug, day = 26 } { hours = 21, minutes = 45, seconds = 30, milliseconds = 0 })
            )
        ]


compareTimeTests : Test
compareTimeTests =
    describe "DateTime.compareTime Test Suite"
        [ test "Comparing 26th of August 2019 21:00:00.000 with 26th of August 2019 21:45:00.000"
            (\_ ->
                Expect.equal (Just LT) <|
                    Maybe.map2 DateTime.compareTime
                        (DateTime.fromRawParts { year = 2019, month = Aug, day = 26 } { hours = 21, minutes = 0, seconds = 0, milliseconds = 0 })
                        (DateTime.fromRawParts { year = 2019, month = Aug, day = 26 } { hours = 21, minutes = 45, seconds = 0, milliseconds = 0 })
            )
        , test "Comparing 26th of August 2019 21:45:00.000 with 26th of August 2019 21:00:00.000"
            (\_ ->
                Expect.equal (Just GT) <|
                    Maybe.map2 DateTime.compareTime
                        (DateTime.fromRawParts { year = 2019, month = Aug, day = 26 } { hours = 21, minutes = 45, seconds = 0, milliseconds = 0 })
                        (DateTime.fromRawParts { year = 2019, month = Aug, day = 26 } { hours = 21, minutes = 0, seconds = 0, milliseconds = 0 })
            )
        , test "Comparing 26th of August 2019 21:00:00.000 with 26th of August 2019 21:00:00.000"
            (\_ ->
                Expect.equal (Just EQ) <|
                    Maybe.map2 DateTime.compareTime
                        (DateTime.fromRawParts { year = 2019, month = Aug, day = 26 } { hours = 21, minutes = 0, seconds = 0, milliseconds = 0 })
                        (DateTime.fromRawParts { year = 2019, month = Aug, day = 26 } { hours = 21, minutes = 0, seconds = 0, milliseconds = 0 })
            )
        , test "Comparing 15th of November 2020 21:00:00.000 with 26th of August 2019 21:00:00.000"
            (\_ ->
                Expect.equal (Just EQ) <|
                    Maybe.map2 DateTime.compareTime
                        (DateTime.fromRawParts { year = 2020, month = Nov, day = 15 } { hours = 21, minutes = 0, seconds = 0, milliseconds = 0 })
                        (DateTime.fromRawParts { year = 2019, month = Aug, day = 26 } { hours = 21, minutes = 0, seconds = 0, milliseconds = 0 })
            )
        , test "Comparing 15th of November 2020 21:00:00.000 with 26th of August 2019 21:00:45.000"
            (\_ ->
                Expect.equal (Just LT) <|
                    Maybe.map2 DateTime.compareTime
                        (DateTime.fromRawParts { year = 2020, month = Nov, day = 15 } { hours = 21, minutes = 0, seconds = 0, milliseconds = 0 })
                        (DateTime.fromRawParts { year = 2019, month = Aug, day = 26 } { hours = 21, minutes = 0, seconds = 45, milliseconds = 0 })
            )
        ]


getWeekdayTests : Test
getWeekdayTests =
    describe "DateTime.getWeekday Test Suite"
        [ test "Getting the weekday from 11th of February 2019."
            (\_ ->
                Expect.equal (Just Mon) <|
                    Maybe.map DateTime.getWeekday
                        (DateTime.fromRawParts { year = 2019, month = Feb, day = 11 } { hours = 12, minutes = 0, seconds = 0, milliseconds = 0 })
            )
        , test "Getting the weekday from 29th of February 2020."
            (\_ ->
                Expect.equal (Just Sat) <|
                    Maybe.map DateTime.getWeekday
                        (DateTime.fromRawParts { year = 2020, month = Feb, day = 29 } { hours = 12, minutes = 0, seconds = 0, milliseconds = 0 })
            )
        , test "Getting the weekday from 1st of March 2020."
            (\_ ->
                Expect.equal (Just Sun) <|
                    Maybe.map DateTime.getWeekday
                        (DateTime.fromRawParts { year = 2020, month = Mar, day = 1 } { hours = 12, minutes = 0, seconds = 0, milliseconds = 0 })
            )
        ]


getDatesInMonthTests : Test
getDatesInMonthTests =
    let
        defaultDate =
            DateTime.fromPosix (Time.millisToPosix 0)
    in
    describe "DateTime.getDatesInMonth Test Suite"
        [ test "Getting the dates in August 2019."
            (\_ ->
                let
                    expectedDates =
                        List.map (Maybe.withDefault defaultDate) <|
                            List.map
                                (\day ->
                                    DateTime.fromRawParts { year = 2019, month = Aug, day = day } { hours = 12, minutes = 0, seconds = 0, milliseconds = 0 }
                                )
                                (List.range 1 31)

                    dates =
                        Maybe.withDefault [] <|
                            Maybe.map DateTime.getDatesInMonth <|
                                DateTime.fromRawParts { year = 2019, month = Aug, day = 1 } { hours = 12, minutes = 0, seconds = 0, milliseconds = 0 }
                in
                Expect.equalLists expectedDates dates
            )
        , test "Getting the dates in February 2019."
            (\_ ->
                let
                    expectedDates =
                        List.map (Maybe.withDefault defaultDate) <|
                            List.map
                                (\day ->
                                    DateTime.fromRawParts { year = 2019, month = Feb, day = day } { hours = 12, minutes = 0, seconds = 0, milliseconds = 0 }
                                )
                                (List.range 1 28)

                    dates =
                        Maybe.withDefault [] <|
                            Maybe.map DateTime.getDatesInMonth <|
                                DateTime.fromRawParts { year = 2019, month = Feb, day = 1 } { hours = 12, minutes = 0, seconds = 0, milliseconds = 0 }
                in
                Expect.equalLists expectedDates dates
            )
        , test "Getting the dates in February 2020."
            (\_ ->
                let
                    expectedDates =
                        List.map (Maybe.withDefault defaultDate) <|
                            List.map
                                (\day ->
                                    DateTime.fromRawParts { year = 2020, month = Feb, day = day } { hours = 12, minutes = 0, seconds = 0, milliseconds = 0 }
                                )
                                (List.range 1 29)

                    dates =
                        Maybe.withDefault [] <|
                            Maybe.map DateTime.getDatesInMonth <|
                                DateTime.fromRawParts { year = 2020, month = Feb, day = 1 } { hours = 12, minutes = 0, seconds = 0, milliseconds = 0 }
                in
                Expect.equalLists expectedDates dates
            )
        ]


getDateRangeTests : Test
getDateRangeTests =
    let
        defaultDate =
            DateTime.fromPosix (Time.millisToPosix 0)

        constructDate day month year =
            Maybe.withDefault defaultDate <|
                DateTime.fromRawParts { year = year, month = month, day = day } midnightRawParts
    in
    describe "DateTime.getDateRange Test Suite"
        [ test "Getting a date range from 25th of February 2019 to 2nd of March 2019"
            (\_ ->
                let
                    ( start, end ) =
                        ( constructDate 25 Feb 2019
                        , constructDate 2 Mar 2019
                        )

                    expected =
                        [ constructDate 25 Feb 2019
                        , constructDate 26 Feb 2019
                        , constructDate 27 Feb 2019
                        , constructDate 28 Feb 2019
                        , constructDate 1 Mar 2019
                        , constructDate 2 Mar 2019
                        ]
                in
                Expect.equalLists expected (DateTime.getDateRange start end Clock.midnight)
            )
        , test "Getting a date range from 25th of February 2020 to 2nd of March 2020"
            (\_ ->
                let
                    ( start, end ) =
                        ( constructDate 25 Feb 2020
                        , constructDate 2 Mar 2020
                        )

                    expected =
                        [ constructDate 25 Feb 2020
                        , constructDate 26 Feb 2020
                        , constructDate 27 Feb 2020
                        , constructDate 28 Feb 2020
                        , constructDate 29 Feb 2020
                        , constructDate 1 Mar 2020
                        , constructDate 2 Mar 2020
                        ]
                in
                Expect.equalLists expected (DateTime.getDateRange start end Clock.midnight)
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
