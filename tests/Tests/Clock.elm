module Tests.Clock exposing (suite)

import Expect exposing (Expectation)
import Fuzz exposing (Fuzzer, int, list, string)
import Test exposing (..)
import Tests.DateTime.Clock as Clock
import Time


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
    describe "Clock Test Suite"
        [ fromPosixTests
        , fromRawPartsTests
        , toMillisTests
        , hoursFromIntTests
        , minutesFromIntTests
        , secondsFromIntTests
        , millisecondsFromIntTests
        , incrementHoursTests
        , incrementMinutesTests
        , incrementSecondsTests
        , incrementMillisecondsTests
        , decrementHoursTests
        , decrementMinutesTests
        , decrementSecondsTests
        , decrementMillisecondsTests
        , compareTimeTests
        , compareHoursTests
        , compareMinutesTests
        , compareSecondsTests
        , compareMillisecondsTests
        ]


fromPosixTests : Test
fromPosixTests =
    let
        time =
            -- This timestamp is equivalent to Fri Dec 21 2018 15:45:30 GMT+0000
            Clock.fromPosix (Time.millisToPosix 1545407130000)
    in
    describe "Clock.fromPosix Test Suite"
        [ test "Hours validation"
            (\_ ->
                Expect.equal 15 (Clock.hoursToInt (Clock.getHours time))
            )
        , test "Minutes validation"
            (\_ ->
                Expect.equal 45 (Clock.minutesToInt (Clock.getMinutes time))
            )
        , test "Seconds validation"
            (\_ ->
                Expect.equal 30 (Clock.secondsToInt (Clock.getSeconds time))
            )
        , test "Milliseconds validation"
            (\_ ->
                Expect.equal 0 (Clock.millisecondsToInt (Clock.getMilliseconds time))
            )
        , test "Milliseconds second validation"
            (\_ ->
                let
                    time_ =
                        Clock.fromPosix (Time.millisToPosix (1545407130000 + 500))
                in
                Expect.equal 500 (Clock.millisecondsToInt (Clock.getMilliseconds time_))
            )
        ]


fromRawPartsTests : Test
fromRawPartsTests =
    let
        time =
            Clock.fromRawParts { hours = 15, minutes = 45, seconds = 30, milliseconds = 500 }
    in
    describe "Clock.fromRawParts Test Suite"
        [ test "Hours validation"
            (\_ ->
                Expect.equal (Just 15) <|
                    Maybe.map (Clock.hoursToInt << Clock.getHours) time
            )
        , test "Minutes validation"
            (\_ ->
                Expect.equal (Just 45) <|
                    Maybe.map (Clock.minutesToInt << Clock.getMinutes) time
            )
        , test "Seconds validation"
            (\_ ->
                Expect.equal (Just 30) <|
                    Maybe.map (Clock.secondsToInt << Clock.getSeconds) time
            )
        , test "Milliseconds validation"
            (\_ ->
                Expect.equal (Just 500) <|
                    Maybe.map (Clock.millisecondsToInt << Clock.getMilliseconds) time
            )
        , test "Zero Milliseconds validation"
            (\_ ->
                let
                    validMilliseconds =
                        Clock.fromRawParts { hours = 23, minutes = 30, seconds = 30, milliseconds = 0 }
                in
                Expect.equal (Just 0) <|
                    Maybe.map (Clock.millisecondsToInt << Clock.getMilliseconds) validMilliseconds
            )
        , test "Invalid Hours validation"
            (\_ ->
                let
                    invalidHoursTime =
                        Clock.fromRawParts { hours = 24, minutes = 15, seconds = 30, milliseconds = 0 }
                in
                Expect.equal Nothing <|
                    Maybe.map (Clock.hoursToInt << Clock.getHours) invalidHoursTime
            )
        , test "Invalid Minutes validation"
            (\_ ->
                let
                    invalidMinutesTime =
                        Clock.fromRawParts { hours = 23, minutes = 60, seconds = 30, milliseconds = 0 }
                in
                Expect.equal Nothing <|
                    Maybe.map (Clock.minutesToInt << Clock.getMinutes) invalidMinutesTime
            )
        , test "Invalid Seconds validation"
            (\_ ->
                let
                    invalidSecondsTime =
                        Clock.fromRawParts { hours = 23, minutes = 30, seconds = 60, milliseconds = 0 }
                in
                Expect.equal Nothing <|
                    Maybe.map (Clock.secondsToInt << Clock.getSeconds) invalidSecondsTime
            )
        , test "Invalid Milliseconds validation"
            (\_ ->
                let
                    invalidMillisecondsTime =
                        Clock.fromRawParts { hours = 23, minutes = 30, seconds = 30, milliseconds = 1000 }
                in
                Expect.equal Nothing <|
                    Maybe.map (Clock.millisecondsToInt << Clock.getMilliseconds) invalidMillisecondsTime
            )
        ]


