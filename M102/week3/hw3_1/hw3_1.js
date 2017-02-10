conn = new Mongo();
db = conn.getDB("performance");

db.sensor_readings.createIndex({
    active: 1,
    tstamp: 1
});
