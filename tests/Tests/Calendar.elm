module Tests.Calendar exposing (suite)

import Array
import Expect exposing (Expectation)
import Fuzz exposing (Fuzzer, int, list, string)
import Test exposing (..)
import Tests.DateTime.Calendar as Calendar
import Time


testDateMillis : Int
testDateMillis =
    1543276800000


testPosixDate : Calendar.Date
testPosixDate =
    Calendar.fromPosix (Time.millisToPosix testDateMillis)


millisInAnHour : Int
millisInAnHour =
    1000 * 60 * 60


suite : Test
suite =
    describe "Calendar Test Suite"
        [ fromPosixTests
        , fromRawYearMonthDayTests
        , compareDatesTests
        , getNextMonthTests
        , getPreviousMonthTests
        , getPrecedingMonthsTests
        , getFollowingMonthsTest
        , isLeapYearTest
        , lastDayOfTest
        , incrementYearTest
        , decrementYearTest
        , toPosixTest
        , weekdayFromDateTest
        , getDatesInMonthTest
        , getNextDayTest
        , getPreviousDayTest
        , getDateRangeTest
        , yearFromIntTest
        , monthFromIntTest
        , dayFromIntTest
        , fromYearMonthDayTest
        , compareDaysTest
        , compareMonthsTest
        , compareYearsTest
        , fromRawDayTest
        , millisSinceEpochTest
        , millisSinceStartOfTheYearTest
        , millisSinceStartOfTheMonthTest
        ]


fromPosixTests : Test
fromPosixTests =
    describe "Calendar.fromPosix Test Suite"
        [ test "Millisecond to date to millisecond validation"
            (\_ ->
                let
                    posixDateMillis =
                        Calendar.toPosix testPosixDate

                    posixMillis =
                        Time.millisToPosix testDateMillis
                in
                Expect.equal posixDateMillis posixMillis
            )
        , test "Millisecond to date validation"
            (\_ ->
                let
                    date =
                        Calendar.fromPosix (Time.millisToPosix testDateMillis)
                in
                Expect.equal testPosixDate date
            )
        , test "Valid date construction from millis and millis + 12 hours"
            (\_ ->
                let
                    twelveHourMillis =
                        millisInAnHour * 12

                    futureDate =
                        Calendar.fromPosix (Time.millisToPosix (testDateMillis + twelveHourMillis))
                in
                Expect.equal testPosixDate futureDate
            )
        , test "Valid date construction from millis and millis + 24 hours"
            (\_ ->
                let
                    oneDayMillis =
                        millisInAnHour * 24

                    futureDate =
                        Calendar.fromPosix (Time.millisToPosix (testDateMillis + oneDayMillis))
                in
                Expect.notEqual testPosixDate futureDate
            )
        , test "Valid date construction from raw components"
            (\_ ->
                let
                    rawDate =
                        Calendar.fromRawYearMonthDay { rawYear = 2018, rawMonth = 11, rawDay = 27 }
                in
                case rawDate of
                    Just date ->
                        Expect.equal testPosixDate date

                    Nothing ->
                        Expect.fail "Couldn't create date from raw parts"
            )
        ]


fromRawYearMonthDayTests : Test
fromRawYearMonthDayTests =
    let
        ( getYearInt, getMonthInt, getDayInt ) =
            ( Calendar.yearToInt << Calendar.getYear
            , Calendar.monthToInt << Calendar.getMonth
            , Calendar.dayToInt << Calendar.getDay
            )
    in
    describe "Calendar.fromRawYearMonthDay Test Suite"
        [ test "Valid date construction by raw parts"
            (\_ ->
                let
                    rawDate =
                        Calendar.fromRawYearMonthDay { rawYear = 2018, rawMonth = 11, rawDay = 27 }
                in
                case rawDate of
                    Just date ->
                        Expect.equal testPosixDate date

                    Nothing ->
                        Expect.fail "Couldn't create date from raw components"
            )
        , test "Valid date on start of the year from raw parts"
            (\_ ->
                let
                    ( rawDay, rawMonth, rawYear ) =
                        ( 1, 1, 2018 )

                    rawDate =
                        Calendar.fromRawYearMonthDay { rawYear = rawYear, rawMonth = rawMonth, rawDay = rawDay }
                in
                case rawDate of
                    Just date ->
                        Expect.true "Created wrong date from raw components."
                            (getDayInt date == rawDay && getMonthInt date == rawMonth && getYearInt date == rawYear)

                    Nothing ->
                        Expect.fail "Couldn't create date from raw components"
            )
        , test "Valid date on end of the year from raw parts"
            (\_ ->
                let
                    ( rawDay, rawMonth, rawYear ) =
                        ( 31, 12, 2018 )

                    rawDate =
                        Calendar.fromRawYearMonthDay { rawYear = rawYear, rawMonth = rawMonth, rawDay = rawDay }
                in
                case rawDate of
                    Just date ->
                        Expect.true "Created wrong date from raw components."
                            (getDayInt date == rawDay && getMonthInt date == rawMonth && getYearInt date == rawYear)

                    Nothing ->
                        Expect.fail "Couldn't create date from raw components"
            )
        , test "Invalid date construction from invalid year passed in raw components"
            (\_ ->
                let
                    date =
                        Calendar.fromRawYearMonthDay { rawYear = 0, rawMonth = 11, rawDay = 27 }
                in
                Expect.equal date Nothing
            )
        , test "Invalid date construction from invalid month passed in raw components"
            (\_ ->
                let
                    date =
                        Calendar.fromRawYearMonthDay { rawYear = 2018, rawMonth = 13, rawDay = 27 }
                in
                Expect.equal date Nothing
            )
        , test "Invalid date construction from invalid day passed in raw components"
            (\_ ->
                let
                    date =
                        Calendar.fromRawYearMonthDay { rawYear = 2018, rawMonth = 11, rawDay = 31 }
                in
                Expect.equal date Nothing
            )
        , test "Valid 29th of February date construction from raw components"
            (\_ ->
                let
                    date =
                        Calendar.fromRawYearMonthDay { rawYear = 2020, rawMonth = 2, rawDay = 29 }
                in
                Expect.notEqual date Nothing
            )
        , test "Invalid 29th of February date construction from raw components"
            (\_ ->
                let
                    date =
                        Calendar.fromRawYearMonthDay { rawYear = 2019, rawMonth = 2, rawDay = 29 }
                in
                Expect.equal date Nothing
            )
        ]