toMillisTests : Test
toMillisTests =
    describe "Clock.toMillis Test Suite"
        [ test "Clock.fromPosix > Clock.toMillis conversion test"
            (\_ ->
                let
                    time =
                        -- This timestamp is equivalent to Fri Dec 21 2018 15:45:30 GMT+0000
                        Clock.fromPosix (Time.millisToPosix 1545407130000)

                    expectedMillis =
                        (millisInAnHour * 15)
                            + (millisInAMinute * 45)
                            + (millisInASecond * 30)
                in
                Expect.equal expectedMillis (Clock.toMillis time)
            )
        , test "Clock.fromRawParts > Clock.toMillis conversion test"
            (\_ ->
                let
                    time =
                        -- This timestamp is equivalent to Fri Dec 21 2018 15:45:30 GMT+0000
                        Clock.fromRawParts { hours = 15, minutes = 45, seconds = 30, milliseconds = 0 }

                    expectedMillis =
                        (millisInAnHour * 15)
                            + (millisInAMinute * 45)
                            + (millisInASecond * 30)
                in
                Expect.equal (Just expectedMillis) <|
                    Maybe.map Clock.toMillis time
            )
        ]


hoursFromIntTests : Test
hoursFromIntTests =
    describe "Clock.hoursFromInt Test Suite"
        [ test "Lowest valid hours test"
            (\_ ->
                Expect.equal (Just (Clock.Hour 0)) (Clock.hoursFromInt 0)
            )
        , test "Highest valid hours test"
            (\_ ->
                Expect.equal (Just (Clock.Hour 23)) (Clock.hoursFromInt 23)
            )
        , test "Longest invalid hours test"
            (\_ ->
                Expect.equal Nothing (Clock.hoursFromInt -1)
            )
        , test "Highest invalid hours test"
            (\_ ->
                Expect.equal Nothing (Clock.hoursFromInt 24)
            )
        ]


minutesFromIntTests : Test
minutesFromIntTests =
    describe "Clock.minutesFromInt Test Suite"
        [ test "Lowest valid minutes test"
            (\_ ->
                Expect.equal (Just (Clock.Minute 0)) (Clock.minutesFromInt 0)
            )
        , test "Highest valid minutes test"
            (\_ ->
                Expect.equal (Just (Clock.Minute 59)) (Clock.minutesFromInt 59)
            )
        , test "Longest invalid minutes test"
            (\_ ->
                Expect.equal Nothing (Clock.minutesFromInt -1)
            )
        , test "Highest invalid minutes test"
            (\_ ->
                Expect.equal Nothing (Clock.minutesFromInt 60)
            )
        ]


secondsFromIntTests : Test
secondsFromIntTests =
    describe "Clock.secondsFromInt Test Suite"
        [ test "Lowest valid seconds test"
            (\_ ->
                Expect.equal (Just (Clock.Second 0)) (Clock.secondsFromInt 0)
            )
        , test "Highest valid seconds test"
            (\_ ->
                Expect.equal (Just (Clock.Second 59)) (Clock.secondsFromInt 59)
            )
        , test "Longest invalid seconds test"
            (\_ ->
                Expect.equal Nothing (Clock.secondsFromInt -1)
            )
        , test "Highest invalid seconds test"
            (\_ ->
                Expect.equal Nothing (Clock.secondsFromInt 60)
            )
        ]


millisecondsFromIntTests : Test
millisecondsFromIntTests =
    describe "Clock.millisecondsFromInt Test Suite"
        [ test "Lowest valid milliseconds test"
            (\_ ->
                Expect.equal (Just (Clock.Millisecond 0)) (Clock.millisecondsFromInt 0)
            )
        , test "Highest valid milliseconds test"
            (\_ ->
                Expect.equal (Just (Clock.Millisecond 999)) (Clock.millisecondsFromInt 999)
            )
        , test "Longest invalid milliseconds test"
            (\_ ->
                Expect.equal Nothing (Clock.millisecondsFromInt -1)
            )
        , test "Highest invalid milliseconds test"
            (\_ ->
                Expect.equal Nothing (Clock.millisecondsFromInt 1000)
            )
        ]


