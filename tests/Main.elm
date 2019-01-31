module Main exposing (suite)

import Test exposing (Test, describe)
import Tests.Calendar as Calendar
import Tests.Clock as Clock
import Tests.DateTime as DateTime


suite : Test
suite =
    describe "DateTime Tests"
        [ Calendar.suite
        , Clock.suite
        , DateTime.suite
        ]