compareDatesTests : Test
compareDatesTests =
    let
        rawDate =
            Calendar.fromRawYearMonthDay { rawYear = 2018, rawMonth = 11, rawDay = 27 }

        ( nextDayRawDate, nextMonthRawDate, nextYearRawDate ) =
            ( Calendar.fromRawYearMonthDay { rawYear = 2018, rawMonth = 11, rawDay = 28 }
            , Calendar.fromRawYearMonthDay { rawYear = 2018, rawMonth = 12, rawDay = 27 }
            , Calendar.fromRawYearMonthDay { rawYear = 2019, rawMonth = 11, rawDay = 27 }
            )

        ( previousDayRawDate, previousMonthRawDate, previousYearRawDate ) =
            ( Calendar.fromRawYearMonthDay { rawYear = 2018, rawMonth = 11, rawDay = 26 }
            , Calendar.fromRawYearMonthDay { rawYear = 2018, rawMonth = 10, rawDay = 27 }
            , Calendar.fromRawYearMonthDay { rawYear = 2017, rawMonth = 11, rawDay = 27 }
            )

        getDayInt =
            Calendar.dayToInt << Calendar.getDay
    in
    describe "Calendar.compareDates Test Suite"
        [ test "Compare two equal posix dates"
            (\_ ->
                Expect.equal (Calendar.compareDates testPosixDate testPosixDate) EQ
            )
        , test "Compare two equal raw dates"
            (\_ ->
                case rawDate of
                    Just date ->
                        Expect.equal (Calendar.compareDates date date) EQ

                    Nothing ->
                        Expect.fail "Couldn't create date from raw parts"
            )
        , test "Compare two dates with a day difference (Less than case)"
            (\_ ->
                case ( rawDate, nextDayRawDate ) of
                    ( Just date, Just nextDate ) ->
                        Expect.equal (Calendar.compareDates date nextDate) LT

                    _ ->
                        Expect.fail "Couldn't create date from raw parts"
            )
        , test "Compare two dates with a month difference (Less than case)"
            (\_ ->
                case ( rawDate, nextMonthRawDate ) of
                    ( Just date, Just nextDate ) ->
                        Expect.equal (Calendar.compareDates date nextDate) LT

                    _ ->
                        Expect.fail "Couldn't create date from raw parts"
            )
        , test "Compare two dates with a year difference (Less than case)"
            (\_ ->
                case ( rawDate, nextYearRawDate ) of
                    ( Just date, Just nextDate ) ->
                        Expect.equal (Calendar.compareDates date nextDate) LT

                    _ ->
                        Expect.fail "Couldn't create date from raw parts"
            )
        , test "Compare two dates with a day difference (Greater than case)"
            (\_ ->
                case ( rawDate, previousDayRawDate ) of
                    ( Just date, Just previousDate ) ->
                        Expect.equal (Calendar.compareDates date previousDate) GT

                    _ ->
                        Expect.fail "Couldn't create date from raw parts"
            )
        , test "Compare two dates with a month difference (Greater than case)"
            (\_ ->
                case ( rawDate, previousMonthRawDate ) of
                    ( Just date, Just previousDate ) ->
                        Expect.equal (Calendar.compareDates date previousDate) GT

                    _ ->
                        Expect.fail "Couldn't create date from raw parts"
            )
        , test "Compare two dates with a year difference (Greater than case)"
            (\_ ->
                case ( rawDate, previousYearRawDate ) of
                    ( Just date, Just previousDate ) ->
                        Expect.equal (Calendar.compareDates date previousDate) GT

                    _ ->
                        Expect.fail "Couldn't create date from raw parts"
            )
        ]


getNextMonthTests : Test
getNextMonthTests =
    let
        performTest initialDate expectedDate =
            case ( initialDate, expectedDate ) of
                ( Just initial, Just expected ) ->
                    Expect.equal (Calendar.getNextMonth initial) expected

                _ ->
                    Expect.fail "Couldn't create date from raw parts"
    in
    describe "Calendar.getNextMonth Test Suite"
        [ test "getNextMonth using 15th of Nov as the start date"
            (\_ ->
                let
                    ( initialDate, expectedDate ) =
                        ( Calendar.fromRawYearMonthDay { rawYear = 2018, rawMonth = 11, rawDay = 15 }
                        , Calendar.fromRawYearMonthDay { rawYear = 2018, rawMonth = 12, rawDay = 15 }
                        )
                in
                performTest initialDate expectedDate
            )
        , test "getNextMonth using 15th of Dec as the start date"
            (\_ ->
                let
                    ( initialDate, expectedDate ) =
                        ( Calendar.fromRawYearMonthDay { rawYear = 2018, rawMonth = 12, rawDay = 15 }
                        , Calendar.fromRawYearMonthDay { rawYear = 2019, rawMonth = 1, rawDay = 15 }
                        )
                in
                performTest initialDate expectedDate
            )
        , test "getNextMonth using 29th of Jan of a leap year as a start date"
            (\_ ->
                let
                    ( initialDate, expectedDate ) =
                        ( Calendar.fromRawYearMonthDay { rawYear = 2020, rawMonth = 1, rawDay = 29 }
                        , Calendar.fromRawYearMonthDay { rawYear = 2020, rawMonth = 2, rawDay = 29 }
                        )
                in
                performTest initialDate expectedDate
            )
        , test "getNextMonth using 29th of Jan of a non leap year as a start date"
            (\_ ->
                let
                    ( initialDate, expectedDate ) =
                        ( Calendar.fromRawYearMonthDay { rawYear = 2019, rawMonth = 1, rawDay = 29 }
                        , Calendar.fromRawYearMonthDay { rawYear = 2019, rawMonth = 2, rawDay = 28 }
                        )
                in
                performTest initialDate expectedDate
            )
        , test "getNextMonth using 31st of Jan as the start date"
            (\_ ->
                let
                    ( initialDate, expectedDate ) =
                        ( Calendar.fromRawYearMonthDay { rawYear = 2018, rawMonth = 1, rawDay = 31 }
                        , Calendar.fromRawYearMonthDay { rawYear = 2018, rawMonth = 2, rawDay = 28 }
                        )
                in
                performTest initialDate expectedDate
            )
        ]


