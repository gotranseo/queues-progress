# QueuesProgress

QueuesProgress is a tiny CLI built to help you better understand what jobs are stuck/in progress for your Vapor Queues Redis instance. If you find yourself doing the following dance on a regular basis:

```sh
> redis-cli
> lrange vapor_queues[default]-processing 0 -1
> get job:key_name
```

Just to get information about a specific job, this CLI can help you. 

## Installation 

To install, run the following commands: 

```sh
git clone https://github.com/gotranseo/queues-progress
cd queues-progress 
swift build -c release 
mv .build/release/Run /usr/local/bin/queues-progress
queues-progress
```

## Usage 

```
Usage: queues-progress [--host,-h] [--password,-p] [--queue,-q] [--pending,-s]

Checks the progress of queue jobs.

Options:
      host The host of the redis server
  password The password of the redis server
     queue The queue to check (defaults to `default`)
   pending Whether or not to check the pending queue. Defaults to `false` and checks the `processing` state
```