db.currentOp() {
    "inprog": [{
            "desc": "conn150",
            "threadId": "0x700000dcf000",
            "connectionId": 150,
            "client": "127.0.0.1:52716",
            "appName": "MongoDB Shell",
            "active": true,
            "opid": 3174597,
            "secs_running": 0,
            "microsecs_running": NumberLong(17),
            "op": "command",
            "ns": "admin.$cmd",
            "query": {
                "currentOp": 1
            },
            "numYields": 0,
            "locks": {

            },
            "waitingForLock": false,
            "lockStats": {

            }
        },
        {
            "desc": "conn149",
            "threadId": "0x700000b40000",
            "connectionId": 149,
            "client": "127.0.0.1:52713",
            "appName": "MongoDB Shell",
            "active": true,
            "opid": 3174496,
            "secs_running": 72,
            "microsecs_running": NumberLong(72728161),
            "op": "update",
            "ns": "performance.sensor_readings",
            "query": {
                "$where": "function(){sleep(500);return false;}"
            },
            "planSummary": "COLLSCAN",
            "numYields": 144,
            "locks": {
                "Global": "w",
                "Database": "w",
                "Collection": "w"
            },
            "waitingForLock": false,
            "lockStats": {
                "Global": {
                    "acquireCount": {
                        "r": NumberLong(149),
                        "w": NumberLong(145)
                    }
                },
                "Database": {
                    "acquireCount": {
                        "r": NumberLong(2),
                        "w": NumberLong(145)
                    }
                },
                "Collection": {
                    "acquireCount": {
                        "r": NumberLong(2),
                        "w": NumberLong(145)
                    }
                }
            }
        }
    ],
    "ok": 1
}

db.killOp(3174496) {
    "info": "attempting to kill op",
    "ok": 1
}

homework.c()
/*
12
*/