getPreviousMonthTests : Test
getPreviousMonthTests =
    let
        performTest initialDate expectedDate =
            case ( initialDate, expectedDate ) of
                ( Just initial, Just expected ) ->
                    Expect.equal (Calendar.getPreviousMonth initial) expected

                _ ->
                    Expect.fail "Couldn't create date from raw parts"
    in
    describe "Calendar.getPreviousMonth Test Suite"
        [ test "getPreviousMonth using 15th of Nov as the start date"
            (\_ ->
                let
                    ( initialDate, expectedDate ) =
                        ( Calendar.fromRawYearMonthDay { rawYear = 2018, rawMonth = 11, rawDay = 15 }
                        , Calendar.fromRawYearMonthDay { rawYear = 2018, rawMonth = 10, rawDay = 15 }
                        )
                in
                performTest initialDate expectedDate
            )
        , test "getPreviousMonth using 15th of Jan as the start date"
            (\_ ->
                let
                    ( initialDate, expectedDate ) =
                        ( Calendar.fromRawYearMonthDay { rawYear = 2019, rawMonth = 1, rawDay = 15 }
                        , Calendar.fromRawYearMonthDay { rawYear = 2018, rawMonth = 12, rawDay = 15 }
                        )
                in
                performTest initialDate expectedDate
            )
        , test "getPreviousMonth using 29th of Mar of a leap year as a start date"
            (\_ ->
                let
                    ( initialDate, expectedDate ) =
                        ( Calendar.fromRawYearMonthDay { rawYear = 2020, rawMonth = 3, rawDay = 29 }
                        , Calendar.fromRawYearMonthDay { rawYear = 2020, rawMonth = 2, rawDay = 29 }
                        )
                in
                performTest initialDate expectedDate
            )
        , test "getPreviousMonth using 29th of Mar of a non leap year as a start date"
            (\_ ->
                let
                    ( initialDate, expectedDate ) =
                        ( Calendar.fromRawYearMonthDay { rawYear = 2019, rawMonth = 3, rawDay = 29 }
                        , Calendar.fromRawYearMonthDay { rawYear = 2019, rawMonth = 2, rawDay = 28 }
                        )
                in
                performTest initialDate expectedDate
            )
        , test "getPreviousMonth using 31st of Mar as the start date"
            (\_ ->
                let
                    ( initialDate, expectedDate ) =
                        ( Calendar.fromRawYearMonthDay { rawYear = 2019, rawMonth = 3, rawDay = 31 }
                        , Calendar.fromRawYearMonthDay { rawYear = 2019, rawMonth = 2, rawDay = 28 }
                        )
                in
                performTest initialDate expectedDate
            )
        ]


getPrecedingMonthsTests : Test
getPrecedingMonthsTests =
    let
        testFn =
            Calendar.getPrecedingMonths

        expectedMonths count =
            List.take count (Array.toList <| Calendar.months)
    in
    describe "Calendar.getPrecedingMonths Test Suite"
        [ test "Jan as the given month"
            (\_ -> Expect.equal (testFn Time.Jan) (expectedMonths 0))
        , test "Feb as the given month"
            (\_ -> Expect.equal (testFn Time.Feb) (expectedMonths 1))
        , test "Mar as the given month"
            (\_ -> Expect.equal (testFn Time.Mar) (expectedMonths 2))
        , test "Apr as the given month"
            (\_ -> Expect.equal (testFn Time.Apr) (expectedMonths 3))
        , test "May as the given month"
            (\_ -> Expect.equal (testFn Time.May) (expectedMonths 4))
        , test "Jun as the given month"
            (\_ -> Expect.equal (testFn Time.Jun) (expectedMonths 5))
        , test "Jul as the given month"
            (\_ -> Expect.equal (testFn Time.Jul) (expectedMonths 6))
        , test "Aug as the given month"
            (\_ -> Expect.equal (testFn Time.Aug) (expectedMonths 7))
        , test "Sep as the given month"
            (\_ -> Expect.equal (testFn Time.Sep) (expectedMonths 8))
        , test "Oct as the given month"
            (\_ -> Expect.equal (testFn Time.Oct) (expectedMonths 9))
        , test "Nov as the given month"
            (\_ -> Expect.equal (testFn Time.Nov) (expectedMonths 10))
        , test "Dec as the given month"
            (\_ -> Expect.equal (testFn Time.Dec) (expectedMonths 11))
        ]


getFollowingMonthsTest : Test
getFollowingMonthsTest =
    let
        testFn =
            Calendar.getFollowingMonths

        expectedMonths validMonths =
            List.take validMonths <| List.drop (12 - validMonths) (Array.toList <| Calendar.months)
    in
    describe "Calendar.getFollowingMonths Test Suite"
        [ test "Jan as the given month"
            (\_ -> Expect.equal (testFn Time.Jan) (expectedMonths 11))
        , test "Feb as the given month"
            (\_ -> Expect.equal (testFn Time.Feb) (expectedMonths 10))
        , test "Mar as the given month"
            (\_ -> Expect.equal (testFn Time.Mar) (expectedMonths 9))
        , test "Apr as the given month"
            (\_ -> Expect.equal (testFn Time.Apr) (expectedMonths 8))
        , test "May as the given month"
            (\_ -> Expect.equal (testFn Time.May) (expectedMonths 7))
        , test "Jun as the given month"
            (\_ -> Expect.equal (testFn Time.Jun) (expectedMonths 6))
        , test "Jul as the given month"
            (\_ -> Expect.equal (testFn Time.Jul) (expectedMonths 5))
        , test "Aug as the given month"
            (\_ -> Expect.equal (testFn Time.Aug) (expectedMonths 4))
        , test "Sep as the given month"
            (\_ -> Expect.equal (testFn Time.Sep) (expectedMonths 3))
        , test "Oct as the given month"
            (\_ -> Expect.equal (testFn Time.Oct) (expectedMonths 2))
        , test "Nov as the given month"
            (\_ -> Expect.equal (testFn Time.Nov) (expectedMonths 1))
        , test "Dec as the given month"
            (\_ -> Expect.equal (testFn Time.Dec) (expectedMonths 0))
        ]


isLeapYearTest : Test
isLeapYearTest =
    describe "Calendar.isLeapYear Test Suite"
        [ test "Test with the given year being 2018"
            (\_ ->
                let
                    rawDate =
                        Calendar.fromRawYearMonthDay { rawYear = 2018, rawMonth = 1, rawDay = 1 }
                in
                case rawDate of
                    Just date ->
                        Expect.false "Expected Calendar.isLeapYear to return False for a normal year"
                            (Calendar.isLeapYear (Calendar.getYear date))

                    Nothing ->
                        Expect.fail "Couldn't create date from raw parts"
            )
        , test "Test with the given year being 2020"
            (\_ ->
                let
                    rawDate =
                        Calendar.fromRawYearMonthDay { rawYear = 2020, rawMonth = 1, rawDay = 1 }
                in
                case rawDate of
                    Just date ->
                        Expect.true "Expected Calendar.isLeapYear to return true for a leap year"
                            (Calendar.isLeapYear (Calendar.getYear date))

                    Nothing ->
                        Expect.fail "Couldn't create date from raw parts"
            )
        ]


