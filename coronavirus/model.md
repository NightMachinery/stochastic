
# A rough draft of a model for simulating disease spread

This is Fereidoon Mehri's for Dr. Mirsadeghi's simulation course at SUT, 2020 Spring.
As this draft is still incomplete, see the [latest version on my Github](https://github.com/batbone/stochastic/blob/master/coronavirus/model.md). That version is also auto-rendered by Github, so you don't need a Markdown renderer.

## Guide to reading this

I am sketching the structure of the model, and how they should be connected.

Some hints:
* `Function` is any read-only function.
* `Function!` is any function that possibly mutates the state.
* `[]` means array.
* `(,)` means tuple.
* `(int, string) -> int` describes the type of a function.
* I use docstring-style for comments, e.g.:

    "This is a comment!"

* `ASSERT` means some relation must hold.
* Search for `SOPH` to find ideas to make the model more sophisticated scattered in the current doc.

### Concepts

#### Rounds

The model proceeds in turns, which I think should be interpreted as hours. We can, of course, change the parameters of the model to make interpreting it as other intervals of time possible (#SOPH). Using longer intervals will make the computation costs lower, but the results will also be more coarsed.

#### World

The global state of the model. It consists of `Place`s and `Person`s.

#### Person

Each `Person` belongs to a `Place`.

#### Places

Each `Place` can have other `Place`s as subplaces. The `Place`'s 'self' is called its root. This can be best shown in a diagram:

![](pics/automaticpaste_2020-04-20-23-20-51.png)



#### Feedback

Some parts of the model need to get feedback (i.e., information) from other parts of the model. For example, each `Person` has a `SocialDistancingFactor` which shows how receptive that `Person` is to social distancing. But this also crucially depends on the, e.g., where they are and what the culture/politics is at that `Place`. So we use an information reporting function (which is read-only), named `getSocialDistancing`, which reads information from multiple sources (here both the `Person` and their `Place`), combines this in the appropriate manner, and returns the result.

Another example is the `possibly move` function list of `Person`; These ultimately determine where that Person will end up as the round ends. This list, by default, should contain a function with utmost priority (`0`)(So it runs before others) that will run its parent `Place` `moveChild(child) -> (Place | null)`. Each of these `moveChild` functions should also call their parent `Place`'s `moveChild`, if they themselves are not going to return a `Place` (i.e., if they want to return `null`).

### Ideas to make model more sophisticated

* Search for SOPH to find more ideas scattered in the current doc.
* Make `Place`s mobile in addition to people.

    This should work similarly to moving people :-?

* Make `Place`s able to be children to multiple parents at once.
* Make current state or an essential summary of it persist in a circular queue, so we can implement time delay. We can also persist every N (24?) rounds to lessen the memory pressure.

## Model's rough class structure (still woefully incomplete)

```
Place: class
    ParentPlace: Place | null
    Subplaces: (Place, DistributiveProbability: float)[]
        ASSERT sum(DistributiveProbability) <= 1

    Actions: (PartialOrder: int, Function!)[] "Functions with lower order numbers will run first."
        Start of round actions
            Possibilities:
                Change probability of accepting travelers as density of infection reaches a threshold.
                ...

        End of round actions

    Count of: int
        count of each state of people (e.g., sick, asymptomatic)(Doesn't include subplaces)

    Measure of: int ?
        size (Doesn't include subplaces, as usual)

    Information Reporting: Function
        all people: -> int
            "Sums all states of people"
        desnity: -> int
            "all people/size"

    Receives infective pressure from: (Place, PressureWeight: int)[]

    Accept travel request and distribute it in subplaces (including self): Function
        "Accepts with probability pEnter and distribute to each subplace according to DistributiveProbability. (The remainder of probability from subplaces goes into the self.)"
        "SOPH: Discriminate based on properties of entrant people."
```

```
Person: class
    "SOPH: Note that this could also be an animal. :D We just need to set the correct parameters."
    parentPlace: Place
    Might have these properties:
        nationality: enum(countries) or string ?
        
    possiblyMove: (PartialOrder, Function!)[]
        "At the start of round, these will be called in the partial order given. If any of them returns a place, this person will move there and the other functions will not be called.
            If the current location should be returned, nothing will be done but the other functions won't be called.
            If 
    changeState: Function! 
        "This function should be called for each person at the end of rounds."
        get new state: Function(self) -> new state
    currentState: enum(Disease States)
```

### Disease States: enum

* immune

    "This means the `Person` is naturally immune to the disease."

* neverInfected
* asymptomatic
* mildly sick
* sick
* severely sick
* recovered
* dead

## Examples of using the model

### How to model different stuff

#### Travel restrictions

Lowering the probability of `Place` to allow entry.

#### Travel-loving people

Create a new class `TravelLovingPerson` that inherits from `Person` and adds this function to its `super`'s `possibly move`:
```
const travelProbability = 0.0001 # Note that this is going to be called every round, so even a low chance means a lot of moving.

(self) -> (Place | null):
    if rand() <= travelProbability
        return selectRandomPlace()
    else
        return null
    end
```

### State forces non-nationals out

As `Person`'s `possibly move` calls the parent `Place`'s `moveChild`, the state simply needs to check each `Person`'s `Nationality` and return a `Place` for non-nationals (anywhere in the world, possibly that `Person`'s `hometown`), and `null` for nationals.

### Short immunity

`Person`'s `changeState` function can insert a property `Person.lastRecoveryDate` when changing that `Person.currentState` to `recovered`. The same function can then check that property and after some time has passed, do the appropriate thing. For example, treat the `Person` as if they were `neverInfected`.