incrementHoursTests : Test
incrementHoursTests =
    describe "Clock.incrementHours Test Suite"
        [ test "Normal case hour increment"
            (\_ ->
                let
                    ( startTime, expectedTime ) =
                        ( Clock.fromRawParts { hours = 0, minutes = 0, seconds = 0, milliseconds = 0 }
                        , Clock.fromRawParts { hours = 1, minutes = 0, seconds = 0, milliseconds = 0 }
                        )

                    res =
                        Maybe.map Clock.incrementHours startTime
                in
                case ( res, expectedTime ) of
                    ( Just r, Just expected ) ->
                        Expect.equal ( expected, False ) r

                    _ ->
                        Expect.fail "Failed to construct Time from raw parts"
            )
        , test "Upper hour limit case increment"
            (\_ ->
                let
                    ( startTime, expectedTime ) =
                        ( Clock.fromRawParts { hours = 23, minutes = 0, seconds = 0, milliseconds = 0 }
                        , Clock.fromRawParts { hours = 0, minutes = 0, seconds = 0, milliseconds = 0 }
                        )

                    res =
                        Maybe.map Clock.incrementHours startTime
                in
                case ( res, expectedTime ) of
                    ( Just r, Just expected ) ->
                        Expect.equal ( expected, True ) r

                    _ ->
                        Expect.fail "Failed to construct Time from raw parts"
            )
        ]


decrementHoursTests : Test
decrementHoursTests =
    describe "Clock.decrementHours Test Suite"
        [ test "Normal case hour decrement"
            (\_ ->
                let
                    ( startTime, expectedTime ) =
                        ( Clock.fromRawParts { hours = 1, minutes = 0, seconds = 0, milliseconds = 0 }
                        , Clock.fromRawParts { hours = 0, minutes = 0, seconds = 0, milliseconds = 0 }
                        )

                    res =
                        Maybe.map Clock.decrementHours startTime
                in
                case ( res, expectedTime ) of
                    ( Just r, Just expected ) ->
                        Expect.equal ( expected, False ) r

                    _ ->
                        Expect.fail "Failed to construct Time from raw parts"
            )
        , test "Lower hour limit case decrement"
            (\_ ->
                let
                    ( startTime, expectedTime ) =
                        ( Clock.fromRawParts { hours = 0, minutes = 0, seconds = 0, milliseconds = 0 }
                        , Clock.fromRawParts { hours = 23, minutes = 0, seconds = 0, milliseconds = 0 }
                        )

                    res =
                        Maybe.map Clock.decrementHours startTime
                in
                case ( res, expectedTime ) of
                    ( Just r, Just expected ) ->
                        Expect.equal ( expected, True ) r

                    _ ->
                        Expect.fail "Failed to construct Time from raw parts"
            )
        ]


incrementMinutesTests : Test
incrementMinutesTests =
    describe "Clock.incrementMinutes Test Suite"
        [ test "Normal case minute increment"
            (\_ ->
                let
                    ( startTime, expectedTime ) =
                        ( Clock.fromRawParts { hours = 0, minutes = 0, seconds = 0, milliseconds = 0 }
                        , Clock.fromRawParts { hours = 0, minutes = 1, seconds = 0, milliseconds = 0 }
                        )

                    res =
                        Maybe.map Clock.incrementMinutes startTime
                in
                case ( res, expectedTime ) of
                    ( Just r, Just expected ) ->
                        Expect.equal ( expected, False ) r

                    _ ->
                        Expect.fail "Failed to construct Time from raw parts"
            )
        , test "Upper minute limit case increment"
            (\_ ->
                let
                    ( startTime, expectedTime ) =
                        ( Clock.fromRawParts { hours = 0, minutes = 59, seconds = 0, milliseconds = 0 }
                        , Clock.fromRawParts { hours = 1, minutes = 0, seconds = 0, milliseconds = 0 }
                        )

                    res =
                        Maybe.map Clock.incrementMinutes startTime
                in
                case ( res, expectedTime ) of
                    ( Just r, Just expected ) ->
                        Expect.equal ( expected, False ) r

                    _ ->
                        Expect.fail "Failed to construct Time from raw parts"
            )
        , test "Upper minute and hour limit case increment"
            (\_ ->
                let
                    ( startTime, expectedTime ) =
                        ( Clock.fromRawParts { hours = 23, minutes = 59, seconds = 0, milliseconds = 0 }
                        , Clock.fromRawParts { hours = 0, minutes = 0, seconds = 0, milliseconds = 0 }
                        )

                    res =
                        Maybe.map Clock.incrementMinutes startTime
                in
                case ( res, expectedTime ) of
                    ( Just r, Just expected ) ->
                        Expect.equal ( expected, True ) r

                    _ ->
                        Expect.fail "Failed to construct Time from raw parts"
            )
        ]