lastDayOfTest : Test
lastDayOfTest =
    let
        lastIntDayOfMonth year =
            Calendar.dayToInt << Calendar.lastDayOf year

        performTest rawDate validLastDay =
            case rawDate of
                Just date ->
                    Expect.equal (lastIntDayOfMonth (Calendar.getYear date) (Calendar.getMonth date)) validLastDay

                Nothing ->
                    Expect.fail "Couldn't create date from raw parts"
    in
    describe "Calendar.lastDayOf Test Suite"
        [ test "Test with the given month being Jan"
            (\_ ->
                let
                    rawDate =
                        Calendar.fromRawYearMonthDay { rawYear = 2018, rawMonth = 1, rawDay = 1 }
                in
                performTest rawDate 31
            )
        , test "Test with the given month being Feb on a normal year"
            (\_ ->
                let
                    rawDate =
                        Calendar.fromRawYearMonthDay { rawYear = 2018, rawMonth = 2, rawDay = 1 }
                in
                performTest rawDate 28
            )
        , test "Test with the given month being Feb on a leap year"
            (\_ ->
                let
                    rawDate =
                        Calendar.fromRawYearMonthDay { rawYear = 2020, rawMonth = 2, rawDay = 1 }
                in
                performTest rawDate 29
            )
        , test "Test with the given month being Mar on a leap year"
            (\_ ->
                let
                    rawDate =
                        Calendar.fromRawYearMonthDay { rawYear = 2018, rawMonth = 3, rawDay = 1 }
                in
                performTest rawDate 31
            )
        ]


incrementYearTest : Test
incrementYearTest =
    let
        performTest initialDate expectedDate =
            case ( initialDate, expectedDate ) of
                ( Just initial, Just expected ) ->
                    Expect.equal (Calendar.incrementYear initial) expected

                _ ->
                    Expect.fail "Couldn't create date from raw parts"
    in
    describe "Calendar.incrementYear Test Suite"
        [ test "Testing with the given date being 1st of Jan 2019"
            (\_ ->
                let
                    ( initialDate, expectedDate ) =
                        ( Calendar.fromRawYearMonthDay { rawYear = 2019, rawMonth = 1, rawDay = 1 }
                        , Calendar.fromRawYearMonthDay { rawYear = 2020, rawMonth = 1, rawDay = 1 }
                        )
                in
                performTest initialDate expectedDate
            )
        , test "Testing with the given date being 31st of Dec 2019"
            (\_ ->
                let
                    ( initialDate, expectedDate ) =
                        ( Calendar.fromRawYearMonthDay { rawYear = 2019, rawMonth = 12, rawDay = 31 }
                        , Calendar.fromRawYearMonthDay { rawYear = 2020, rawMonth = 12, rawDay = 31 }
                        )
                in
                performTest initialDate expectedDate
            )
        , test "Testing with the given date being 28th of Feb 2019"
            (\_ ->
                let
                    ( initialDate, expectedDate ) =
                        ( Calendar.fromRawYearMonthDay { rawYear = 2019, rawMonth = 2, rawDay = 28 }
                        , Calendar.fromRawYearMonthDay { rawYear = 2020, rawMonth = 2, rawDay = 28 }
                        )
                in
                performTest initialDate expectedDate
            )
        , test "Testing with the given date being 29th of Feb 2020"
            (\_ ->
                let
                    ( initialDate, expectedDate ) =
                        ( Calendar.fromRawYearMonthDay { rawYear = 2020, rawMonth = 2, rawDay = 29 }
                        , Calendar.fromRawYearMonthDay { rawYear = 2021, rawMonth = 2, rawDay = 28 }
                        )
                in
                performTest initialDate expectedDate
            )
        ]


decrementYearTest : Test
decrementYearTest =
    let
        performTest initialDate expectedDate =
            case ( initialDate, expectedDate ) of
                ( Just initial, Just expected ) ->
                    Expect.equal (Calendar.decrementYear initial) expected

                _ ->
                    Expect.fail "Couldn't create date from raw parts"
    in
    describe "Calendar.decrementYearTest Test Suite"
        [ test "Testing with the given date being 1st of Jan 2020"
            {- This test case covers going from the start of
               -- a normal year to the start of a leap year.
            -}
            (\_ ->
                let
                    ( initialDate, expectedDate ) =
                        ( Calendar.fromRawYearMonthDay { rawYear = 2020, rawMonth = 1, rawDay = 1 }
                        , Calendar.fromRawYearMonthDay { rawYear = 2019, rawMonth = 1, rawDay = 1 }
                        )
                in
                performTest initialDate expectedDate
            )
        , test "Testing with the given date being 31st of Dec 2020"
            {- This test case covers going from the end of
               -- a normal year to the end of a leap year.
            -}
            (\_ ->
                let
                    ( initialDate, expectedDate ) =
                        ( Calendar.fromRawYearMonthDay { rawYear = 2020, rawMonth = 12, rawDay = 31 }
                        , Calendar.fromRawYearMonthDay { rawYear = 2019, rawMonth = 12, rawDay = 31 }
                        )
                in
                performTest initialDate expectedDate
            )
        , test "Testing with the given date being 29th of Feb 2020"
            {- This test case covers going from the 29th of Feb on a leap year
               -- to the 28th of Feb on a normal year.
            -}
            (\_ ->
                let
                    ( initialDate, expectedDate ) =
                        ( Calendar.fromRawYearMonthDay { rawYear = 2020, rawMonth = 2, rawDay = 29 }
                        , Calendar.fromRawYearMonthDay { rawYear = 2019, rawMonth = 2, rawDay = 28 }
                        )
                in
                performTest initialDate expectedDate
            )
        , test "Testing with the given date being 28th of Feb 2021"
            {- This test case covers going from the 28th of Feb on a normal year
               -- to the 28th of Feb on a leap year.
            -}
            (\_ ->
                let
                    ( initialDate, expectedDate ) =
                        ( Calendar.fromRawYearMonthDay { rawYear = 2021, rawMonth = 2, rawDay = 28 }
                        , Calendar.fromRawYearMonthDay { rawYear = 2020, rawMonth = 2, rawDay = 28 }
                        )
                in
                performTest initialDate expectedDate
            )
        ]


