


//: This is a companion Playground for the article "Swift Functors, Applicatives, and Monads in Pictures", available at http://www.mokacoding.com/blog/functor-applicative-monads-in-pictures/
//: The article itself is a translation of the original "Functors, Applicatives, and Monads in Pictures" written for Haskell by Aditya Bhargava, available at http://adit.io/posts/2013-04-17-functors,_applicatives,_and_monads_in_pictures.html
//:
//: ## Optional
//:
//: Optional is just a type

enum MyOptional<T> {
    case Some(T)
    case None
}

//: ## Functor
//:
//: Optional defines map, which knows how to apply a function to the optional value, depending on it's state

func plusThree(addend: Int) -> Int {
    return addend + 3
}

Optional.some(2).map(plusThree)

//: We can use autoclosures and be more succint

Optional.some(2).map { $0 + 3 }

//: If the optional value is .None, map will return .None (nil)

Optional.none.map { $0 + 3 }

//: Map implementation might look like this

func myMap<T, U>(a: T?, f: (T) -> U) -> U? {
    switch a {
    case .some(let x): return f(x)
    case .none: return .none
    }
}

myMap(a: Optional.some(2), f: { $0 + 3 })

//: We can define an infix operator

infix operator <^>: MultiplicationPrecedence

func <^><T, U>(f: (T) -> U, a: T?) -> U? {
    return a.map(f)
}

plusThree <^> Optional.some(2)

//: Turns out functions can be mapped as well. Functions are functors too!

typealias IntFunction = (Int) -> Int

func map(_
	f: @escaping IntFunction, _ g: @escaping IntFunction) -> IntFunction {
    return { x in f(g(x)) }
}

let foo = map({ $0 + 2 }, { $0 + 3 })
foo(10)

//: ## Applicative
extension Optional {
    func apply<U>(_ f: ((Wrapped) -> U)?) -> U? {
        switch f {
        case .some(let someF): return self.map(someF)
        case .none: return .none
        }
    }
}

extension Array {
    func apply<U>(_
		fs: [(Element) -> U]) -> [U] {
        var result = [U]()
        for f in fs {
            for element in self.map(f) {
                result.append(element)
            }
        }
        return result
    }
}

infix operator <*>: MultiplicationPrecedence

func <*><T, U>(f: ((T) -> U)?, a: T?) -> U? {
    return a.apply(f)
}

func <*><T, U>(f: [(T) -> U], a: [T]) -> [U] {
    return a.apply(f)
}

Optional.some({ $0 + 3 }) <*> Optional.some(2)

let arrayApplicative = [ { $0 + 3 }, { $0 * 2 } ] <*> [1, 2, 3]
//: _Playground (as of Xcode 7 Beta 3) doesn't seem to be happy show the result of array applications , so we'll print open the console with Cmd + Y to see it_

print(arrayApplicative)

public func curry<A, B, C>(_ function: @escaping (A, B) -> C) -> (A) -> (B) -> C {
	return { (a: A) -> (B) -> C in { (b: B) -> C in function(a, b) } }
}

func addition(a: Int, b: Int) -> Int {
    return a + b
}

let curriedAddition = curry(addition)

curriedAddition(2)(3)

curriedAddition <^> Optional(2) <*> Optional(3)

func multiplication(a: Int, b: Int) -> Int {
	return a * b
}

let curriedTimes = curry(multiplication)

curriedTimes <^> Optional(5) <*> Optional(3)

//: ## Monads

infix operator >>- : MultiplicationPrecedence

func >>-<T, U>(a: T?, f: (T) -> U?) -> U? {
    return a.flatMap(f)
}

func half(a: Int) -> Int? {
    return a % 2 == 0 ? a / 2 : .none
}

Optional(3) >>- half
Optional(4) >>- half
Optional.none >>- half

//: We can even chain >>-

Optional(20) >>- half >>- half >>- half
