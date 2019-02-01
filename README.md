# DateTime

The 0.19 version of Elm introduced some [important changes][important-changes] in the Time API which is now split into a [separate package][elm-time].

The DateTime package was inspired because __date and time__ is a crucial part on our everyday lives and most of the products we are working on rely heavily on the ___correct interpretation of both.___
This means that whenever we need to handle date or time we need to be sure that it is a ___valid___ __DateTime__. In order to guarantee the __validity of the DateTime__ but also create a solid package
we had to make some sacrifices such as not using timezones.

This means that all the results that DateTime returns are based on [UTC][UTC-wiki] and therefore the consumer of the package should be the one that implements timezone specific solutions. This gives us the
freedom to work on generic solutions of DateTime handling instead of having timezone specific solutions.

The main goal of this package is to serve as an extension of [elm/time][elm-time] and to provide ___isomorphism___ between [Time.Posix][TimePosix] and __DateTime__.
This basically means that __DateTime__ can be constructed by a [Time.Posix][TimePosix] type and it can be converted back to [Time.Posix][TimePosix] without losing any of it's integrity.

<br/>
#### Constructing a DateTime

You can construct a DateTime in 2 different ways. Either by providing a __Posix Time__ or by providing a Calendar.Date and a Clock.Time.

![alt text](https://github.com/PanagiotisGeorgiadis/elm-datetime/blob/master/assets/Isomorphic-DateTime-Construction.png "Isomorphic DateTime construction")

<br/>
You can also ___attempt___ to construct a DateTime by providing its' constituent parts as raw data.

![alt text](https://github.com/PanagiotisGeorgiadis/Elm-DateTime/blob/master/assets/RawParts-DateTime-Construction.png "RawParts to Maybe DateTime")

<br/>
#### Constructing a Calendar.Date

You can attempt to construct a Calendar.Date by providing its' constituent parts as raw data as shown in the diagram below.

![alt text](https://github.com/PanagiotisGeorgiadis/Elm-DateTime/blob/master/assets/RawParts-Calendar-Construction.png "RawParts to Calendar.Date")

There could be some cases where you don't really care about the time but you only need to store the Dates. Of course this will mean that if you try to convert a Calendar.Date to
a Posix Time it will always default to 00:00 hours. You can always use this along with a Clock.Time to construct a DateTime in case you need to.

<br/>
#### Constructing a Clock.Time

You can attempt to construct a Clock.Time by providing its' constituent parts as raw data as shown in the diagram below.

![alt text](https://github.com/PanagiotisGeorgiadis/Elm-DateTime/blob/master/assets/RawParts-Clock-Construction.png "RawParts to Clock.Time")

Building a timer app could be one of the cases where you don't really care about the Calendar.Date portion of DateTime. This would mean that you only need a Clock.Time in order
to keep track of the time. Be very careful though if you want to get a valid Posix Time you would need to convert your Clock.Time to a DateTime by using a Calendar.Date as well.

#
#### Running the package locally
```
npm install
npm run elm-make
npm test
```

[important-changes]: https://github.com/elm/compiler/blob/master/upgrade-docs/0.19.md#modules-moved
[elm-time]: https://package.elm-lang.org/packages/elm/time/latest/
[UTC-wiki]: https://en.wikipedia.org/wiki/Coordinated_Universal_Time
[TimePosix]: https://package.elm-lang.org/packages/elm/time/latest/Time#Posix