decrementMinutesTests : Test
decrementMinutesTests =
    describe "Clock.decrementMinutes Test Suite"
        [ test "Normal case minute decrement"
            (\_ ->
                let
                    ( startTime, expectedTime ) =
                        ( Clock.fromRawParts { hours = 0, minutes = 1, seconds = 0, milliseconds = 0 }
                        , Clock.fromRawParts { hours = 0, minutes = 0, seconds = 0, milliseconds = 0 }
                        )

                    res =
                        Maybe.map Clock.decrementMinutes startTime
                in
                case ( res, expectedTime ) of
                    ( Just r, Just expected ) ->
                        Expect.equal ( expected, False ) r

                    _ ->
                        Expect.fail "Failed to construct Time from raw parts"
            )
        , test "Lower minute limit case decrement"
            (\_ ->
                let
                    ( startTime, expectedTime ) =
                        ( Clock.fromRawParts { hours = 1, minutes = 0, seconds = 0, milliseconds = 0 }
                        , Clock.fromRawParts { hours = 0, minutes = 59, seconds = 0, milliseconds = 0 }
                        )

                    res =
                        Maybe.map Clock.decrementMinutes startTime
                in
                case ( res, expectedTime ) of
                    ( Just r, Just expected ) ->
                        Expect.equal ( expected, False ) r

                    _ ->
                        Expect.fail "Failed to construct Time from raw parts"
            )
        , test "Lower minute and hour limit case decrement"
            (\_ ->
                let
                    ( startTime, expectedTime ) =
                        ( Clock.fromRawParts { hours = 0, minutes = 0, seconds = 0, milliseconds = 0 }
                        , Clock.fromRawParts { hours = 23, minutes = 59, seconds = 0, milliseconds = 0 }
                        )

                    res =
                        Maybe.map Clock.decrementMinutes startTime
                in
                case ( res, expectedTime ) of
                    ( Just r, Just expected ) ->
                        Expect.equal ( expected, True ) r

                    _ ->
                        Expect.fail "Failed to construct Time from raw parts"
            )
        ]


incrementSecondsTests : Test
incrementSecondsTests =
    describe "Clock.incrementSeconds Test Suite"
        [ test "Normal case seconds increment"
            (\_ ->
                let
                    ( startTime, expectedTime ) =
                        ( Clock.fromRawParts { hours = 0, minutes = 0, seconds = 0, milliseconds = 0 }
                        , Clock.fromRawParts { hours = 0, minutes = 0, seconds = 1, milliseconds = 0 }
                        )

                    res =
                        Maybe.map Clock.incrementSeconds startTime
                in
                case ( res, expectedTime ) of
                    ( Just r, Just expected ) ->
                        Expect.equal ( expected, False ) r

                    _ ->
                        Expect.fail "Failed to construct Time from raw parts"
            )
        , test "Upper seconds limit case increment"
            (\_ ->
                let
                    ( startTime, expectedTime ) =
                        ( Clock.fromRawParts { hours = 0, minutes = 0, seconds = 59, milliseconds = 0 }
                        , Clock.fromRawParts { hours = 0, minutes = 1, seconds = 0, milliseconds = 0 }
                        )

                    res =
                        Maybe.map Clock.incrementSeconds startTime
                in
                case ( res, expectedTime ) of
                    ( Just r, Just expected ) ->
                        Expect.equal ( expected, False ) r

                    _ ->
                        Expect.fail "Failed to construct Time from raw parts"
            )
        , test "Upper seconds and minute limit case increment"
            (\_ ->
                let
                    ( startTime, expectedTime ) =
                        ( Clock.fromRawParts { hours = 0, minutes = 59, seconds = 59, milliseconds = 0 }
                        , Clock.fromRawParts { hours = 1, minutes = 0, seconds = 0, milliseconds = 0 }
                        )

                    res =
                        Maybe.map Clock.incrementSeconds startTime
                in
                case ( res, expectedTime ) of
                    ( Just r, Just expected ) ->
                        Expect.equal ( expected, False ) r

                    _ ->
                        Expect.fail "Failed to construct Time from raw parts"
            )
        , test "Upper seconds, minute and hour limit case increment"
            (\_ ->
                let
                    ( startTime, expectedTime ) =
                        ( Clock.fromRawParts { hours = 23, minutes = 59, seconds = 59, milliseconds = 0 }
                        , Clock.fromRawParts { hours = 0, minutes = 0, seconds = 0, milliseconds = 0 }
                        )

                    res =
                        Maybe.map Clock.incrementSeconds startTime
                in
                case ( res, expectedTime ) of
                    ( Just r, Just expected ) ->
                        Expect.equal ( expected, True ) r

                    _ ->
                        Expect.fail "Failed to construct Time from raw parts"
            )
        ]


