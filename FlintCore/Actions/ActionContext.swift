//
//  ActionContext.swift
//  FlintCore-iOS
//
//  Created by Marc Palmer on 05/03/2018.
//  Copyright © 2018 Montana Floss Co. Ltd. All rights reserved.
//

import Foundation

/// The context in which an action executes. Contains the initial state and contextual logger.
///
/// The context can be passed forward, or a new instance derived with new state, so that e.g. a subsystem can be
/// passed the logger and state information as a single opaque value, without passing forward the entire action request
public class ActionContext<InputType> where InputType: FlintLoggable {

    /// Provides access to the context specific loggers for this action invocation
    public class Logs {
        public internal(set) var development: ContextSpecificLogger?
        public internal(set) var production: ContextSpecificLogger?
    }
    
    /// The input to the action
    public let input: InputType

    /// The contextual logs for the action
    public let logs: Logs = .init()
    
    /// The source of the action, used to tell if it came from the application itself or e.g. Siri.
    public let source: ActionSource
    
    private let session: ActionSession
    
    init(input: InputType, session: ActionSession, source: ActionSource) {
        self.input = input
        self.session = session
        self.source = source
    }

    /// Perform the action in the same session as this current action request, passing on the contextual loggers
    /// Use this to perform other actions within action implementations.
    public func perform<FeatureType, ActionType>(_ actionBinding: StaticActionBinding<FeatureType, ActionType>,
                           using presenter: ActionType.PresenterType,
                           with input: ActionType.InputType,
                           userInitiated: Bool,
                           completion: ((ActionOutcome) -> ())? = nil) {
        session.perform(actionBinding, using: presenter, with: input, userInitiated: userInitiated, source: source, completion: completion)
    }
    
    /// Perform the action in the same session as this current action request, passing on the contextual loggers
    /// Use this to perform other actions within action implementations.
    public func perform<FeatureType, ActionType>(_ conditionalRequest: ConditionalActionRequest<FeatureType, ActionType>,
                           using presenter: ActionType.PresenterType,
                           with input: ActionType.InputType,
                           userInitiated: Bool,
                           completion: ((ActionOutcome) -> ())? = nil) {
        session.perform(conditionalRequest, using: presenter, with: input, userInitiated: userInitiated, source: source, completion: completion)
    }

    public var debugDescriptionOfInput: String? {
        if input is NoInput {
            return nil
        } else {
            return String(reflecting: input)
        }
    }
}