toPosixTest : Test
toPosixTest =
    let
        performTest rawDate expectedTimestamp =
            case rawDate of
                Just date ->
                    Expect.equal (Calendar.toPosix date) (Time.millisToPosix expectedTimestamp)

                Nothing ->
                    Expect.fail "Couldn't create date from raw parts"
    in
    describe "Calendar.toPosix Test Suite"
        [ test "Testing with the given date being 1st of Jan 2019"
            (\_ ->
                let
                    ( rawDate, expectedTimestamp ) =
                        ( Calendar.fromRawYearMonthDay { rawYear = 2019, rawMonth = 1, rawDay = 1 }
                        , 1546300800000
                        )
                in
                performTest rawDate expectedTimestamp
            )
        , test "Testing with the given date being 28th of Feb 2019"
            (\_ ->
                let
                    ( rawDate, expectedTimestamp ) =
                        ( Calendar.fromRawYearMonthDay { rawYear = 2019, rawMonth = 2, rawDay = 28 }
                        , 1551312000000
                        )
                in
                performTest rawDate expectedTimestamp
            )
        , test "Testing with the given date being 29th of Feb 2020 ( leap year )"
            (\_ ->
                let
                    ( rawDate, expectedTimestamp ) =
                        ( Calendar.fromRawYearMonthDay { rawYear = 2020, rawMonth = 2, rawDay = 29 }
                        , 1582934400000
                        )
                in
                performTest rawDate expectedTimestamp
            )
        , test "Testing with the given date being 1st of Mar 2020 ( leap year )"
            (\_ ->
                let
                    ( rawDate, expectedTimestamp ) =
                        ( Calendar.fromRawYearMonthDay { rawYear = 2020, rawMonth = 3, rawDay = 1 }
                        , 1583020800000
                        )
                in
                performTest rawDate expectedTimestamp
            )
        , test "Testing with a constructed date through Calendar.fromPosix being 29th of Feb 2020 23:59:59. (leap year)"
            (\_ ->
                let
                    ( posixDate, expectedTimestamp ) =
                        ( Calendar.fromPosix (Time.millisToPosix 1583020799000)
                        , Time.millisToPosix 1582934400000
                        )
                in
                Expect.equal (Calendar.toPosix posixDate) expectedTimestamp
            )
        , test "Testing with a constructed date through Calendar.fromPosix being 1st of Mar 2020 00:00:00. (leap year)"
            (\_ ->
                let
                    ( posixDate, expectedTimestamp ) =
                        ( Calendar.fromPosix (Time.millisToPosix 1583020800000)
                        , Time.millisToPosix 1583020800000
                        )
                in
                Expect.equal (Calendar.toPosix posixDate) expectedTimestamp
            )
        , test "Testing with a constructed date through Calendar.fromPosix being 26 of Aug 2019 12:00:00."
            (\_ ->
                let
                    ( posixDate, expectedTimestamp ) =
                        ( Calendar.fromPosix (Time.millisToPosix 1566820800000)
                        , Time.millisToPosix 1566777600000
                        )
                in
                Expect.equal (Calendar.toPosix posixDate) expectedTimestamp
            )
        , test "Testing with a constructed date through Calendar.fromPosix being 15 of Jun 2019 00:00:00."
            (\_ ->
                let
                    ( posixDate, expectedTimestamp ) =
                        ( Calendar.fromPosix (Time.millisToPosix 1560556800000)
                        , Time.millisToPosix 1560556800000
                        )
                in
                Expect.equal (Calendar.toPosix posixDate) expectedTimestamp
            )
        ]


weekdayFromDateTest : Test
weekdayFromDateTest =
    describe "Calendar.weekdayFromDate Test Suite"
        [ test "Testing with the given date being 27th of November 2018"
            (\_ ->
                Expect.equal (Calendar.weekdayFromDate testPosixDate) Time.Tue
            )
        , test "Testing with the given date being 29th of February 2020"
            (\_ ->
                let
                    rawDate =
                        Calendar.fromRawYearMonthDay { rawYear = 2020, rawMonth = 2, rawDay = 29 }
                in
                case rawDate of
                    Just date ->
                        Expect.equal (Calendar.weekdayFromDate date) Time.Sat

                    _ ->
                        Expect.fail "Couldn't create date from raw parts"
            )
        ]


getDatesInMonthTest : Test
getDatesInMonthTest =
    let
        getDatesInMonth date =
            Calendar.getDatesInMonth (Calendar.getYear date) (Calendar.getMonth date)

        performTest rawDate datesCount =
            case rawDate of
                Just date ->
                    Expect.equal (List.length (getDatesInMonth date)) datesCount

                Nothing ->
                    Expect.fail "Couldn't create date from raw parts"
    in
    describe "Calendar.getMonthDates Test Suite"
        [ test "Testing with the given month being November of 2018"
            (\_ ->
                let
                    rawDate =
                        Calendar.fromRawYearMonthDay { rawYear = 2018, rawMonth = 11, rawDay = 1 }
                in
                performTest rawDate 30
            )
        , test "Testing with the given month being February of 2019"
            (\_ ->
                let
                    rawDate =
                        Calendar.fromRawYearMonthDay { rawYear = 2019, rawMonth = 2, rawDay = 1 }
                in
                performTest rawDate 28
            )
        , test "Testing with the given month being February of 2020"
            (\_ ->
                let
                    rawDate =
                        Calendar.fromRawYearMonthDay { rawYear = 2020, rawMonth = 2, rawDay = 1 }
                in
                performTest rawDate 29
            )
        , test "Comparing the same month in different years. March 2019 & March 2020"
            (\_ ->
                let
                    ( firstDate, secondDate ) =
                        ( Calendar.fromRawYearMonthDay { rawYear = 2019, rawMonth = 3, rawDay = 1 }
                        , Calendar.fromRawYearMonthDay { rawYear = 2020, rawMonth = 3, rawDay = 1 }
                        )
                in
                case ( firstDate, secondDate ) of
                    ( Just fDay, Just lDay ) ->
                        Expect.notEqual (getDatesInMonth fDay) (getDatesInMonth lDay)

                    _ ->
                        Expect.fail "Couldn't create date from raw parts"
            )
        , test "Testing the whole date range on January 2019"
            (\_ ->
                let
                    rawDate =
                        Calendar.fromRawYearMonthDay { rawYear = 2019, rawMonth = 1, rawDay = 1 }

                    firstOfJanuaryMillis =
                        1546300800000

                    millisBasedOnDayMultiplier dayMultiplier =
                        firstOfJanuaryMillis + (Calendar.millisInADay * (dayMultiplier - 1))

                    expectedDates =
                        List.map
                            (Calendar.fromPosix << Time.millisToPosix << millisBasedOnDayMultiplier)
                            (List.range 1 31)
                in
                case rawDate of
                    Just date ->
                        Expect.equal (getDatesInMonth date) expectedDates

                    Nothing ->
                        Expect.fail "Couldn't create date from raw parts"
            )
        ]