decrementSecondsTests : Test
decrementSecondsTests =
    describe "Clock.decrementSeconds Test Suite"
        [ test "Normal case seconds decrement"
            (\_ ->
                let
                    ( startTime, expectedTime ) =
                        ( Clock.fromRawParts { hours = 0, minutes = 0, seconds = 1, milliseconds = 0 }
                        , Clock.fromRawParts { hours = 0, minutes = 0, seconds = 0, milliseconds = 0 }
                        )

                    res =
                        Maybe.map Clock.decrementSeconds startTime
                in
                case ( res, expectedTime ) of
                    ( Just r, Just expected ) ->
                        Expect.equal ( expected, False ) r

                    _ ->
                        Expect.fail "Failed to construct Time from raw parts"
            )
        , test "Lower seconds limit case decrement"
            (\_ ->
                let
                    ( startTime, expectedTime ) =
                        ( Clock.fromRawParts { hours = 0, minutes = 1, seconds = 0, milliseconds = 0 }
                        , Clock.fromRawParts { hours = 0, minutes = 0, seconds = 59, milliseconds = 0 }
                        )

                    res =
                        Maybe.map Clock.decrementSeconds startTime
                in
                case ( res, expectedTime ) of
                    ( Just r, Just expected ) ->
                        Expect.equal ( expected, False ) r

                    _ ->
                        Expect.fail "Failed to construct Time from raw parts"
            )
        , test "Lower seconds and minute limit case decrement"
            (\_ ->
                let
                    ( startTime, expectedTime ) =
                        ( Clock.fromRawParts { hours = 1, minutes = 0, seconds = 0, milliseconds = 0 }
                        , Clock.fromRawParts { hours = 0, minutes = 59, seconds = 59, milliseconds = 0 }
                        )

                    res =
                        Maybe.map Clock.decrementSeconds startTime
                in
                case ( res, expectedTime ) of
                    ( Just r, Just expected ) ->
                        Expect.equal ( expected, False ) r

                    _ ->
                        Expect.fail "Failed to construct Time from raw parts"
            )
        , test "Lower seconds, minute and hour limit case decrement"
            (\_ ->
                let
                    ( startTime, expectedTime ) =
                        ( Clock.fromRawParts { hours = 0, minutes = 0, seconds = 0, milliseconds = 0 }
                        , Clock.fromRawParts { hours = 23, minutes = 59, seconds = 59, milliseconds = 0 }
                        )

                    res =
                        Maybe.map Clock.decrementSeconds startTime
                in
                case ( res, expectedTime ) of
                    ( Just r, Just expected ) ->
                        Expect.equal ( expected, True ) r

                    _ ->
                        Expect.fail "Failed to construct Time from raw parts"
            )
        ]


