//
//  File.swift
//  
//
//  Created by Jimmy McDermott on 10/10/20.
//

import Foundation
import Redis
import NIO
import Vapor

struct SimpleRedisClient: RedisClient {
    let configuration: RedisConfiguration
    let eventLoopGroup: EventLoopGroup

    private struct PoolKey: StorageKey, LockKey {
        typealias Value = [EventLoop.Key: RedisConnectionPool]
    }

    // must be event loop from this app's elg
    internal func pool() -> RedisConnectionPool {
        let logger = Logger(label: "queues.progress.logger")
        return RedisConnectionPool(
            serverConnectionAddresses: configuration.serverAddresses,
            loop: eventLoop,
            maximumConnectionCount: configuration.pool.maximumConnectionCount,
            minimumConnectionCount: configuration.pool.minimumConnectionCount,
            connectionPassword: configuration.password,
            connectionLogger: logger,
            connectionTCPClient: nil,
            poolLogger: logger,
            connectionBackoffFactor: configuration.pool.connectionBackoffFactor,
            initialConnectionBackoffDelay: configuration.pool.initialConnectionBackoffDelay,
            connectionRetryTimeout: configuration.pool.connectionRetryTimeout
        )
    }

    func send(command: String, with arguments: [RESPValue]) -> EventLoopFuture<RESPValue> {
        self.pool().send(command: command, with: arguments)
    }

    public var eventLoop: EventLoop {
        self.eventLoopGroup.next()
    }

    public func logging(to logger: Logger) -> RedisClient {
        self
    }

    func unsubscribe(from channels: [RedisChannelName]) -> EventLoopFuture<Void> {
        eventLoop.future()
    }

    func punsubscribe(from patterns: [String]) -> EventLoopFuture<Void> {
        eventLoop.future()
    }
}

private extension EventLoop {
    typealias Key = ObjectIdentifier
    var key: Key {
        ObjectIdentifier(self)
    }
}