getNextDayTest : Test
getNextDayTest =
    let
        performTest rawDate expectedDate =
            case ( rawDate, expectedDate ) of
                ( Just date, Just expected ) ->
                    Expect.equal (Calendar.getNextDay date) expected

                _ ->
                    Expect.fail "Couldn't create date from raw parts"
    in
    describe "Calendar.getNextDay Test Suite"
        [ test "Testing with the given date of 25th of August 2018"
            (\_ ->
                let
                    ( rawDate, expectedDate ) =
                        ( Calendar.fromRawYearMonthDay { rawYear = 2018, rawMonth = 8, rawDay = 25 }
                        , Calendar.fromRawYearMonthDay { rawYear = 2018, rawMonth = 8, rawDay = 26 }
                        )
                in
                performTest rawDate expectedDate
            )
        , test "Testing with the given date of 31st of December 2018"
            (\_ ->
                let
                    ( rawDate, expectedDate ) =
                        ( Calendar.fromRawYearMonthDay { rawYear = 2018, rawMonth = 12, rawDay = 31 }
                        , Calendar.fromRawYearMonthDay { rawYear = 2019, rawMonth = 1, rawDay = 1 }
                        )
                in
                performTest rawDate expectedDate
            )
        , test "Testing with the given date of 28th of February 2019"
            (\_ ->
                let
                    ( rawDate, expectedDate ) =
                        ( Calendar.fromRawYearMonthDay { rawYear = 2019, rawMonth = 2, rawDay = 28 }
                        , Calendar.fromRawYearMonthDay { rawYear = 2019, rawMonth = 3, rawDay = 1 }
                        )
                in
                performTest rawDate expectedDate
            )
        , test "Testing with the given date of 28th of February 2020 (leap year)"
            (\_ ->
                let
                    ( rawDate, expectedDate ) =
                        ( Calendar.fromRawYearMonthDay { rawYear = 2020, rawMonth = 2, rawDay = 28 }
                        , Calendar.fromRawYearMonthDay { rawYear = 2020, rawMonth = 2, rawDay = 29 }
                        )
                in
                performTest rawDate expectedDate
            )
        , test "Testing with the given date of 29th of February 2020 (leap year)"
            (\_ ->
                let
                    ( rawDate, expectedDate ) =
                        ( Calendar.fromRawYearMonthDay { rawYear = 2020, rawMonth = 2, rawDay = 29 }
                        , Calendar.fromRawYearMonthDay { rawYear = 2020, rawMonth = 3, rawDay = 1 }
                        )
                in
                performTest rawDate expectedDate
            )
        ]


getPreviousDayTest : Test
getPreviousDayTest =
    let
        performTest rawDate expectedDate =
            case ( rawDate, expectedDate ) of
                ( Just date, Just expected ) ->
                    Expect.equal (Calendar.getPreviousDay date) expected

                _ ->
                    Expect.fail "Couldn't create date from raw parts"
    in
    describe "Calendar.getPreviousDay Test Suite"
        [ test "Testing with the given date of 25th of August 2018"
            (\_ ->
                let
                    ( rawDate, expectedDate ) =
                        ( Calendar.fromRawYearMonthDay { rawYear = 2018, rawMonth = 8, rawDay = 25 }
                        , Calendar.fromRawYearMonthDay { rawYear = 2018, rawMonth = 8, rawDay = 24 }
                        )
                in
                performTest rawDate expectedDate
            )
        , test "Testing with the given date of 1st of January 2019"
            (\_ ->
                let
                    ( rawDate, expectedDate ) =
                        ( Calendar.fromRawYearMonthDay { rawYear = 2019, rawMonth = 1, rawDay = 1 }
                        , Calendar.fromRawYearMonthDay { rawYear = 2018, rawMonth = 12, rawDay = 31 }
                        )
                in
                performTest rawDate expectedDate
            )
        , test "Testing with the given date of 1st of March 2019"
            (\_ ->
                let
                    ( rawDate, expectedDate ) =
                        ( Calendar.fromRawYearMonthDay { rawYear = 2019, rawMonth = 3, rawDay = 1 }
                        , Calendar.fromRawYearMonthDay { rawYear = 2019, rawMonth = 2, rawDay = 28 }
                        )
                in
                performTest rawDate expectedDate
            )
        , test "Testing with the given date of 1st of March 2020"
            (\_ ->
                let
                    ( rawDate, expectedDate ) =
                        ( Calendar.fromRawYearMonthDay { rawYear = 2020, rawMonth = 3, rawDay = 1 }
                        , Calendar.fromRawYearMonthDay { rawYear = 2020, rawMonth = 2, rawDay = 29 }
                        )
                in
                performTest rawDate expectedDate
            )
        , test "Testing with the given date of 29th of February 2020 (leap year)"
            (\_ ->
                let
                    ( rawDate, expectedDate ) =
                        ( Calendar.fromRawYearMonthDay { rawYear = 2020, rawMonth = 2, rawDay = 29 }
                        , Calendar.fromRawYearMonthDay { rawYear = 2020, rawMonth = 2, rawDay = 28 }
                        )
                in
                performTest rawDate expectedDate
            )
        ]