incrementMillisecondsTests : Test
incrementMillisecondsTests =
    describe "Clock.incrementMilliseconds Test Suite"
        [ test "Normal case milliseconds increment"
            (\_ ->
                let
                    ( startTime, expectedTime ) =
                        ( Clock.fromRawParts { hours = 0, minutes = 0, seconds = 0, milliseconds = 0 }
                        , Clock.fromRawParts { hours = 0, minutes = 0, seconds = 0, milliseconds = 1 }
                        )

                    res =
                        Maybe.map Clock.incrementMilliseconds startTime
                in
                case ( res, expectedTime ) of
                    ( Just r, Just expected ) ->
                        Expect.equal ( expected, False ) r

                    _ ->
                        Expect.fail "Failed to construct Time from raw parts"
            )
        , test "Upper milliseconds limit case increment"
            (\_ ->
                let
                    ( startTime, expectedTime ) =
                        ( Clock.fromRawParts { hours = 0, minutes = 0, seconds = 0, milliseconds = 999 }
                        , Clock.fromRawParts { hours = 0, minutes = 0, seconds = 1, milliseconds = 0 }
                        )

                    res =
                        Maybe.map Clock.incrementMilliseconds startTime
                in
                case ( res, expectedTime ) of
                    ( Just r, Just expected ) ->
                        Expect.equal ( expected, False ) r

                    _ ->
                        Expect.fail "Failed to construct Time from raw parts"
            )
        , test "Upper milliseconds and seconds limit case increment"
            (\_ ->
                let
                    ( startTime, expectedTime ) =
                        ( Clock.fromRawParts { hours = 0, minutes = 0, seconds = 59, milliseconds = 999 }
                        , Clock.fromRawParts { hours = 0, minutes = 1, seconds = 0, milliseconds = 0 }
                        )

                    res =
                        Maybe.map Clock.incrementMilliseconds startTime
                in
                case ( res, expectedTime ) of
                    ( Just r, Just expected ) ->
                        Expect.equal ( expected, False ) r

                    _ ->
                        Expect.fail "Failed to construct Time from raw parts"
            )
        , test "Upper milliseconds, seconds and minutes limit case increment"
            (\_ ->
                let
                    ( startTime, expectedTime ) =
                        ( Clock.fromRawParts { hours = 0, minutes = 59, seconds = 59, milliseconds = 999 }
                        , Clock.fromRawParts { hours = 1, minutes = 0, seconds = 0, milliseconds = 0 }
                        )

                    res =
                        Maybe.map Clock.incrementMilliseconds startTime
                in
                case ( res, expectedTime ) of
                    ( Just r, Just expected ) ->
                        Expect.equal ( expected, False ) r

                    _ ->
                        Expect.fail "Failed to construct Time from raw parts"
            )
        , test "Upper milliseconds, seconds, minutes and hours limit case increment"
            (\_ ->
                let
                    ( startTime, expectedTime ) =
                        ( Clock.fromRawParts { hours = 23, minutes = 59, seconds = 59, milliseconds = 999 }
                        , Clock.fromRawParts { hours = 0, minutes = 0, seconds = 0, milliseconds = 0 }
                        )

                    res =
                        Maybe.map Clock.incrementMilliseconds startTime
                in
                case ( res, expectedTime ) of
                    ( Just r, Just expected ) ->
                        Expect.equal ( expected, True ) r

                    _ ->
                        Expect.fail "Failed to construct Time from raw parts"
            )
        ]


decrementMillisecondsTests : Test
decrementMillisecondsTests =
    describe "Clock.decrementMilliseconds Test Suite"
        [ test "Normal case milliseconds decrement"
            (\_ ->
                let
                    ( startTime, expectedTime ) =
                        ( Clock.fromRawParts { hours = 0, minutes = 0, seconds = 0, milliseconds = 1 }
                        , Clock.fromRawParts { hours = 0, minutes = 0, seconds = 0, milliseconds = 0 }
                        )

                    res =
                        Maybe.map Clock.decrementMilliseconds startTime
                in
                case ( res, expectedTime ) of
                    ( Just r, Just expected ) ->
                        Expect.equal ( expected, False ) r

                    _ ->
                        Expect.fail "Failed to construct Time from raw parts"
            )
        , test "Lower milliseconds limit case decrement"
            (\_ ->
                let
                    ( startTime, expectedTime ) =
                        ( Clock.fromRawParts { hours = 0, minutes = 0, seconds = 1, milliseconds = 0 }
                        , Clock.fromRawParts { hours = 0, minutes = 0, seconds = 0, milliseconds = 999 }
                        )

                    res =
                        Maybe.map Clock.decrementMilliseconds startTime
                in
                case ( res, expectedTime ) of
                    ( Just r, Just expected ) ->
                        Expect.equal ( expected, False ) r

                    _ ->
                        Expect.fail "Failed to construct Time from raw parts"
            )
        , test "Lower milliseconds and seconds limit case decrement"
            (\_ ->
                let
                    ( startTime, expectedTime ) =
                        ( Clock.fromRawParts { hours = 0, minutes = 1, seconds = 0, milliseconds = 0 }
                        , Clock.fromRawParts { hours = 0, minutes = 0, seconds = 59, milliseconds = 999 }
                        )

                    res =
                        Maybe.map Clock.decrementMilliseconds startTime
                in
                case ( res, expectedTime ) of
                    ( Just r, Just expected ) ->
                        Expect.equal ( expected, False ) r

                    _ ->
                        Expect.fail "Failed to construct Time from raw parts"
            )
        , test "Lower milliseconds, seconds and minutes limit case decrement"
            (\_ ->
                let
                    ( startTime, expectedTime ) =
                        ( Clock.fromRawParts { hours = 1, minutes = 0, seconds = 0, milliseconds = 0 }
                        , Clock.fromRawParts { hours = 0, minutes = 59, seconds = 59, milliseconds = 999 }
                        )

                    res =
                        Maybe.map Clock.decrementMilliseconds startTime
                in
                case ( res, expectedTime ) of
                    ( Just r, Just expected ) ->
                        Expect.equal ( expected, False ) r

                    _ ->
                        Expect.fail "Failed to construct Time from raw parts"
            )
        , test "Lower milliseconds, seconds, minutes and hours limit case decrement"
            (\_ ->
                let
                    ( startTime, expectedTime ) =
                        ( Clock.fromRawParts { hours = 0, minutes = 0, seconds = 0, milliseconds = 0 }
                        , Clock.fromRawParts { hours = 23, minutes = 59, seconds = 59, milliseconds = 999 }
                        )

                    res =
                        Maybe.map Clock.decrementMilliseconds startTime
                in
                case ( res, expectedTime ) of
                    ( Just r, Just expected ) ->
                        Expect.equal ( expected, True ) r

                    _ ->
                        Expect.fail "Failed to construct Time from raw parts"
            )
        ]


