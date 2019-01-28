module Tests.DateTime exposing (suite)

import Expect exposing (Expectation)
import Fuzz exposing (Fuzzer, int, list, string)
import Test exposing (..)
import Tests.DateTime.DateTime as DateTime
import Time


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

        -- , daysSinceEpochTests
        ]


fromPosixTests : Test
fromPosixTests =
    let
        date =
            -- This timestamp is equivalent to Fri Dec 21 2018 15:45:30 GMT+0000
            DateTime.fromPosix (Time.millisToPosix 1545407130000)
    in
    describe "Clock.fromPosix Test Suite"
        [ test "Year validation"
            (\_ ->
                Expect.equal 2018 (DateTime.getYearInt date)
            )
        , test "Month Int validation"
            (\_ ->
                Expect.equal 12 (DateTime.getMonthInt date)
            )
        , test "Month validation"
            (\_ ->
                Expect.equal Time.Dec (DateTime.getMonth date)
            )
        , test "Day validation"
            (\_ ->
                Expect.equal 21 (DateTime.getDayInt date)
            )
        , test "Weekday validation"
            (\_ ->
                Expect.equal Time.Fri (DateTime.getWeekday date)
            )
        , test "Hours validation"
            (\_ ->
                Expect.equal 15 (DateTime.getHoursInt date)
            )
        , test "Minutes validation"
            (\_ ->
                Expect.equal 45 (DateTime.getMinutesInt date)
            )
        , test "Seconds validation"
            (\_ ->
                Expect.equal 30 (DateTime.getSecondsInt date)
            )
        , test "Milliseconds validation"
            (\_ ->
                Expect.equal 0 (DateTime.getMillisecondsInt date)
            )
        , test "Milliseconds second validation"
            (\_ ->
                let
                    date_ =
                        DateTime.fromPosix (Time.millisToPosix (1545407130000 + 500))
                in
                Expect.equal 500 (DateTime.getMillisecondsInt date_)
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