getDateRangeTest : Test
getDateRangeTest =
    let
        performTest startDate endDate dayRangeLength =
            case ( startDate, endDate ) of
                ( Just start, Just end ) ->
                    let
                        dateRange =
                            Calendar.getDateRange start end

                        ( s, e ) =
                            ( List.head dateRange
                            , List.head <| List.reverse dateRange
                            )

                        areDaysSorted =
                            case Calendar.compareDates start end of
                                GT ->
                                    s == Just end && e == Just start

                                _ ->
                                    s == Just start && e == Just end
                    in
                    Expect.true "getDateRange didn't return the expected result"
                        (areDaysSorted && List.length dateRange == dayRangeLength)

                _ ->
                    Expect.fail "Couldn't create date from raw parts"
    in
    describe "Calendar.getDateRange Test Suite"
        [ test "Testing with range from 15th of November 2018 to 25th of November 2018"
            (\_ ->
                let
                    ( startDate, endDate ) =
                        ( Calendar.fromRawYearMonthDay { rawYear = 2018, rawMonth = 11, rawDay = 15 }
                        , Calendar.fromRawYearMonthDay { rawYear = 2018, rawMonth = 11, rawDay = 25 }
                        )
                in
                performTest startDate endDate 11
            )
        , test "Testing with range from 28th of December 2018 to 5th of January 2019"
            (\_ ->
                let
                    ( startDate, endDate ) =
                        ( Calendar.fromRawYearMonthDay { rawYear = 2018, rawMonth = 12, rawDay = 28 }
                        , Calendar.fromRawYearMonthDay { rawYear = 2019, rawMonth = 1, rawDay = 5 }
                        )
                in
                performTest startDate endDate 9
            )
        , test "Testing with range from 25th of February 2019 to 1st of March 2019"
            (\_ ->
                let
                    ( startDate, endDate ) =
                        ( Calendar.fromRawYearMonthDay { rawYear = 2019, rawMonth = 2, rawDay = 25 }
                        , Calendar.fromRawYearMonthDay { rawYear = 2019, rawMonth = 3, rawDay = 1 }
                        )
                in
                performTest startDate endDate 5
            )
        , test "Testing with range from 25th of February 2020 to 1st of March 2020"
            (\_ ->
                let
                    ( startDate, endDate ) =
                        ( Calendar.fromRawYearMonthDay { rawYear = 2020, rawMonth = 2, rawDay = 25 }
                        , Calendar.fromRawYearMonthDay { rawYear = 2020, rawMonth = 3, rawDay = 1 }
                        )
                in
                performTest startDate endDate 6
            )
        , test "Testing with range from 1st of January 2019 to 1st of January 2020"
            (\_ ->
                let
                    ( startDate, endDate ) =
                        ( Calendar.fromRawYearMonthDay { rawYear = 2019, rawMonth = 1, rawDay = 1 }
                        , Calendar.fromRawYearMonthDay { rawYear = 2020, rawMonth = 1, rawDay = 1 }
                        )
                in
                performTest startDate endDate 366
            )
        , test "Testing with range from 1st of January 2020 to 1st of January 2021"
            (\_ ->
                let
                    ( startDate, endDate ) =
                        ( Calendar.fromRawYearMonthDay { rawYear = 2020, rawMonth = 1, rawDay = 1 }
                        , Calendar.fromRawYearMonthDay { rawYear = 2021, rawMonth = 1, rawDay = 1 }
                        )
                in
                performTest startDate endDate 367
            )
        , test "Testing with range from 15th of January 2018 to the 1st of January 2018"
            (\_ ->
                let
                    ( startDate, endDate ) =
                        ( Calendar.fromRawYearMonthDay { rawYear = 2018, rawMonth = 1, rawDay = 15 }
                        , Calendar.fromRawYearMonthDay { rawYear = 2018, rawMonth = 1, rawDay = 1 }
                        )
                in
                performTest startDate endDate 15
            )
        , test "Testing with range from 1st of January 2018 to the 1st of January 2018"
            (\_ ->
                let
                    startDate =
                        Calendar.fromRawYearMonthDay { rawYear = 2018, rawMonth = 1, rawDay = 1 }
                in
                performTest startDate startDate 1
            )
        ]


yearFromIntTest : Test
yearFromIntTest =
    describe "Calendar.yearFromInt Test Suite"
        [ test "Testing with a valid year integer"
            (\_ ->
                Expect.equal (Just (Calendar.Year 2018)) (Calendar.yearFromInt 2018)
            )
        , test "Testing with an invalid year integer"
            (\_ ->
                Expect.equal Nothing (Calendar.yearFromInt 0)
            )
        ]


monthFromIntTest : Test
monthFromIntTest =
    describe "Calendar.monthFromInt Test Suite"
        [ test "Testing with a valid month integer"
            (\_ ->
                Expect.equal (Just Time.Dec) (Calendar.monthFromInt 12)
            )
        , test "Testing with an invalid month integer"
            (\_ ->
                Expect.equal Nothing (Calendar.monthFromInt 0)
            )
        ]


dayFromIntTest : Test
dayFromIntTest =
    describe "Calendar.dayFromInt Test Suite"
        [ test "Testing for the valid date of 25th of December 2018"
            (\_ ->
                Expect.equal (Just (Calendar.Day 25)) (Calendar.dayFromInt (Calendar.Year 2018) Time.Dec 25)
            )
        , test "Testing for the valid date of 29th of February 2020"
            (\_ ->
                Expect.equal (Just (Calendar.Day 29)) (Calendar.dayFromInt (Calendar.Year 2020) Time.Feb 29)
            )
        , test "Testing for the invalid date of 29th of February 2019"
            (\_ ->
                Expect.equal Nothing (Calendar.dayFromInt (Calendar.Year 2019) Time.Feb 29)
            )
        , test "Testing with an invalid day integer"
            (\_ ->
                Expect.equal Nothing (Calendar.dayFromInt (Calendar.Year 2018) Time.Dec 0)
            )
        ]


fromYearMonthDayTest : Test
fromYearMonthDayTest =
    describe "Calendar.fromYearMonthDay Test Suite"
        [ test "Testing for a valid date of 25th of December 2018"
            (\_ ->
                let
                    ( day, month, year ) =
                        ( Calendar.Day 25
                        , Time.Dec
                        , Calendar.Year 2018
                        )
                in
                Expect.equal
                    (Just (Calendar.Date { day = day, month = month, year = year }))
                    (Calendar.fromYearMonthDay year month day)
            )
        , test "Testing for the valid date of 29th of February 2020"
            (\_ ->
                let
                    ( day, month, year ) =
                        ( Calendar.Day 29
                        , Time.Feb
                        , Calendar.Year 2020
                        )
                in
                Expect.equal
                    (Just (Calendar.Date { day = day, month = month, year = year }))
                    (Calendar.fromYearMonthDay year month day)
            )
        , test "Testing for the invalid date of 29th of February 2019"
            (\_ ->
                let
                    ( day, month, year ) =
                        ( Calendar.Day 29
                        , Time.Feb
                        , Calendar.Year 2019
                        )
                in
                Expect.equal
                    Nothing
                    (Calendar.fromYearMonthDay year month day)
            )
        ]


compareDaysTest : Test
compareDaysTest =
    let
        ( low, high ) =
            ( Calendar.Day 15
            , Calendar.Day 25
            )
    in
    describe "Calendar.compareDays Test Suite"
        [ test "Comparing days 15 and 25"
            (\_ ->
                Expect.equal LT (Calendar.compareDays low high)
            )
        , test "Comparing days 25 and 15"
            (\_ ->
                Expect.equal GT (Calendar.compareDays high low)
            )
        , test "Comparing days 25 and 25"
            (\_ ->
                Expect.equal EQ (Calendar.compareDays high high)
            )
        ]


compareMonthsTest : Test
compareMonthsTest =
    describe "Calendar.compareMonths Test Suite"
        [ test "Comparing January and December"
            (\_ ->
                Expect.equal LT (Calendar.compareMonths Time.Jan Time.Dec)
            )
        , test "Comparing December and January"
            (\_ ->
                Expect.equal GT (Calendar.compareMonths Time.Dec Time.Jan)
            )
        , test "Comparing January and January"
            (\_ ->
                Expect.equal EQ (Calendar.compareMonths Time.Jan Time.Jan)
            )
        ]


