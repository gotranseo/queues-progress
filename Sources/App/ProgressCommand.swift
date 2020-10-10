//
//  File.swift
//  
//
//  Created by Jimmy McDermott on 10/10/20.
//

import Foundation
import ConsoleKit
import Redis
import Vapor

public struct ProgressCommand: Command {
    public struct Signature: CommandSignature {
        @Option(name: "host", short: "h", help: "The host of the redis server")
        var host: String?

        @Option(name: "password", short: "p", help: "The password of the redis server")
        var password: String?

        @Option(name: "queue", short: "q", help: "The queue to check (defaults to `default`)")
        var queue: String?

        @Option(name: "pending", short: "s", help: "Whether or not to check the pending queue. Defaults to `false` and checks the `processing` state")
        var pending: Bool?

        public init() {}
    }

    /// See `Command`.
    public let signature = Signature()

    /// See `Command`.
    public var help: String {
        "Checks the progress of queue jobs."
    }

    public init() { }

    public func run(using context: CommandContext, signature: Signature) throws {
        guard let host = signature.host else {
            context.console.error("Please specify a host", newLine: true)
            return
        }

        guard let password = signature.password else {
            context.console.error("Please specify a password", newLine: true)
            return
        }

        let config = try RedisConfiguration(hostname: host,
                                            port: 6379,
                                            password: password,
                                            pool: .init(connectionRetryTimeout: .minutes(1)))
        let redis = context.application.redis
        redis.configuration = config

        let keyName = "vapor_queues[\(signature.queue ?? "default")]\((signature.pending ?? false) ? "" : "-processing")"
        let keys = try redis.lrange(from: .init(keyName), fromIndex: 0).wait().compactMap { $0.string }.map { "job:\($0)" }
        context.console.success("\(keys.count) keys fetched from the \((signature.pending ?? false) ? "" : "processing ")queue")

        let dataType = context.console.choose("Data Return Type", from: ["Full Data", "Job Type Overview"])

        let progressBar = context.console.loadingBar(title: "Loading Data")
        progressBar.start()

        var dataReturned = [PayloadData]()
        for key in keys {
            guard let data = try redis.get(.init(key), as: Data.self).wait() else {
                context.console.error("Skipping \(key)", newLine: true)
                continue
            }

            var payload = try JSONDecoder().decode(PayloadData.self, from: data)
            payload.key = key
            dataReturned.append(payload)
        }

        progressBar.succeed()
        if dataType == "Full Data" {
            for payload in dataReturned {
                context.console.info("------------------------", newLine: true)
                context.console.success(payload.key ?? "")
                context.console.output("    Job Name: ", style: .info, newLine: false)
                context.console.output("\(payload.jobName)", style: .success)
                context.console.output("    Queued At: ", style: .info, newLine: false)
                context.console.output("\(payload.queuedAt)", style: .success)
                context.console.output("    Bytes: ", style: .info, newLine: false)
                context.console.output("\(payload.payload.count)", style: .success)
                context.console.output("    Max Retry Count: ", style: .info, newLine: false)
                context.console.output("\(payload.maxRetryCount)", style: .success)
                context.console.output("    Delay Until: ", style: .info, newLine: false)
                if let delayUntil = payload.delayUntil {
                    context.console.output("\(delayUntil)", style: .success)
                } else {
                    context.console.output("N/A", style: .success)
                }
            }
        }

        if dataType == "Job Type Overview" {
            dataReturned.map { $0.jobName }.histogram.forEach {
                context.console.output("\($0.key): ", style: .info, newLine: false)
                context.console.output("\($0.value)", style: .success)
            }
        }
    }
}

struct PayloadData: Codable {
    var key: String?
    let payload: [UInt8]
    let maxRetryCount: Int
    let delayUntil: Date?
    let queuedAt: Date
    let jobName: String
}

extension Sequence where Element: Hashable {
    var histogram: [Element: Int] {
        return self.reduce(into: [:]) { counts, elem in counts[elem, default: 0] += 1 }
    }
}
