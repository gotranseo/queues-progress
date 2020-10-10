# QueuesProgress

QueuesProgress is a tiny CLI built to help you better understand what jobs are stuck/in progress for your Vapor Queues Redis instance. If you find yourself doing the following dance on a regular basis:

```sh
> redis-cli
> lrange vapor_queues[default]-processing 0 -1
> get job:key_name
```

then this CLI can help you!

## Installation 

To install, run the following commands: 

```sh
git clone https://github.com/gotranseo/queues-progress
cd queues-progress 
swift build -c release 
mv .build/release/Run /usr/local/bin/queues
queues progress --help
```

## Usage 

```
Usage: queues-progress progress [--host,-b] [--password,-p] [--queue,-q] [--pending,-s] [--key,-k]

Checks the progress of queue jobs.

Options:
      host The host of the redis server
  password The password of the redis server
     queue The queue to check (defaults to `default`)
   pending Whether or not to check the pending queue. Defaults to `false` and checks the `processing` state
       key A specific key to filter against
```

When running the CLI you have a view different options for displaying the data:

```
queues progress -b localhost

Data Return Type
1: Full Data
2: Full Data (Expanded Payload)
3: Job Type Overview
> 
```

Full data will return all of the stored data points for the payload, formatted nicely: 

```
job:6C6DE227-38BE-42C8-90F4-CA741A976264
    Job Name: JobName
    Queued At: 2020-10-01 08:00:15 +0000
    Bytes: 4189
    Max Retry Count: 0
    Delay Until: N/A
```

Selecting the expanded payload option will also dump out the full JSON string of the data associated with the job.

```
------------------------
job:6C6DE227-38BE-42C8-90F4-CA741A976264
    Job Name: JobName
    Queued At: 2020-10-01 08:00:15 +0000
    Bytes: 4189
    Max Retry Count: 0
    Delay Until: N/A
    Payload Data: **Payload Data Here**
```

You can also view a breakdown of the counts of jobs in your processing queue:

```
JobOne: 1
JobTwo: 11
JobThree: 2
```

If you want to filter by a specific key, specify it using the `-k` flag:

`queues progress -b localhost -k key-name`

If you are using a different queue name than `default` you can specify that as well:

`queues progress -b localhost -q email-queue`

The default setting of the tool is to pull data from the `processing` queue. If you want to pull it from the pending list instead pass in the `-s` flag:

`queues progress -b localhost -s true`
