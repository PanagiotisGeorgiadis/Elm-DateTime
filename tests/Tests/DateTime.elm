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


suite : Test
suite =
    describe "DateTime Test Suite"
        [ fromPosixTests
        , sortTests

        -- , daysSinceEpochTests
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



-- daysSinceEpochTests : Test
-- daysSinceEpochTests =
--     describe "DateTime.daysSinceEpoch Test Suite"
--         [ test "1 day difference test case"
--             (\_ ->
--                 let
--                     dateTime =
--                         DateTime.fromPosix (Time.millisToPosix Calendar.millisInADay)
--                 in
--                 Expect.equal 1 (DateTime.daysSinceEpoch dateTime)
--             )
--         , test "1 week difference test case"
--             (\_ ->
--                 let
--                     dateTime =
--                         DateTime.fromPosix (Time.millisToPosix (Calendar.millisInADay * 7))
--                 in
--                 Expect.equal 7 (DateTime.daysSinceEpoch dateTime)
--             )
--         , test "Today"
--             (\_ ->
--                 let
--                     dateTime =
--                         DateTime.fromPosix (Time.millisToPosix 1545919050908)
--                 in
--                 Expect.equal 17892 (DateTime.daysSinceEpoch dateTime)
--             )
--         ]


sortTests : Test
sortTests =
    let
        defaultDateTime =
            DateTime.fromPosix (Time.millisToPosix 0)

        ( rawDate, rawMidnight ) =
            ( { year = 2019, month = Aug, day = 26 }
            , { hours = 0, minutes = 0, seconds = 0, milliseconds = 0 }
            )
    in
    describe "DateTime.sort Test Suite"
        [ test "Testing date sorting"
            (\_ ->
                let
                    dateTimeList =
                        List.map (Maybe.withDefault defaultDateTime)
                            [ DateTime.fromRawParts { year = 2019, month = Feb, day = 5 } rawMidnight
                            , DateTime.fromRawParts { year = 1995, month = Jan, day = 26 } rawMidnight
                            , DateTime.fromRawParts { year = 2017, month = Mar, day = 17 } rawMidnight
                            , DateTime.fromRawParts { year = 1895, month = Feb, day = 20 } rawMidnight
                            , DateTime.fromRawParts { year = 2018, month = Aug, day = 15 } rawMidnight
                            , DateTime.fromRawParts { year = 1650, month = Feb, day = 10 } rawMidnight
                            ]

                    sortedList =
                        List.map (Maybe.withDefault defaultDateTime)
                            [ DateTime.fromRawParts { year = 1650, month = Feb, day = 10 } rawMidnight
                            , DateTime.fromRawParts { year = 1895, month = Feb, day = 20 } rawMidnight
                            , DateTime.fromRawParts { year = 1995, month = Jan, day = 26 } rawMidnight
                            , DateTime.fromRawParts { year = 2017, month = Mar, day = 17 } rawMidnight
                            , DateTime.fromRawParts { year = 2018, month = Aug, day = 15 } rawMidnight
                            , DateTime.fromRawParts { year = 2019, month = Feb, day = 5 } rawMidnight
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