compareTimeTests : Test
compareTimeTests =
    let
        ( hoursTime, hoursTime2 ) =
            ( Clock.fromRawParts { hours = 15, minutes = 0, seconds = 0, milliseconds = 0 }
            , Clock.fromRawParts { hours = 16, minutes = 0, seconds = 0, milliseconds = 0 }
            )

        ( minutesTime, minutesTime2 ) =
            ( Clock.fromRawParts { hours = 15, minutes = 0, seconds = 0, milliseconds = 0 }
            , Clock.fromRawParts { hours = 15, minutes = 1, seconds = 0, milliseconds = 0 }
            )

        ( secondTime, secondTime2 ) =
            ( Clock.fromRawParts { hours = 15, minutes = 0, seconds = 0, milliseconds = 0 }
            , Clock.fromRawParts { hours = 15, minutes = 0, seconds = 1, milliseconds = 0 }
            )

        ( millisecondsTime, millisecondsTime2 ) =
            ( Clock.fromRawParts { hours = 15, minutes = 0, seconds = 0, milliseconds = 0 }
            , Clock.fromRawParts { hours = 15, minutes = 0, seconds = 0, milliseconds = 1 }
            )

        time =
            Clock.fromRawParts { hours = 15, minutes = 30, seconds = 45, milliseconds = 500 }
    in
    describe "Clock.compareTime Test Suite"
        [ test "Lesser than test case with comparison on hours"
            (\_ ->
                Expect.equal (Just LT) (Maybe.map2 Clock.compareTime hoursTime hoursTime2)
            )
        , test "Greater than test case with comparison on hours"
            (\_ ->
                Expect.equal (Just GT) (Maybe.map2 Clock.compareTime hoursTime2 hoursTime)
            )
        , test "Lesser than test case with comparison on minutes"
            (\_ ->
                Expect.equal (Just LT) (Maybe.map2 Clock.compareTime hoursTime hoursTime2)
            )
        , test "Greater than test case with comparison on minutes"
            (\_ ->
                Expect.equal (Just GT) (Maybe.map2 Clock.compareTime hoursTime2 hoursTime)
            )
        , test "Lesser than test case with comparison on seconds"
            (\_ ->
                Expect.equal (Just LT) (Maybe.map2 Clock.compareTime secondTime secondTime2)
            )
        , test "Greater than test case with comparison on seconds"
            (\_ ->
                Expect.equal (Just GT) (Maybe.map2 Clock.compareTime secondTime2 secondTime)
            )
        , test "Lesser than test case with comparison on milliseconds"
            (\_ ->
                Expect.equal (Just LT) (Maybe.map2 Clock.compareTime millisecondsTime millisecondsTime2)
            )
        , test "Greater than test case with comparison on milliseconds"
            (\_ ->
                Expect.equal (Just GT) (Maybe.map2 Clock.compareTime millisecondsTime2 millisecondsTime)
            )
        , test "Equality test case"
            (\_ ->
                Expect.equal (Just EQ) (Maybe.map2 Clock.compareTime time time)
            )
        ]