compareYearsTest : Test
compareYearsTest =
    let
        ( low, high ) =
            ( Calendar.Year 2018
            , Calendar.Year 2020
            )
    in
    describe "Calendar.compareYears Test Suite"
        [ test "Comparing years 2018 and 2020"
            (\_ ->
                Expect.equal LT (Calendar.compareYears low high)
            )
        , test "Comparing days 2020 and 2018"
            (\_ ->
                Expect.equal GT (Calendar.compareYears high low)
            )
        , test "Comparing days 2020 and 2020"
            (\_ ->
                Expect.equal EQ (Calendar.compareYears high high)
            )
        ]


fromRawDayTest : Test
fromRawDayTest =
    describe "Calendar.fromRawDay Test Suite"
        [ test "Testing for a valid date of 25th of December 2018"
            (\_ ->
                let
                    ( day, month, year ) =
                        ( Calendar.Day 25
                        , Time.Dec
                        , Calendar.Year 2018
                        )
                in
                Expect.equal
                    (Just (Calendar.Date { day = day, month = month, year = year }))
                    (Calendar.fromRawDay year month 25)
            )
        , test "Testing for the valid date of 29th of February 2020"
            (\_ ->
                let
                    ( day, month, year ) =
                        ( Calendar.Day 29
                        , Time.Feb
                        , Calendar.Year 2020
                        )
                in
                Expect.equal
                    (Just (Calendar.Date { day = day, month = month, year = year }))
                    (Calendar.fromRawDay year month 29)
            )
        , test "Testing for the invalid date of 29th of February 2019"
            (\_ ->
                let
                    ( day, month, year ) =
                        ( Calendar.Day 29
                        , Time.Feb
                        , Calendar.Year 2019
                        )
                in
                Expect.equal
                    Nothing
                    (Calendar.fromRawDay year month 29)
            )
        ]


millisSinceEpochTest : Test
millisSinceEpochTest =
    describe "Calendar.millisSinceEpoch Test Suite"
        [ test "Testing for year 1970"
            (\_ ->
                Expect.equal 0 (Calendar.millisSinceEpoch (Calendar.Year 1970))
            )
        , test "Testing for year 2018"
            (\_ ->
                Expect.equal 1514764800000 (Calendar.millisSinceEpoch (Calendar.Year 2018))
            )
        , test "Testing for year 1969"
            (\_ ->
                Expect.equal 0 (Calendar.millisSinceEpoch (Calendar.Year 1969))
            )
        ]


millisSinceStartOfTheYearTest : Test
millisSinceStartOfTheYearTest =
    let
        yearsRange =
            List.map Calendar.Year (List.range 1900 2020)

        ( leapYears, nonLeapYears ) =
            ( List.filter Calendar.isLeapYear yearsRange
            , List.filter (not << Calendar.isLeapYear) yearsRange
            )

        ( leapYearsExpectation, nonLeapYearsExpectation ) =
            ( List.repeat (List.length leapYears) 5184000000
            , List.repeat (List.length nonLeapYears) 5097600000
            )
    in
    describe "Calendar.millisSinceStartOfTheYear Test Suite"
        [ test "Testing for January of 1970"
            (\_ ->
                Expect.equal 0 (Calendar.millisSinceStartOfTheYear (Calendar.Year 2018) Time.Jan)
            )
        , test "Testing for December of 2018"
            (\_ ->
                Expect.equal 28857600000 (Calendar.millisSinceStartOfTheYear (Calendar.Year 2018) Time.Dec)
            )
        , test "Testing for March of non leap years from 1900 - 2020"
            (\_ ->
                Expect.equalLists nonLeapYearsExpectation
                    (List.map
                        (\year ->
                            Calendar.millisSinceStartOfTheYear year Time.Mar
                        )
                        nonLeapYears
                    )
            )
        , test "Testing for March of leap years from 1900 - 2020"
            (\_ ->
                Expect.equalLists leapYearsExpectation
                    (List.map
                        (\year ->
                            Calendar.millisSinceStartOfTheYear year Time.Mar
                        )
                        leapYears
                    )
            )
        ]


millisSinceStartOfTheMonthTest : Test
millisSinceStartOfTheMonthTest =
    describe "Calendar.millisSinceStartOfTheMonth Test Suite"
        [ test "Testing for the 1st of a month"
            (\_ ->
                Expect.equal 0 (Calendar.millisSinceStartOfTheMonth (Calendar.Day 1))
            )
        , test "Testing for the 15th of a month"
            (\_ ->
                Expect.equal 1209600000 (Calendar.millisSinceStartOfTheMonth (Calendar.Day 15))
            )
        , test "Testing for the 31st of a month"
            (\_ ->
                Expect.equal 2592000000 (Calendar.millisSinceStartOfTheMonth (Calendar.Day 31))
            )
        ]



-- NEW TODO: Implement the tests for the following functions + cases.
{-
   yearFromInt  -- DONE
   monthFromInt -- DONE
   dayFromInt   -- DONE

   fromYearMonthDay -- DONE
   compareDays      -- DONE
   compareMonths    -- DONE
   compareYears     -- DONE

   fromRawDay       -- DONE

   getNextMonth_     -- TODO ??? NOPE since they are internal and they are part of getNextMonth
   getPreviousMonth_ -- TODO ??? NOPE since they are internal and they are part of getPreviousMonth

   millisInYear      -- TODO ??? NOPE

   millisSinceEpoch           -- DONE
   millisSinceStartOfTheYear  -- DONE
   millisSinceStartOfTheMonth -- DONE

-}
{- Implement the tests for the following functions:
   yearFromInt  -- Not to be exposed
   monthFromInt -- Not to be exposed
   dayFromInt   -- Not to be exposed

   getNextMonth     -- DONE
   getPreviousMonth -- DONE

   previousMonthsInTheYear -- Rename to getPrecedingMonths ? -- DONE
   nextMonthsInTheYear     -- Implement ? Rename to followingMonthsInYear ? -- DONE
   setYear ??
   setMonth ??
   setDay ??
   isLeapYear  -- DONE
   lastDayOf   -- DONE

   incrementYear ?? -- DONE
   decrementYear ?? -- DONE

   toPosix ??  -- DONE
   weekdayFromDate  -- DONE
   getMonthDates ?? Rename it to getDatesInMonth ? -- DONE
   nextDay      -- DONE
   previousDay  -- DONE
   getDateRange -- DONE
-}
