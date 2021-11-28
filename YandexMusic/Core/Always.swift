// Copyright (c) 2019–20 Adam Sharp and thoughtbot, inc.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

import Combine

/// A publisher that repeatedly sends the same value as long as there
/// is demand.
public struct Always<Output>: Publisher {
    public typealias Failure = Never

    public let output: Output

    public init(_ output: Output) {
        self.output = output
    }

    public func receive<S: Subscriber>(subscriber: S) where S.Input == Output, S.Failure == Failure {
        let subscription = Subscription(output: output, subscriber: subscriber)
        subscriber.receive(subscription: subscription)
    }
}

private extension Always {
    final class Subscription<S: Subscriber> where S.Input == Output, S.Failure == Failure {
        private let output: Output
        private var subscriber: S?

        init(output: Output, subscriber: S) {
            self.output = output
            self.subscriber = subscriber
        }
    }
}

extension Always.Subscription: Cancellable {
    func cancel() {
        subscriber = nil
    }
}

extension Always.Subscription: Subscription {
    func request(_ demand: Subscribers.Demand) {
        var demand = demand
        while let subscriber = subscriber, demand > 0 {
            demand -= 1
            demand += subscriber.receive(output)
        }
    }
}