compareHoursTests : Test
compareHoursTests =
    let
        ( time, time2 ) =
            ( Clock.fromRawParts { hours = 15, minutes = 0, seconds = 0, milliseconds = 0 }
            , Clock.fromRawParts { hours = 16, minutes = 0, seconds = 0, milliseconds = 0 }
            )
    in
    describe "Clock.compareHours Test Suite"
        [ test "Lesser than test case"
            (\_ ->
                Expect.equal (Just LT) (Maybe.map2 Clock.compareHours (Maybe.map Clock.getHours time) (Maybe.map Clock.getHours time2))
            )
        , test "Greater than test case"
            (\_ ->
                Expect.equal (Just GT) (Maybe.map2 Clock.compareHours (Maybe.map Clock.getHours time2) (Maybe.map Clock.getHours time))
            )
        , test "Equality test case"
            (\_ ->
                Expect.equal (Just EQ) (Maybe.map2 Clock.compareHours (Maybe.map Clock.getHours time) (Maybe.map Clock.getHours time))
            )
        ]


compareMinutesTests : Test
compareMinutesTests =
    let
        ( time, time2 ) =
            ( Clock.fromRawParts { hours = 15, minutes = 0, seconds = 0, milliseconds = 0 }
            , Clock.fromRawParts { hours = 15, minutes = 30, seconds = 0, milliseconds = 0 }
            )
    in
    describe "Clock.compareMinutes Test Suite"
        [ test "Lesser than test case"
            (\_ ->
                Expect.equal (Just LT) (Maybe.map2 Clock.compareMinutes (Maybe.map Clock.getMinutes time) (Maybe.map Clock.getMinutes time2))
            )
        , test "Greater than test case"
            (\_ ->
                Expect.equal (Just GT) (Maybe.map2 Clock.compareMinutes (Maybe.map Clock.getMinutes time2) (Maybe.map Clock.getMinutes time))
            )
        , test "Equality test case"
            (\_ ->
                Expect.equal (Just EQ) (Maybe.map2 Clock.compareMinutes (Maybe.map Clock.getMinutes time) (Maybe.map Clock.getMinutes time))
            )
        ]


compareSecondsTests : Test
compareSecondsTests =
    let
        ( time, time2 ) =
            ( Clock.fromRawParts { hours = 15, minutes = 0, seconds = 0, milliseconds = 0 }
            , Clock.fromRawParts { hours = 15, minutes = 0, seconds = 30, milliseconds = 0 }
            )
    in
    describe "Clock.compareSeconds Test Suite"
        [ test "Lesser than test case"
            (\_ ->
                Expect.equal (Just LT) (Maybe.map2 Clock.compareSeconds (Maybe.map Clock.getSeconds time) (Maybe.map Clock.getSeconds time2))
            )
        , test "Greater than test case"
            (\_ ->
                Expect.equal (Just GT) (Maybe.map2 Clock.compareSeconds (Maybe.map Clock.getSeconds time2) (Maybe.map Clock.getSeconds time))
            )
        , test "Equality test case"
            (\_ ->
                Expect.equal (Just EQ) (Maybe.map2 Clock.compareSeconds (Maybe.map Clock.getSeconds time) (Maybe.map Clock.getSeconds time))
            )
        ]


compareMillisecondsTests : Test
compareMillisecondsTests =
    let
        ( time, time2 ) =
            ( Clock.fromRawParts { hours = 15, minutes = 0, seconds = 0, milliseconds = 0 }
            , Clock.fromRawParts { hours = 15, minutes = 0, seconds = 0, milliseconds = 500 }
            )
    in
    describe "Clock.compareMilliseconds Test Suite"
        [ test "Lesser than test case"
            (\_ ->
                Expect.equal (Just LT) (Maybe.map2 Clock.compareMilliseconds (Maybe.map Clock.getMilliseconds time) (Maybe.map Clock.getMilliseconds time2))
            )
        , test "Greater than test case"
            (\_ ->
                Expect.equal (Just GT) (Maybe.map2 Clock.compareMilliseconds (Maybe.map Clock.getMilliseconds time2) (Maybe.map Clock.getMilliseconds time))
            )
        , test "Equality test case"
            (\_ ->
                Expect.equal (Just EQ) (Maybe.map2 Clock.compareMilliseconds (Maybe.map Clock.getMilliseconds time) (Maybe.map Clock.getMilliseconds time))
            )
        ]
